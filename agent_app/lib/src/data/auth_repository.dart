import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import 'api/api_client.dart';

/// Owns the device identity and the agent JWT. The device is the credential
/// (CLAUDE.md): a single stable `device_id` is generated once and reused, so the
/// server's device-binding check stays consistent across app restarts.
class AuthRepository {
  AuthRepository(this._api, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final ApiClient _api;
  final FlutterSecureStorage _storage;

  static const _kToken = 'agent_token';
  static const _kDeviceId = 'device_id';
  static const _kAgentName = 'agent_name';

  Future<String> deviceId() async {
    var id = await _storage.read(key: _kDeviceId);
    if (id == null) {
      id = const Uuid().v4();
      await _storage.write(key: _kDeviceId, value: id);
    }
    return id;
  }

  /// Restores a saved session into the API client on cold start.
  Future<String?> restore() async {
    final token = await _storage.read(key: _kToken);
    _api.token = token;
    return token;
  }

  Future<String?> agentName() => _storage.read(key: _kAgentName);

  Future<AgentSession> login(String phone) async {
    final device = await deviceId();
    final session = await _api.login(phone: phone, deviceId: device);
    _api.token = session.token;
    await _storage.write(key: _kToken, value: session.token);
    await _storage.write(key: _kAgentName, value: session.agentName);
    return session;
  }

  Future<void> logout() async {
    _api.token = null;
    await _storage.delete(key: _kToken);
    // Deliberately keep device_id — the binding survives a re-login.
  }
}
