/// Represents a language that can be used either as the app's UI language
/// or as a language the user wants to learn. Adding a new language only
/// requires a new entry in `assets/data/languages.json` (and a matching
/// content JSON file once lessons are authored for it).
class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String locale; // BCP-47 locale used for Text-to-Speech
  final String flag;
  final String contentFile;
  final bool hasContent;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.locale,
    required this.flag,
    required this.contentFile,
    required this.hasContent,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
      locale: json['locale'] as String,
      flag: json['flag'] as String,
      contentFile: json['contentFile'] as String? ?? '',
      hasContent: json['hasContent'] as bool? ?? false,
    );
  }
}
