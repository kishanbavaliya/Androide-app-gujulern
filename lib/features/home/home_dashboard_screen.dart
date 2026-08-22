import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../shared/widgets/lesson_card.dart';
import '../../core/theme/app_theme.dart';
import 'home_shell.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  static const _icons = [
    Icons.abc,
    Icons.text_fields,
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
    final language = app.learningLanguage;
    final totalWords = content?.totalItems ?? 0;
    final completedWords = app.progress.completedItemIds.length;
    final ratio = totalWords == 0 ? 0.0 : completedWords / totalWords;

    return SafeArea(
      child: content == null
          ? const Center(child: Text('No lessons available yet.'))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learn ${language?.name ?? ''}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Your progress',
                                      style: TextStyle(color: Colors.white70)),
                                  Text('${(ratio * 100).round()}%',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 10,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation(
                                      Colors.white),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  const Icon(Icons.local_fire_department,
                                      color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text('${app.progress.currentStreak} day streak',
                                      style: const TextStyle(color: Colors.white)),
                                  const SizedBox(width: 20),
                                  const Icon(Icons.star, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text('${app.progress.xp} XP',
                                      style: const TextStyle(color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                HomeTabController.maybeOf(context)
                                    ?.goToTab(1),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Continue Learning'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Lessons',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = content.categories[index];
                        final done = category.items
                            .where((i) =>
                                app.progress.completedItemIds.contains(i.id))
                            .length;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: LessonCard(
                            title: category.title,
                            icon: _icons[index % _icons.length],
                            color: AppTheme.boxPalette[
                                index % AppTheme.boxPalette.length],
                            totalItems: category.items.length,
                            completedItems: done,
                            onTap: () =>
                                HomeTabController.maybeOf(context)?.goToTab(1),
                          ),
                        );
                      },
                      childCount: content.categories.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
