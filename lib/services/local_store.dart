import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class LocalStore {
  static const _key = 'watchman.snapshot.v1';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<AppSnapshot?> load() async {
    final raw = _prefs?.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AppSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(AppSnapshot snapshot) async {
    await _prefs?.setString(_key, jsonEncode(snapshot.toJson()));
  }

  Future<void> wipe() async {
    await _prefs?.remove(_key);
  }
}
