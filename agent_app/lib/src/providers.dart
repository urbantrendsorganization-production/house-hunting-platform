import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/api/api_client.dart';
import 'data/auth_repository.dart';
import 'data/capture_repository.dart';
import 'data/estate_repository.dart';
import 'data/local/database.dart';
import 'data/location_service.dart';
import 'data/photo_service.dart';
import 'sync/sync_service.dart';

// --- Singletons ---

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => AuthRepository(ref.watch(apiClientProvider)));

final captureRepositoryProvider = Provider<CaptureRepository>(
    (ref) => CaptureRepository(ref.watch(databaseProvider)));

final estateRepositoryProvider = Provider<EstateRepository>(
    (ref) => EstateRepository(ref.watch(apiClientProvider)));

final locationServiceProvider = Provider<LocationService>((_) => LocationService());
final photoServiceProvider = Provider<PhotoService>((_) => PhotoService());

final syncServiceProvider = Provider<SyncService>((ref) {
  final svc = SyncService(
    ref.watch(databaseProvider),
    ref.watch(apiClientProvider),
  );
  svc.start();
  ref.onDispose(svc.dispose);
  return svc;
});

// --- Derived / reactive state ---

/// Restores a persisted session and reports whether we're logged in.
final sessionProvider = FutureProvider<String?>((ref) async {
  return ref.watch(authRepositoryProvider).restore();
});

/// Valid estate options for the capture form. Serves the local cache first (so
/// the form is usable offline) then refreshes from the API in the background.
final estateOptionsProvider = FutureProvider<List<EstateOption>>((ref) async {
  final repo = ref.watch(estateRepositoryProvider);
  final cached = await repo.cached();
  if (cached.isEmpty) return repo.refresh();
  // Warm cache: return it now, refresh for next time.
  unawaited(repo.refresh());
  return cached;
});

final buildingsProvider = StreamProvider((ref) =>
    ref.watch(captureRepositoryProvider).watchBuildings());

final pendingCountProvider = StreamProvider<int>((ref) =>
    ref.watch(captureRepositoryProvider).watchPending());

final syncPhaseProvider = StreamProvider<SyncPhase>((ref) =>
    ref.watch(syncServiceProvider).status);
