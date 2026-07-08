import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../config.dart';

/// Thin wrapper over the agent API. Speaks exactly the contract in
/// `api/core/agent_views.py` + `services/sync.py`. Holds the bearer token in
/// memory; persistence is the auth repository's job.
class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: '${AppConfig.apiBaseUrl}${AppConfig.apiPrefix}',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
            ));

  final Dio _dio;
  String? _token;

  set token(String? value) {
    _token = value;
  }

  Options get _auth => Options(
        headers: _token == null ? null : {'Authorization': 'Bearer $_token'},
      );

  /// POST /agent/login/ — binds the device on first use, returns a 30-day JWT.
  Future<AgentSession> login({
    required String phone,
    required String deviceId,
  }) async {
    final res = await _dio.post('/agent/login/', data: {
      'phone': phone,
      'device_id': deviceId,
    });
    final data = res.data as Map<String, dynamic>;
    return AgentSession(
      token: data['token'] as String,
      agentId: (data['agent'] as Map)['id'] as int,
      agentName: (data['agent'] as Map)['name'] as String,
    );
  }

  /// POST /agent/sync/ — idempotent batch upsert. Returns per-record results
  /// keyed by client_uuid the caller uses to mark records synced/failed.
  Future<List<SyncResult>> sync(List<Map<String, dynamic>> records) async {
    final res = await _dio.post('/agent/sync/',
        data: {'records': records}, options: _auth);
    final results = (res.data['results'] as List).cast<Map<String, dynamic>>();
    return results.map(SyncResult.fromJson).toList();
  }

  /// GET /estates/ — anonymous-readable. The capture form pins a building to an
  /// estate *slug that must already exist on the server*; a free-typed slug is
  /// how "pipeline" got captured and then failed every sync. Fetched when online
  /// and cached locally so field capture stays offline-first.
  Future<List<EstateOption>> estates() async {
    final res = await _dio.get('/estates/');
    final results = (res.data['results'] as List).cast<Map<String, dynamic>>();
    return results.map(EstateOption.fromJson).toList();
  }

  /// POST /agent/photos/presign/ — get a presigned PUT URL + storage key.
  Future<PresignedUpload> presignPhoto({
    required String buildingId,
    String contentType = 'image/jpeg',
  }) async {
    final res = await _dio.post('/agent/photos/presign/',
        data: {'building': buildingId, 'content_type': contentType},
        options: _auth);
    final data = res.data as Map<String, dynamic>;
    return PresignedUpload(
      uploadUrl: data['upload_url'] as String,
      storageKey: data['storage_key'] as String,
    );
  }

  /// Direct PUT of the image bytes to object storage. The API never sees bytes.
  Future<void> uploadBytes({
    required String uploadUrl,
    required File file,
    String contentType = 'image/jpeg',
  }) async {
    final Uint8List bytes = await file.readAsBytes();
    // A bare Dio (no baseUrl/auth) — the presigned URL is fully self-contained.
    await Dio().put(
      uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          Headers.contentTypeHeader: contentType,
          Headers.contentLengthHeader: bytes.length,
        },
      ),
    );
  }
}

class AgentSession {
  AgentSession({
    required this.token,
    required this.agentId,
    required this.agentName,
  });
  final String token;
  final int agentId;
  final String agentName;
}

class SyncResult {
  SyncResult({required this.clientUuid, required this.status, this.error});
  final String clientUuid;
  final String status; // "synced" | "failed"
  final String? error;

  bool get ok => status == 'synced';

  factory SyncResult.fromJson(Map<String, dynamic> j) => SyncResult(
        clientUuid: j['client_uuid'] as String,
        status: j['status'] as String,
        error: j['error'] as String?,
      );
}

class EstateOption {
  EstateOption({required this.slug, required this.name});
  final String slug;
  final String name;

  factory EstateOption.fromJson(Map<String, dynamic> j) => EstateOption(
        slug: j['slug'] as String,
        name: j['name'] as String,
      );

  Map<String, dynamic> toJson() => {'slug': slug, 'name': name};
}

class PresignedUpload {
  PresignedUpload({required this.uploadUrl, required this.storageKey});
  final String uploadUrl;
  final String storageKey;
}
