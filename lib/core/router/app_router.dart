import 'package:flutter/material.dart';
import '../../data/models/learning_content_model.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/country_selection_screen.dart';
import '../../features/onboarding/app_language_selection_screen.dart';
import '../../features/onboarding/learning_language_selection_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/learning/lesson_screen.dart';
import '../../features/learning/word_detail_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const country = '/country';
  static const appLanguage = '/app-language';
  static const learningLanguage = '/learning-language';
  static const welcome = '/welcome';
  static const home = '/home';
  static const lesson = '/lesson';
  static const wordDetail = '/word-detail';
}

/// Arguments passed when opening a lesson (a single category's boxes).
class LessonArgs {
  final LearningCategory category;
  const LessonArgs(this.category);
}

/// Arguments passed when opening a word/letter detail screen.
class WordDetailArgs {
  final LearningCategory category;
  final int initialIndex;
  const WordDetailArgs(this.category, this.initialIndex);
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(const SplashScreen(), settings);
      case AppRoutes.country:
        return _page(const CountrySelectionScreen(), settings);
      case AppRoutes.appLanguage:
        return _page(const AppLanguageSelectionScreen(), settings);
      case AppRoutes.learningLanguage:
        return _page(const LearningLanguageSelectionScreen(), settings);
      case AppRoutes.welcome:
        return _page(const WelcomeScreen(), settings);
      case AppRoutes.home:
        return _page(const HomeShell(), settings);
      case AppRoutes.lesson:
        final args = settings.arguments as LessonArgs;
        return _page(LessonScreen(category: args.category), settings);
      case AppRoutes.wordDetail:
        final args = settings.arguments as WordDetailArgs;
        return _page(
          WordDetailScreen(
              category: args.category, initialIndex: args.initialIndex),
          settings,
        );
      default:
        return _page(
          Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static PageRoute _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
