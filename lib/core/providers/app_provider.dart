import 'package:flutter/foundation.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/country_model.dart';
import '../../data/models/language_model.dart';
import '../../data/models/learning_content_model.dart';
import '../../data/models/progress_model.dart';
import '../../data/repositories/content_repository.dart';
import '../../services/tts_service.dart';
import '../constants/app_constants.dart';

/// Single source of truth for app state: user selections, progress,
/// gamification and access to local content/services. Kept intentionally
/// simple (one ChangeNotifier) since the app's state needs are modest.
class AppProvider extends ChangeNotifier {
  final ContentRepository contentRepository;
  final LocalStorageService storage;
  final TextToSpeechService tts;

  AppProvider({
    required this.contentRepository,
    required this.storage,
    required this.tts,
  });

  late UserProgress progress = storage.loadProgress();

  List<CountryModel> countries = [];
  List<LanguageModel> allLanguages = [];
  LanguageContent? currentLearningContent;

  bool isLoading = true;
  bool soundEnabled = true;
  double speechRate = 0.5;

  CountryModel? get selectedCountry {
    if (progress.countryCode == null) return null;
    try {
      return countries.firstWhere((c) => c.code == progress.countryCode);
    } catch (_) {
      return null;
    }
  }

  LanguageModel? get appLanguage => _findLanguage(progress.appLanguageCode);
  LanguageModel? get learningLanguage =>
      _findLanguage(progress.learningLanguageCode);

  LanguageModel? _findLanguage(String? code) {
    if (code == null) return null;
    try {
      return allLanguages.firstWhere((l) => l.code == code);
    } catch (_) {
      return null;
    }
  }

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    await tts.init();
    soundEnabled = storage.soundEnabled;
    speechRate = storage.speechRate;
    await tts.setSpeechRate(speechRate);

    countries = await contentRepository.getCountries();
    allLanguages = await contentRepository.getAllLanguages();

    if (learningLanguage != null) {
      currentLearningContent =
          await contentRepository.getContentForLanguage(learningLanguage!);
    }

    _registerAppOpenForStreak();

    isLoading = false;
    notifyListeners();
  }

  Future<void> selectCountry(CountryModel country) async {
    progress.countryCode = country.code;
    await _persist();
  }

  Future<void> selectAppLanguage(LanguageModel language) async {
    progress.appLanguageCode = language.code;
    await _persist();
  }

  Future<void> selectLearningLanguage(LanguageModel language) async {
    progress.learningLanguageCode = language.code;
    currentLearningContent =
        await contentRepository.getContentForLanguage(language);
    await _persist();
  }

  Future<void> completeOnboarding() async {
    progress.onboardingComplete = true;
    await _persist();
  }

  List<String> get completedBadgeTitles => kBadges
      .where((b) => progress.unlockedBadgeIds.contains(b.id))
      .map((b) => b.title)
      .toList();

  void _checkBadges() {
    for (final badge in kBadges) {
      if (progress.unlockedBadgeIds.contains(badge.id)) continue;
      final unlocked = badge.isUnlocked(
        progress.completedItemIds.length,
        progress.completedCategoryIds.length,
        progress.currentStreak,
        progress.xp,
      );
      if (unlocked) {
        progress.unlockedBadgeIds.add(badge.id);
      }
    }
  }

  Future<void> markItemCompleted(LearningItem item, LearningCategory category) async {
    final isNew = progress.completedItemIds.add(item.id);
    if (isNew) {
      progress.xp += AppConstants.xpPerWordCompleted;
    }

    final allDone = category.items.every(
      (i) => progress.completedItemIds.contains(i.id),
    );
    if (allDone && progress.completedCategoryIds.add(category.id)) {
      progress.xp += AppConstants.xpPerCategoryCompleted;
    }

    _checkBadges();
    await _persist();
  }

  Future<void> recordQuizAnswer(bool correct) async {
    progress.quizzesTaken += 1;
    if (correct) {
      progress.quizzesCorrect += 1;
      progress.xp += AppConstants.xpPerCorrectAnswer;
    }
    _checkBadges();
    await _persist();
  }

  void _registerAppOpenForStreak() {
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (progress.lastActiveDate == todayKey) return;

    if (progress.lastActiveDate != null) {
      final last = DateTime.tryParse(progress.lastActiveDate!);
      if (last != null) {
        final diff = DateTime(today.year, today.month, today.day)
            .difference(DateTime(last.year, last.month, last.day))
            .inDays;
        if (diff == 1) {
          progress.currentStreak += 1;
        } else if (diff > 1) {
          progress.currentStreak = 1;
        }
      } else {
        progress.currentStreak = 1;
      }
    } else {
      progress.currentStreak = 1;
    }
    progress.lastActiveDate = todayKey;
    _checkBadges();
    _persist();
  }

  Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    await storage.setSoundEnabled(value);
    notifyListeners();
  }

  Future<void> setSpeechRate(double value) async {
    speechRate = value;
    await storage.setSpeechRate(value);
    await tts.setSpeechRate(value);
    notifyListeners();
  }

  Future<void> resetProgress() async {
    final country = progress.countryCode;
    final appLang = progress.appLanguageCode;
    final learnLang = progress.learningLanguageCode;
    progress = UserProgress(
      countryCode: country,
      appLanguageCode: appLang,
      learningLanguageCode: learnLang,
      onboardingComplete: true,
    );
    await _persist();
  }

  Future<void> _persist() async {
    await storage.saveProgress(progress);
    notifyListeners();
  }
}
