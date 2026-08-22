import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/progress_card.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final progress = app.progress;
    final content = app.currentLearningContent;
    final totalWords = content?.totalItems ?? 0;
    final completedWords = progress.completedItemIds.length;
    final accuracy = progress.quizzesTaken == 0
        ? 0
        : ((progress.quizzesCorrect / progress.quizzesTaken) * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.3,
            children: [
              ProgressCard(
                label: 'Words learned',
                value: '$completedWords / $totalWords',
                icon: Icons.menu_book,
                color: Colors.indigo,
              ),
              ProgressCard(
                label: 'Day streak',
                value: '${progress.currentStreak} 🔥',
                icon: Icons.local_fire_department,
                color: Colors.deepOrange,
              ),
              ProgressCard(
                label: 'Total XP',
                value: '${progress.xp} ⭐',
                icon: Icons.star,
                color: Colors.amber,
              ),
              ProgressCard(
                label: 'Quiz accuracy',
                value: '$accuracy%',
                icon: Icons.quiz,
                color: Colors.teal,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Badges',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: kBadges.map((badge) {
              final unlocked = progress.unlockedBadgeIds.contains(badge.id);
              return Opacity(
                opacity: unlocked ? 1 : 0.35,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(badge.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(badge.title,
                          style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Daily goal',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${progress.xp % AppConstants.dailyGoalXp} / ${AppConstants.dailyGoalXp} XP today',
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (progress.xp % AppConstants.dailyGoalXp) /
                        AppConstants.dailyGoalXp,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
