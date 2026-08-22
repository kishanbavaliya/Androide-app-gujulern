import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/app_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/local/local_storage_service.dart';
import 'data/repositories/content_repository.dart';
import 'services/tts_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Everything below is built once, locally, before the UI is shown --
  // there is no network call anywhere in this startup path.
  final storage = await LocalStorageService.create();
  final contentRepository = ContentRepository();
  final tts = TextToSpeechService();

  runApp(GujjuLearnApp(
    storage: storage,
    contentRepository: contentRepository,
    tts: tts,
  ));
}

class GujjuLearnApp extends StatelessWidget {
  final LocalStorageService storage;
  final ContentRepository contentRepository;
  final TextToSpeechService tts;

  const GujjuLearnApp({
    super.key,
    required this.storage,
    required this.contentRepository,
    required this.tts,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(
        contentRepository: contentRepository,
        storage: storage,
        tts: tts,
      ),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
