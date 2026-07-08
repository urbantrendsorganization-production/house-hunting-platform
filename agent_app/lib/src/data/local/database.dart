import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Per-record sync lifecycle. The whole app is offline-first: every capture is
/// born [pending] and only becomes [synced] once the API confirms it. [failed]
/// records carry an error and are retried on the next drain.
enum SyncStatus { pending, syncing, synced, failed }

/// Shared columns for every locally-captured, server-syncable record. `id` here
/// is the **client_uuid** — the idempotency key the API upserts on, so a record
/// keeps the same identity across retries (CLAUDE.md sync contract).
mixin _Syncable on Table {
  TextColumn get id => text()(); // client_uuid (also the server id for buildings)
  IntColumn get syncStatus =>
      intEnum<SyncStatus>().withDefault(const Constant(0))();
  TextColumn get syncError => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Buildings extends Table with _Syncable {
  TextColumn get estateSlug => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get gpsAccuracy => real().nullable()();
  IntColumn get floors => integer().nullable()();
  TextColumn get waterNotes => text().withDefault(const Constant(''))();
  TextColumn get powerNotes => text().withDefault(const Constant(''))();
  TextColumn get securityNotes => text().withDefault(const Constant(''))();
  BoolColumn get parking => boolean().withDefault(const Constant(false))();
  TextColumn get caretakerName => text().withDefault(const Constant(''))();
  TextColumn get caretakerPhone => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

class UnitTypes extends Table with _Syncable {
  TextColumn get buildingId => text()();
  TextColumn get kind => text()(); // BEDSITTER / 1BR / 2BR / ...
  IntColumn get rentKes => integer()();
  IntColumn get depositKes => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class VacancySnapshots extends Table with _Syncable {
  TextColumn get unitTypeId => text()();
  IntColumn get vacantCount => integer()();
  DateTimeColumn get verifiedAt => dateTime()();
  TextColumn get source =>
      text().withDefault(const Constant('AGENT_VISIT'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Photos extends Table with _Syncable {
  TextColumn get buildingId => text()();
  TextColumn get unitTypeId => text().nullable()();
  TextColumn get localPath => text()(); // compressed file on disk
  TextColumn get storageKey => text().nullable()(); // set after presign+upload
  BoolColumn get uploaded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Buildings, UnitTypes, VacancySnapshots, Photos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // --- Reads ---

  /// Buildings newest-first for the "My buildings" list.
  Future<List<Building>> allBuildings() =>
      (select(buildings)..orderBy([(b) => OrderingTerm.desc(b.createdAt)])).get();

  Stream<List<Building>> watchBuildings() =>
      (select(buildings)..orderBy([(b) => OrderingTerm.desc(b.createdAt)]))
          .watch();

  Future<List<UnitType>> unitTypesFor(String buildingId) =>
      (select(unitTypes)..where((u) => u.buildingId.equals(buildingId))).get();

  Future<Building?> buildingById(String id) =>
      (select(buildings)..where((b) => b.id.equals(id))).getSingleOrNull();

  /// Count of buildings still needing a sync — drives the status badge. A
  /// building-level signal is enough for the headline; children ride with them.
  Stream<int> watchPendingCount() {
    return (select(buildings)
          ..where((b) => b.syncStatus.isIn(_unsyncedIndexes)))
        .watch()
        .map((rows) => rows.length);
  }

  // --- Writes ---

  Future<void> upsertBuilding(BuildingsCompanion b) =>
      into(buildings).insertOnConflictUpdate(b);

  Future<void> upsertUnitType(UnitTypesCompanion u) =>
      into(unitTypes).insertOnConflictUpdate(u);

  Future<void> upsertSnapshot(VacancySnapshotsCompanion s) =>
      into(vacancySnapshots).insertOnConflictUpdate(s);

  Future<void> upsertPhoto(PhotosCompanion ph) =>
      into(photos).insertOnConflictUpdate(ph);

  Future<void> markBuildingSynced(String id, SyncStatus status,
          {String? error}) =>
      (update(buildings)..where((b) => b.id.equals(id))).write(
        BuildingsCompanion(syncStatus: Value(status), syncError: Value(error)),
      );

  Future<void> markUnitTypeSynced(String id, SyncStatus status,
          {String? error}) =>
      (update(unitTypes)..where((u) => u.id.equals(id))).write(
        UnitTypesCompanion(syncStatus: Value(status), syncError: Value(error)),
      );

  Future<void> markSnapshotSynced(String id, SyncStatus status,
          {String? error}) =>
      (update(vacancySnapshots)..where((s) => s.id.equals(id))).write(
        VacancySnapshotsCompanion(
            syncStatus: Value(status), syncError: Value(error)),
      );

  Future<void> markPhotoSynced(String id, SyncStatus status, {String? error}) =>
      (update(photos)..where((ph) => ph.id.equals(id))).write(
        PhotosCompanion(syncStatus: Value(status), syncError: Value(error)),
      );

  /// Correct a failed building's estate and re-queue it for sync. Used when the
  /// server rejected the original estate slug (it didn't exist there).
  Future<void> retryBuildingWithEstate(String id, String estateSlug) =>
      (update(buildings)..where((b) => b.id.equals(id))).write(
        BuildingsCompanion(
          estateSlug: Value(estateSlug),
          syncStatus: const Value(SyncStatus.pending),
          syncError: const Value(null),
        ),
      );

  Future<void> setPhotoUploaded(String id, String storageKey) =>
      (update(photos)..where((ph) => ph.id.equals(id))).write(
        PhotosCompanion(storageKey: Value(storageKey), uploaded: const Value(true)),
      );

  // pending(0) or failed(3) — everything not yet syncing/synced. The drain
  // retries failures, so they belong in the same batch as fresh captures.
  static const List<int> _unsyncedIndexes = [0, 3];

  Future<List<Building>> pendingBuildings() =>
      (select(buildings)..where((b) => b.syncStatus.isIn(_unsyncedIndexes)))
          .get();

  Future<List<UnitType>> pendingUnitTypes() =>
      (select(unitTypes)..where((u) => u.syncStatus.isIn(_unsyncedIndexes)))
          .get();

  Future<List<VacancySnapshot>> pendingSnapshots() =>
      (select(vacancySnapshots)
            ..where((s) => s.syncStatus.isIn(_unsyncedIndexes)))
          .get();

  Future<List<Photo>> pendingPhotos() =>
      (select(photos)..where((ph) => ph.syncStatus.isIn(_unsyncedIndexes)))
          .get();
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'keja_agent.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
