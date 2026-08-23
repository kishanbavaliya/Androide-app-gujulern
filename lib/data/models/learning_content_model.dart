/// A single learnable item: a letter/character paired with an example word.
class LearningItem {
  final String id;
  final String character;
  final String word;
  final String translation;
  final String image;

  /// Emoji used as the animated fallback visual when [image] is empty or
  /// missing on disk (see [AnimatedLearningVisual]). Falls back to
  /// [character] itself when also empty (e.g. colors/animals already use
  /// an emoji as their character).
  final String emoji;

  const LearningItem({
    required this.id,
    required this.character,
    required this.word,
    required this.translation,
    required this.image,
    this.emoji = '',
  });

  factory LearningItem.fromJson(Map<String, dynamic> json) {
    return LearningItem(
      id: json['id'] as String,
      character: json['character'] as String,
      word: json['word'] as String,
      translation: json['translation'] as String,
      image: json['image'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
    );
  }

  /// The best available emoji/glyph to animate for this item.
  String get displayEmoji => emoji.isNotEmpty ? emoji : character;
}

/// A category of items, e.g. "Alphabet", "Numbers", "Colors", "Animals".
class LearningCategory {
  final String id;
  final String title;
  final String icon;
  final List<LearningItem> items;

  const LearningCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.items,
  });

  factory LearningCategory.fromJson(Map<String, dynamic> json) {
    return LearningCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String? ?? 'school',
      items: (json['items'] as List)
          .map((e) => LearningItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// The full lesson content for one learning language.
class LanguageContent {
  final String language;
  final String code;
  final String locale;
  final List<LearningCategory> categories;

  const LanguageContent({
    required this.language,
    required this.code,
    required this.locale,
    required this.categories,
  });

  factory LanguageContent.fromJson(Map<String, dynamic> json) {
    return LanguageContent(
      language: json['language'] as String,
      code: json['code'] as String,
      locale: json['locale'] as String,
      categories: (json['categories'] as List)
          .map((e) => LearningCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get totalItems => categories.fold(0, (sum, c) => sum + c.items.length);
}
