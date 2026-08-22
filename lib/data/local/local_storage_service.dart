import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress_model.dart';

/// Thin wrapper around SharedPreferences. This is the ONLY place in the
/// app that talks to on-device storage, so swapping to another lightweight
/// storage solution later only means editing this one file.
class LocalStorageService {
  static const _progressKey = 'user_progress_v1';
  static const _soundEnabledKey = 'sound_enabled';
  static const _speechRateKey = 'speech_rate';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  UserProgress loadProgress() {
    final raw = _prefs.getString(_progressKey);
    if (raw == null) return UserProgress();
    try {
      return UserProgress.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupt data should never crash the app -- start fresh instead.
      return UserProgress();
    }
  }

  Future<void> saveProgress(UserProgress progress) async {
    await _prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  Future<void> resetProgress() async {
    await _prefs.remove(_progressKey);
  }

  bool get soundEnabled => _prefs.getBool(_soundEnabledKey) ?? true;

  Future<void> setSoundEnabled(bool value) =>
      _prefs.setBool(_soundEnabledKey, value);

  double get speechRate => _prefs.getDouble(_speechRateKey) ?? 0.5;

  Future<void> setSpeechRate(double value) =>
      _prefs.setDouble(_speechRateKey, value);
}
