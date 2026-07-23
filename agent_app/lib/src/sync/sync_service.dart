import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../data/api/api_client.dart';
import '../data/local/database.dart';

/// Drains the local capture queue to the API. Runs on connectivity changes and
/// on demand. The API sync endpoint is idempotent on client_uuid, so retries —
/// the normal case for a field app on flaky mobile data — converge to identical
/// server state with zero duplicates (CLAUDE.md).
class SyncService {
  SyncService(this._db, this._api);

  final AppDatabase _db;
  final ApiClient _api;

  final _status = StreamController<SyncPhase>.broadcast();
  Stream<SyncPhase> get status => _status.stream;

  StreamSubscription? _connSub;
  bool _running = false;

  /// Start reacting to connectivity: the moment we're back online, drain.
  void start() {
    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) drain();
    });
  }

  void dispose() {
    _connSub?.cancel();
    _status.close();
  }

  /// Push everything not-yet-synced. Safe to call repeatedly; re-entrant calls
  /// are ignored while a drain is in flight.
  Future<SyncOutcome> drain() async {
    if (_running) return SyncOutcome.skipped;
    _running = true;
    _status.add(SyncPhase.syncing);
    try {
      // 1) Photos first: bytes go straight to object storage; we only learn the
      //    storage_key here, which the sync batch then references.
      await _uploadPendingPhotos();

      // 2) Assemble a dependency-ordered batch: building → unit_type →
      //    snapshot → photo. The server commits records in order, so a photo's
      //    building exists by the time the photo record is applied.
      final records = await _buildBatch();
      if (records.isEmpty) {
        _status.add(SyncPhase.idle);
        return SyncOutcome.nothingToDo;
      }

      final results = await _api.sync(records);
      await _applyResults(results);
      _status.add(SyncPhase.idle);
      return SyncOutcome.success;
    } catch (_) {
      // Network / server error — records stay pending and retry next time.
      _status.add(SyncPhase.offline);
      return SyncOutcome.failed;
    } finally {
      _running = false;
    }
  }

  Future<void> _uploadPendingPhotos() async {
    final pending = await _db.pendingPhotos();
    for (final photo in pending) {
      if (photo.uploaded && photo.storageKey != null) continue;
      final file = File(photo.localPath);
      if (!file.existsSync()) {
        await _db.markPhotoSynced(photo.id, SyncStatus.failed,
            error: 'local file missing');
        continue;
      }
      final presign = await _api.presignPhoto(buildingId: photo.buildingId);
      await _api.uploadBytes(uploadUrl: presign.uploadUrl, file: file);
      await _db.setPhotoUploaded(photo.id, presign.storageKey);
    }
  }

  Future<List<Map<String, dynamic>>> _buildBatch() async {
    final records = <Map<String, dynamic>>[];

    for (final b in await _db.pendingBuildings()) {
      records.add({
        'type': 'building',
        'client_uuid': b.id,
        'data': {
          'estate': b.estateSlug,
          'name': b.name,
          'lat': b.lat,
          'lng': b.lng,
          'floors': b.floors,
          'water_notes': b.waterNotes,
          'power_notes': b.powerNotes,
          'security_notes': b.securityNotes,
          'parking': b.parking,
          'caretaker_name': b.caretakerName,
          'caretaker_phone': b.caretakerPhone,
        },
      });
    }

    for (final u in await _db.pendingUnitTypes()) {
      records.add({
        'type': 'unit_type',
        'client_uuid': u.id,
        'data': {
          'building': u.buildingId,
          'kind': u.kind,
          'rent_kes': u.rentKes,
          'deposit_kes': u.depositKes,
          'amenities': _decodeAmenities(u.amenities),
        },
      });
    }

    for (final s in await _db.pendingSnapshots()) {
      records.add({
        'type': 'vacancy_snapshot',
        'client_uuid': s.id,
        'data': {
          'unit_type': s.unitTypeId,
          'vacant_count': s.vacantCount,
          'verified_at': s.verifiedAt.toUtc().toIso8601String(),
          'source': s.source,
        },
      });
    }

    // Only photos whose bytes are already in object storage can be referenced.
    for (final ph in await _db.pendingPhotos()) {
      if (ph.storageKey == null) continue;
      records.add({
        'type': 'photo',
        'client_uuid': ph.id,
        'data': {
          'building': ph.buildingId,
          'unit_type': ph.unitTypeId,
          'storage_key': ph.storageKey,
          'confirmed': true,
        },
      });
    }

    return records;
  }

  /// Locally-stored amenities are a JSON flag map; the API expects the dict
  /// verbatim. A corrupt/empty value degrades to {} rather than failing sync.
  Map<String, dynamic> _decodeAmenities(String raw) {
    if (raw.isEmpty) return const {};
    try {
      return (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (_) {
      return const {};
    }
  }

  Future<void> _applyResults(List<SyncResult> results) async {
    // Fan the per-record result back out to whichever table owns the uuid.
    final byId = {for (final r in results) r.clientUuid: r};

    for (final b in await _db.pendingBuildings()) {
      final r = byId[b.id];
      if (r != null) {
        await _db.markBuildingSynced(
            b.id, r.ok ? SyncStatus.synced : SyncStatus.failed,
            error: r.error);
      }
    }
    for (final u in await _db.pendingUnitTypes()) {
      final r = byId[u.id];
      if (r != null) {
        await _db.markUnitTypeSynced(
            u.id, r.ok ? SyncStatus.synced : SyncStatus.failed,
            error: r.error);
      }
    }
    for (final s in await _db.pendingSnapshots()) {
      final r = byId[s.id];
      if (r != null) {
        await _db.markSnapshotSynced(
            s.id, r.ok ? SyncStatus.synced : SyncStatus.failed,
            error: r.error);
      }
    }
    for (final ph in await _db.pendingPhotos()) {
      final r = byId[ph.id];
      if (r != null) {
        await _db.markPhotoSynced(
            ph.id, r.ok ? SyncStatus.synced : SyncStatus.failed,
            error: r.error);
      }
    }
  }
}

enum SyncPhase { idle, syncing, offline }

enum SyncOutcome { success, failed, skipped, nothingToDo }
