/// App-wide configuration. The API base URL is compile-time injectable so the
/// same build can point at local / staging / prod:
///
///   flutter run --dart-define=API_BASE_URL=https://api.keja.example
class AppConfig {
  /// Default targets the Android emulator's host loopback (10.0.2.2 -> host
  /// 127.0.0.1) where the Django dev server runs on :8000.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const String apiPrefix = '/api/v1';

  /// A GPS pin is only trustworthy at the gate — reject saves above this.
  static const double maxGpsAccuracyMeters = 15.0;

  /// Photos are compressed to this long-edge before queueing (CLAUDE.md).
  static const int photoMaxLongEdge = 1600;
  static const int photoQuality = 80;
}
