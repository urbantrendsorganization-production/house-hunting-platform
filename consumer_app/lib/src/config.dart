/// Compile-time config. Point at any environment with:
///   flutter run --dart-define=API_BASE_URL=https://api.keja.example \
///               --dart-define=MAPS_WEB_KEY=AIza...
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
  static const String apiPrefix = '/api/v1';

  /// Optional key for the Places Autocomplete REST call (search box). The map
  /// tiles use the native SDK key from the Android manifest, not this one.
  static const String placesApiKey =
      String.fromEnvironment('PLACES_API_KEY', defaultValue: '');

  static bool get placesEnabled => placesApiKey.isNotEmpty;

  /// Nairobi CBD — a sensible default camera before we have the user's fix.
  static const double defaultLat = -1.2864;
  static const double defaultLng = 36.8172;

  /// Below this zoom the server sends clusters, above it raw markers — mirrors
  /// MAP_CLUSTER_ZOOM_THRESHOLD in the API.
  static const double clusterZoomThreshold = 15;

  /// Debounce map-idle refetches so a pan doesn't spam the viewport endpoint
  /// (CLAUDE.md: never call on every pan).
  static const Duration viewportDebounce = Duration(milliseconds: 350);
}
