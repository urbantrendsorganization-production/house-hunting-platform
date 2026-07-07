import 'package:geolocator/geolocator.dart';

/// GPS capture with an accuracy gate. The agent physically stands at the gate;
/// we refuse to pin until the fix is good enough (CLAUDE.md: accuracy ≤ 15m).
class LocationService {
  /// A live stream of best-effort high-accuracy fixes for the capture screen to
  /// show the accuracy circle and enable/disable the save button.
  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    );
  }

  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  Future<Position?> currentFix() async {
    if (!await ensurePermission()) return null;
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );
  }
}
