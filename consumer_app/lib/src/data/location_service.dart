import 'package:geolocator/geolocator.dart';

/// Fused high-accuracy location for the "Bolt moment" — open → see houses
/// around me. Falls back gracefully if permission is denied (the map just
/// starts at the default city camera).
class LocationService {
  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  Future<Position?> currentPosition() async {
    if (!await ensurePermission()) return null;
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          // Never block the "Bolt moment" forever: a cold GPS (common on
          // emulators / indoors) would otherwise hang this future. On timeout
          // we fall through to the last known fix, then the default camera.
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      return Geolocator.getLastKnownPosition();
    }
  }
}
