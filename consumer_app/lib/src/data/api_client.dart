import 'package:dio/dio.dart';

import '../config.dart';
import 'models.dart';

/// Read-only consumer API client. All endpoints are anonymous — browsing needs
/// no account (CLAUDE.md). Matches `api/core/consumer_views.py`.
class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: '${AppConfig.apiBaseUrl}${AppConfig.apiPrefix}',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 12),
            ));

  final Dio _dio;

  /// GET /map/viewport/ — markers when zoomed in, clusters when out.
  Future<ViewportResult> viewport({
    required double w,
    required double s,
    required double e,
    required double n,
    required int zoom,
  }) async {
    final res = await _dio.get('/map/viewport/', queryParameters: {
      'w': w,
      's': s,
      'e': e,
      'n': n,
      'zoom': zoom,
    });
    return ViewportResult.fromJson(res.data as Map<String, dynamic>);
  }

  /// GET /map/near-me/ — distance-sorted active buildings.
  Future<List<BuildingMarker>> nearMe({
    required double lat,
    required double lng,
    double radiusKm = 2,
  }) async {
    final res = await _dio.get('/map/near-me/', queryParameters: {
      'lat': lat,
      'lng': lng,
      'radius_km': radiusKm,
    });
    return (res.data['results'] as List)
        .cast<Map<String, dynamic>>()
        .map(BuildingMarker.fromJson)
        .toList();
  }

  /// GET `/buildings/<id>/` — full detail. Hidden buildings 404 (returns null).
  Future<BuildingDetail?> buildingDetail(String id) async {
    try {
      final res = await _dio.get('/buildings/$id/');
      return BuildingDetail.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
