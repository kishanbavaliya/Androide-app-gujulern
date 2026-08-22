import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/country_model.dart';
import '../models/language_model.dart';
import '../models/learning_content_model.dart';

/// Loads every piece of learning content from local JSON assets. There is
/// no network call anywhere in this class -- the whole app works with the
/// device switched to airplane mode.
class ContentRepository {
  List<CountryModel>? _countriesCache;
  List<LanguageModel>? _languagesCache;
  final Map<String, LanguageContent> _contentCache = {};

  Future<List<CountryModel>> getCountries() async {
    if (_countriesCache != null) return _countriesCache!;
    final raw = await rootBundle.loadString('assets/data/countries.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _countriesCache = (json['countries'] as List)
        .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _countriesCache!;
  }

  Future<List<LanguageModel>> getAllLanguages() async {
    if (_languagesCache != null) return _languagesCache!;
    final raw = await rootBundle.loadString('assets/data/languages.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _languagesCache = (json['languages'] as List)
        .map((e) => LanguageModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _languagesCache!;
  }

  /// Languages available for a given country, in the order the country
  /// lists them.
  Future<List<LanguageModel>> getLanguagesForCountry(
      CountryModel country) async {
    final all = await getAllLanguages();
    final byCode = {for (final l in all) l.code: l};
    return country.languageCodes
        .map((code) => byCode[code])
        .whereType<LanguageModel>()
        .toList();
  }

  /// Every language usable as the app's UI language. Per the product
  /// requirement this is currently English, Gujarati and Hindi.
  Future<List<LanguageModel>> getAppUiLanguages() async {
    final all = await getAllLanguages();
    const uiCodes = ['en', 'gu', 'hi', 'sa'];
    return all.where((l) => uiCodes.contains(l.code)).toList();
  }

  /// Loads the full lesson content for one learning language. Returns
  /// null if no content file has been authored for it yet (e.g. a
  /// language that was added to languages.json but has no lessons yet).
  Future<LanguageContent?> getContentForLanguage(
      LanguageModel language) async {
    if (!language.hasContent || language.contentFile.isEmpty) return null;
    if (_contentCache.containsKey(language.code)) {
      return _contentCache[language.code];
    }
    try {
      final raw = await rootBundle.loadString(language.contentFile);
      final content =
          LanguageContent.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _contentCache[language.code] = content;
      return content;
    } catch (_) {
      return null;
    }
  }
}
