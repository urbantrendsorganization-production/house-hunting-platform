import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../config.dart';

/// Google Places Autocomplete for the search box, following the cost discipline
/// in CLAUDE.md: session tokens (one per keystroke-burst, reused until a place
/// is picked), `components=country:ke`, and callers must debounce. Disabled
/// entirely when no key is configured.
class PlacesService {
  PlacesService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  String _sessionToken = const Uuid().v4();

  bool get enabled => AppConfig.placesEnabled;

  Future<List<PlacePrediction>> autocomplete(String input) async {
    if (!enabled || input.trim().isEmpty) return const [];
    final res = await _dio.get(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      queryParameters: {
        'input': input,
        'key': AppConfig.placesApiKey,
        'sessiontoken': _sessionToken,
        'components': 'country:ke', // Kenya only
      },
    );
    final preds = (res.data['predictions'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    return preds
        .map((p) => PlacePrediction(
              placeId: p['place_id'] as String,
              description: p['description'] as String,
            ))
        .toList();
  }

  /// Resolve a prediction to coordinates. Picking a place *ends* the session, so
  /// we rotate the token afterwards (the next search bills as a new session).
  Future<({double lat, double lng})?> resolve(String placeId) async {
    if (!enabled) return null;
    final res = await _dio.get(
      'https://maps.googleapis.com/maps/api/place/details/json',
      queryParameters: {
        'place_id': placeId,
        'key': AppConfig.placesApiKey,
        'sessiontoken': _sessionToken,
        'fields': 'geometry',
      },
    );
    _sessionToken = const Uuid().v4();
    final loc = res.data['result']?['geometry']?['location'];
    if (loc == null) return null;
    return (lat: (loc['lat'] as num).toDouble(), lng: (loc['lng'] as num).toDouble());
  }
}

class PlacePrediction {
  PlacePrediction({required this.placeId, required this.description});
  final String placeId;
  final String description;
}
