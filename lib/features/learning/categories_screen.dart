import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/lesson_card.dart';

/// The "Learn" tab: lists every category (Alphabet, Numbers, Colors,
/// Animals, ...) for the currently selected learning language.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const _icons = [
    Icons.abc,
    Icons.numbers,
    Icons.palette,
    Icons.pets,
    Icons.local_florist,
    Icons.eco,
    Icons.family_restroom,
    Icons.chair,
    Icons.chat_bubble_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final content = app.currentLearningContent;

    return Scaffold(
      appBar: AppBar(
        title: Text('Learn ${app.learningLanguage?.name ?? ''}'),
      ),
      body: content == null
          ? const Center(child: Text('No lessons available yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: content.categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = content.categories[index];
                final done = category.items
                    .where(
                        (i) => app.progress.completedItemIds.contains(i.id))
                    .length;
                return LessonCard(
                  title: category.title,
                  icon: _icons[index % _icons.length],
                  color:
                      AppTheme.boxPalette[index % AppTheme.boxPalette.length],
                  totalItems: category.items.length,
                  completedItems: done,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.lesson,
                    arguments: LessonArgs(category),
                  ),
                );
              },
            ),
    );
  }
}
