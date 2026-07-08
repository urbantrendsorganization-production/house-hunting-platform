import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api/api_client.dart';

/// Supplies the set of valid estate slugs for the capture form. Capture happens
/// in the field, often offline, so this is offline-first: the last list fetched
/// while online is cached locally and served instantly. A free-typed estate slug
/// (e.g. "pipeline") is how a building silently failed every sync — pinning to a
/// known-good slug removes that whole class of bug.
class EstateRepository {
  EstateRepository(this._api, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final ApiClient _api;
  final FlutterSecureStorage _storage;

  static const _kCache = 'estates_cache';

  /// Cached estates, or an empty list if we've never been online. Never throws —
  /// a corrupt cache degrades to "no options" (the form falls back to free text).
  Future<List<EstateOption>> cached() async {
    final raw = await _storage.read(key: _kCache);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(EstateOption.fromJson).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Fetch the live list and refresh the cache. Falls back to the cached copy on
  /// any network error, so an offline agent still gets the last-known estates.
  Future<List<EstateOption>> refresh() async {
    try {
      final estates = await _api.estates();
      await _storage.write(
        key: _kCache,
        value: jsonEncode(estates.map((e) => e.toJson()).toList()),
      );
      return estates;
    } catch (_) {
      return cached();
    }
  }
}
