import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/learning_content_model.dart';
import '../../shared/widgets/learning_box.dart';

/// Shows the large, colorful, tappable boxes for one category (e.g. all
/// 30 letters of the Gujarati alphabet).
class LessonScreen extends StatelessWidget {
  final LearningCategory category;
  const LessonScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          itemCount: category.items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
          ),
          itemBuilder: (context, index) {
            final item = category.items[index];
            final completed =
                app.progress.completedItemIds.contains(item.id);
            return LearningBox(
              character: item.character,
              color: AppTheme.boxPalette[index % AppTheme.boxPalette.length],
              completed: completed,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.wordDetail,
                arguments: WordDetailArgs(category, index),
              ),
            );
          },
        ),
      ),
    );
  }
}
