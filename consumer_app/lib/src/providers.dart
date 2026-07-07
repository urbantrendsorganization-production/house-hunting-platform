import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/api_client.dart';
import 'data/location_service.dart';
import 'data/models.dart';
import 'data/places_service.dart';

final apiClientProvider = Provider<ApiClient>((_) => ApiClient());
final locationServiceProvider = Provider<LocationService>((_) => LocationService());
final placesServiceProvider = Provider<PlacesService>((_) => PlacesService());

/// Consumer-side freshness/quality filters. Price + unit-type filtering needs a
/// denormalized min_rent / unit_kinds on Building to be added to the viewport
/// API (a Phase 4.1 follow-up); until then we filter on what the marker payload
/// actually carries: verification age and the demoted flag.
class MapFilters {
  const MapFilters({this.maxVerifiedDays, this.hideDemoted = false});

  /// Only show listings verified within this many days (null = no limit).
  final int? maxVerifiedDays;

  /// Drop listings the server flagged as demoted (stale-but-visible).
  final bool hideDemoted;

  bool allows(BuildingMarker m) {
    if (hideDemoted && m.isDemoted) return false;
    if (maxVerifiedDays != null) {
      final age = m.verifiedDaysAgo;
      if (age == null || age > maxVerifiedDays!) return false;
    }
    return true;
  }

  bool get isActive => maxVerifiedDays != null || hideDemoted;

  MapFilters copyWith({int? maxVerifiedDays, bool? hideDemoted, bool clearDays = false}) {
    return MapFilters(
      maxVerifiedDays: clearDays ? null : (maxVerifiedDays ?? this.maxVerifiedDays),
      hideDemoted: hideDemoted ?? this.hideDemoted,
    );
  }
}

class MapFiltersNotifier extends StateNotifier<MapFilters> {
  MapFiltersNotifier() : super(const MapFilters());

  void setMaxDays(int? days) =>
      state = state.copyWith(maxVerifiedDays: days, clearDays: days == null);
  void toggleHideDemoted() =>
      state = state.copyWith(hideDemoted: !state.hideDemoted);
}

final mapFiltersProvider =
    StateNotifierProvider<MapFiltersNotifier, MapFilters>(
        (_) => MapFiltersNotifier());
