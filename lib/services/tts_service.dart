import 'package:flutter_tts/flutter_tts.dart';

/// Wraps `flutter_tts` behind a small, app-specific API. The learning
/// language's locale is passed in on every [speak] call so the correct
/// voice/pronunciation is always used automatically -- callers never need
/// to think about locales themselves.
class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  String? _lastSetLocale;

  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    await _tts.awaitSpeakCompletion(true);
    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((_) => _isSpeaking = false);
  }

  Future<void> setLanguage(String locale) async {
    if (_lastSetLocale == locale) return;
    await _tts.setLanguage(locale);
    _lastSetLocale = locale;
  }

  Future<void> setSpeechRate(double rate) async {
    // flutter_tts expects 0.0 - 1.0 on most platforms.
    await _tts.setSpeechRate(rate.clamp(0.1, 1.0));
  }

  /// Returns true if the given locale is available for the device's TTS
  /// engine. Callers should show a friendly message instead of crashing
  /// when this is false.
  Future<bool> isLanguageAvailable(String locale) async {
    try {
      final result = await _tts.isLanguageAvailable(locale);
      return result == true || result == 1;
    } catch (_) {
      return false;
    }
  }

  /// Speaks [text] in [locale], preventing overlapping speech by stopping
  /// anything currently playing first.
  Future<void> speak(String text, String locale) async {
    if (_isSpeaking) {
      await stop();
    }
    await setLanguage(locale);
    _isSpeaking = true;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
