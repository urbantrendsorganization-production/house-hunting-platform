import 'dart:convert';

import 'package:agent_app/src/data/capture_repository.dart';
import 'package:agent_app/src/data/local/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 2 correctness: capture writes to the local db first (offline-first),
/// and pending-record queries return exactly the un-synced work the sync worker
/// batches. These run on a pure in-memory Drift db — no device, no network.
void main() {
  late AppDatabase db;
  late CaptureRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CaptureRepository(db);
  });

  tearDown(() => db.close());

  test('a full capture is queued as pending, in dependency order', () async {
    final buildingId = await repo.saveBuilding(
      estateSlug: 'roysambu',
      name: 'Green Court',
      lat: -1.2185,
      lng: 36.8964,
      gpsAccuracy: 8.0,
    );
    final unitId = await repo.saveUnitType(
      buildingId: buildingId,
      kind: '1BR',
      rentKes: 15000,
    );
    await repo.addVacancy(unitTypeId: unitId, vacantCount: 2);
    await repo.addPhoto(buildingId: buildingId, localPath: '/tmp/x.jpg');

    // Everything is pending until the API confirms it.
    expect((await db.pendingBuildings()).single.id, buildingId);
    expect((await db.pendingUnitTypes()).single.buildingId, buildingId);
    expect((await db.pendingSnapshots()).single.unitTypeId, unitId);
    expect((await db.pendingPhotos()).single.buildingId, buildingId);
  });

  test('unit amenities persist as the flag map the API expects', () async {
    final b = await repo.saveBuilding(
        estateSlug: 'roysambu', name: '', lat: -1.2, lng: 36.9, gpsAccuracy: 5);
    await repo.saveUnitType(
      buildingId: b,
      kind: '1BR',
      rentKes: 15000,
      amenities: {'wifi', 'hot_shower'},
    );

    final unit = (await db.pendingUnitTypes()).single;
    // Stored shape must be a JSON dict of selected flags → true (JSONB on the
    // server, Record<string, unknown> on the consumer surfaces).
    expect(jsonDecode(unit.amenities), {'wifi': true, 'hot_shower': true});

    // A unit with no amenities selected stays an empty dict, never null.
    final u2 =
        await repo.saveUnitType(buildingId: b, kind: 'BEDSITTER', rentKes: 8000);
    final bare =
        (await db.pendingUnitTypes()).firstWhere((u) => u.id == u2);
    expect(jsonDecode(bare.amenities), isEmpty);
  });

  test('re-verify appends a NEW snapshot without touching the old one',
      () async {
    final b = await repo.saveBuilding(
        estateSlug: 'roysambu', name: '', lat: -1.2, lng: 36.9, gpsAccuracy: 5);
    final u =
        await repo.saveUnitType(buildingId: b, kind: 'BEDSITTER', rentKes: 8000);

    await repo.addVacancy(unitTypeId: u, vacantCount: 3);
    await repo.addVacancy(unitTypeId: u, vacantCount: 1);

    final snaps = await db.pendingSnapshots();
    expect(snaps.length, 2, reason: 'append-only: both snapshots retained');
    expect(snaps.map((s) => s.vacantCount).toSet(), {3, 1});
  });

  test('synced records drop out of the pending set', () async {
    final b = await repo.saveBuilding(
        estateSlug: 'roysambu', name: '', lat: -1.2, lng: 36.9, gpsAccuracy: 5);
    expect(await db.pendingBuildings(), hasLength(1));

    await db.markBuildingSynced(b, SyncStatus.synced);
    expect(await db.pendingBuildings(), isEmpty);

    // A failed record stays in the queue for the next drain.
    final b2 = await repo.saveBuilding(
        estateSlug: 'roysambu', name: '', lat: -1.2, lng: 36.9, gpsAccuracy: 5);
    await db.markBuildingSynced(b2, SyncStatus.failed, error: 'boom');
    expect((await db.pendingBuildings()).single.id, b2);
  });
}
