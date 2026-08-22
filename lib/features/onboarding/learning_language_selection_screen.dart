import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/router/app_router.dart';
import '../../data/models/language_model.dart';
import '../../shared/widgets/language_card.dart';

/// Lets the user pick which language they want to LEARN, scoped to the
/// languages available for their previously selected country.
class LearningLanguageSelectionScreen extends StatelessWidget {
  const LearningLanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final country = app.selectedCountry;

    return Scaffold(
      appBar: AppBar(title: const Text('What do you want to learn?')),
      body: country == null
          ? const Center(child: Text('Please select a country first.'))
          : FutureBuilder<List<LanguageModel>>(
              future: app.contentRepository.getLanguagesForCountry(country),
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
                        'Languages in ${country.name} ${country.flag}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.separated(
                          itemCount: languages.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final lang = languages[index];
                            final selected =
                                app.progress.learningLanguageCode ==
                                    lang.code;
                            return Opacity(
                              opacity: lang.hasContent ? 1 : 0.5,
                              child: LanguageCard(
                                language: lang,
                                selected: selected,
                                onTap: !lang.hasContent
                                    ? () {}
                                    : () async {
                                        await app.selectLearningLanguage(lang);
                                        if (!context.mounted) return;
                                        Navigator.of(context)
                                            .pushNamed(AppRoutes.welcome);
                                      },
                              ),
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
