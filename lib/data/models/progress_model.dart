/// Tracks everything about the user's setup and learning progress.
/// Persisted locally via [LocalStorageService] -- nothing is sent
/// anywhere.
class UserProgress {
  String? countryCode;
  String? appLanguageCode; // UI language
  String? learningLanguageCode; // language being learned
  bool onboardingComplete;

  /// itemId -> true once the user has viewed/completed that word.
  final Set<String> completedItemIds;

  /// categoryId -> true once every item in the category is completed.
  final Set<String> completedCategoryIds;

  int xp;
  int currentStreak;
  String? lastActiveDate; // yyyy-MM-dd, used to compute streaks
  int quizzesTaken;
  int quizzesCorrect;
  final Set<String> unlockedBadgeIds;

  UserProgress({
    this.countryCode,
    this.appLanguageCode,
    this.learningLanguageCode,
    this.onboardingComplete = false,
    Set<String>? completedItemIds,
    Set<String>? completedCategoryIds,
    this.xp = 0,
    this.currentStreak = 0,
    this.lastActiveDate,
    this.quizzesTaken = 0,
    this.quizzesCorrect = 0,
    Set<String>? unlockedBadgeIds,
  })  : completedItemIds = completedItemIds ?? <String>{},
        completedCategoryIds = completedCategoryIds ?? <String>{},
        unlockedBadgeIds = unlockedBadgeIds ?? <String>{};

  Map<String, dynamic> toJson() => {
        'countryCode': countryCode,
        'appLanguageCode': appLanguageCode,
        'learningLanguageCode': learningLanguageCode,
        'onboardingComplete': onboardingComplete,
        'completedItemIds': completedItemIds.toList(),
        'completedCategoryIds': completedCategoryIds.toList(),
        'xp': xp,
        'currentStreak': currentStreak,
        'lastActiveDate': lastActiveDate,
        'quizzesTaken': quizzesTaken,
        'quizzesCorrect': quizzesCorrect,
        'unlockedBadgeIds': unlockedBadgeIds.toList(),
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      countryCode: json['countryCode'] as String?,
      appLanguageCode: json['appLanguageCode'] as String?,
      learningLanguageCode: json['learningLanguageCode'] as String?,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      completedItemIds:
          Set<String>.from(json['completedItemIds'] as List? ?? const []),
      completedCategoryIds: Set<String>.from(
          json['completedCategoryIds'] as List? ?? const []),
      xp: json['xp'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] as String?,
      quizzesTaken: json['quizzesTaken'] as int? ?? 0,
      quizzesCorrect: json['quizzesCorrect'] as int? ?? 0,
      unlockedBadgeIds:
          Set<String>.from(json['unlockedBadgeIds'] as List? ?? const []),
    );
  }

  double completionRatio(int totalItems) {
    if (totalItems == 0) return 0;
    return (completedItemIds.length / totalItems).clamp(0, 1).toDouble();
  }
}
