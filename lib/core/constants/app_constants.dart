/// App-wide constant values that aren't learning content or theming.
class AppConstants {
  AppConstants._();

  static const String appName = 'Gujju Learn';
  static const String tagline = 'Learn Languages Easily';

  static const List<String> uiLanguageCodes = ['en', 'gu', 'hi', 'sa'];

  /// Simple XP economy -- intentionally not overcomplicated.
  static const int xpPerWordCompleted = 5;
  static const int xpPerCategoryCompleted = 25;
  static const int xpPerCorrectAnswer = 10;

  static const int dailyGoalXp = 50;
}

/// Static badge definitions. Badges unlock purely from locally tracked
/// progress -- no server involved.
class BadgeDef {
  final String id;
  final String title;
  final String emoji;
  final bool Function(int completedWords, int completedCategories,
      int streak, int xp) isUnlocked;

  const BadgeDef({
    required this.id,
    required this.title,
    required this.emoji,
    required this.isUnlocked,
  });
}

final List<BadgeDef> kBadges = [
  BadgeDef(
    id: 'first_steps',
    title: 'First Steps',
    emoji: '🐣',
    isUnlocked: (words, cats, streak, xp) => words >= 1,
  ),
  BadgeDef(
    id: 'alphabet_beginner',
    title: 'Alphabet Beginner',
    emoji: '🏆',
    isUnlocked: (words, cats, streak, xp) => cats >= 1,
  ),
  BadgeDef(
    id: 'word_explorer',
    title: 'Word Explorer',
    emoji: '📖',
    isUnlocked: (words, cats, streak, xp) => words >= 20,
  ),
  BadgeDef(
    id: 'streak_3',
    title: '3 Day Streak',
    emoji: '🔥',
    isUnlocked: (words, cats, streak, xp) => streak >= 3,
  ),
  BadgeDef(
    id: 'streak_7',
    title: '7 Day Streak',
    emoji: '🔥',
    isUnlocked: (words, cats, streak, xp) => streak >= 7,
  ),
  BadgeDef(
    id: 'xp_100',
    title: 'Century XP',
    emoji: '⭐',
    isUnlocked: (words, cats, streak, xp) => xp >= 100,
  ),
];
