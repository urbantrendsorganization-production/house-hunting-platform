import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'local/database.dart';

/// All capture writes go here first — the local Drift db is the source of truth
/// (CLAUDE.md: UI must never block on network). Every record gets a
/// client-generated uuid used as the API idempotency key.
class CaptureRepository {
  CaptureRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  Stream<List<Building>> watchBuildings() => _db.watchBuildings();
  Stream<int> watchPending() => _db.watchPendingCount();
  Future<List<UnitType>> unitTypesFor(String id) => _db.unitTypesFor(id);
  Future<Building?> buildingById(String id) => _db.buildingById(id);

  /// Re-point a rejected building at a valid estate and re-queue it for sync.
  Future<void> retryBuildingWithEstate(String id, String estateSlug) =>
      _db.retryBuildingWithEstate(id, estateSlug);

  /// Persist a captured building. Returns the client_uuid (= its server id).
  Future<String> saveBuilding({
    required String estateSlug,
    required String name,
    required double lat,
    required double lng,
    required double gpsAccuracy,
    int? floors,
    String waterNotes = '',
    String powerNotes = '',
    String securityNotes = '',
    bool parking = false,
    String caretakerName = '',
    String caretakerPhone = '',
  }) async {
    final id = _uuid.v4();
    await _db.upsertBuilding(BuildingsCompanion.insert(
      id: id,
      estateSlug: estateSlug,
      name: Value(name),
      lat: lat,
      lng: lng,
      gpsAccuracy: Value(gpsAccuracy),
      floors: Value(floors),
      waterNotes: Value(waterNotes),
      powerNotes: Value(powerNotes),
      securityNotes: Value(securityNotes),
      parking: Value(parking),
      caretakerName: Value(caretakerName),
      caretakerPhone: Value(caretakerPhone),
    ));
    return id;
  }

  Future<String> saveUnitType({
    required String buildingId,
    required String kind,
    required int rentKes,
    int? depositKes,
  }) async {
    final id = _uuid.v4();
    await _db.upsertUnitType(UnitTypesCompanion.insert(
      id: id,
      buildingId: buildingId,
      kind: kind,
      rentKes: rentKes,
      depositKes: Value(depositKes),
    ));
    return id;
  }

  /// Append a vacancy snapshot — the daily re-verify loop. Append-only, mirrors
  /// the server's VacancySnapshot discipline.
  Future<String> addVacancy({
    required String unitTypeId,
    required int vacantCount,
    DateTime? verifiedAt,
    String source = 'AGENT_VISIT',
  }) async {
    final id = _uuid.v4();
    await _db.upsertSnapshot(VacancySnapshotsCompanion.insert(
      id: id,
      unitTypeId: unitTypeId,
      vacantCount: vacantCount,
      verifiedAt: verifiedAt ?? DateTime.now(),
      source: Value(source),
    ));
    return id;
  }

  Future<String> addPhoto({
    required String buildingId,
    String? unitTypeId,
    required String localPath,
  }) async {
    final id = _uuid.v4();
    await _db.upsertPhoto(PhotosCompanion.insert(
      id: id,
      buildingId: buildingId,
      unitTypeId: Value(unitTypeId),
      localPath: localPath,
    ));
    return id;
  }
}
