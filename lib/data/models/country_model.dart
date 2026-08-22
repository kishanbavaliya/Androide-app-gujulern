/// Represents a selectable country. New countries can be added simply by
/// adding an entry to `assets/data/countries.json` -- no UI code changes
/// are required.
class CountryModel {
  final String code;
  final String name;
  final String flag;
  final List<String> languageCodes;

  const CountryModel({
    required this.code,
    required this.name,
    required this.flag,
    required this.languageCodes,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: json['code'] as String,
      name: json['name'] as String,
      flag: json['flag'] as String,
      languageCodes: List<String>.from(json['languageCodes'] as List),
    );
  }
}
