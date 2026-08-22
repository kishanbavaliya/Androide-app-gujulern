import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/router/app_router.dart';
import '../../data/models/language_model.dart';
import '../../shared/widgets/language_card.dart';

/// Lets the user pick the language the APP INTERFACE will be shown in.
/// This is intentionally a separate concept from the language they want
/// to learn (chosen on the next screen).
class AppLanguageSelectionScreen extends StatelessWidget {
  const AppLanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('App language')),
      body: FutureBuilder<List<LanguageModel>>(
        future: app.contentRepository.getAppUiLanguages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final languages = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What language should the app use?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Menus and buttons will use this language.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: languages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final lang = languages[index];
                      final selected =
                          app.progress.appLanguageCode == lang.code;
                      return LanguageCard(
                        language: lang,
                        selected: selected,
                        onTap: () async {
                          await app.selectAppLanguage(lang);
                          if (!context.mounted) return;
                          Navigator.of(context)
                              .pushNamed(AppRoutes.learningLanguage);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
