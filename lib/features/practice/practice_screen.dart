import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/learning_content_model.dart';
import '../../shared/widgets/quiz_option.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  LearningCategory? _activeCategory;
  late List<LearningItem> _quizItems;
  int _questionIndex = 0;
  int _score = 0;
  String? _selectedOptionId;
  bool _answered = false;
  late List<LearningItem> _currentOptions;
  String? _correctId;

  void _startQuiz(LearningCategory category) {
    final items = List<LearningItem>.from(category.items)..shuffle();
    setState(() {
      _activeCategory = category;
      _quizItems = items.take(min(8, items.length)).toList();
      _questionIndex = 0;
      _score = 0;
    });
    _prepareQuestion();
  }

  void _prepareQuestion() {
    final category = _activeCategory!;
    final correct = _quizItems[_questionIndex];
    final distractors = List<LearningItem>.from(category.items)
      ..removeWhere((i) => i.id == correct.id)
      ..shuffle();
    final options = [correct, ...distractors.take(3)]..shuffle();
    setState(() {
      _currentOptions = options;
      _correctId = correct.id;
      _selectedOptionId = null;
      _answered = false;
    });
  }

  Future<void> _selectOption(LearningItem option) async {
    if (_answered) return;
    final app = context.read<AppProvider>();
    final correct = option.id == _correctId;
    setState(() {
      _selectedOptionId = option.id;
      _answered = true;
      if (correct) _score++;
    });
    await app.recordQuizAnswer(correct);
  }

  void _nextQuestion() {
    if (_questionIndex + 1 >= _quizItems.length) {
      // No more questions -- advancing the index past the end makes the
      // build method fall through to the results view.
      setState(() => _questionIndex = _quizItems.length);
      return;
    }
    setState(() => _questionIndex++);
    _prepareQuestion();
  }

  void _reset() {
    setState(() => _activeCategory = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_activeCategory == null) {
      return _CategoryPicker(onSelected: _startQuiz);
    }
    if (_questionIndex >= _quizItems.length) {
      return _ResultsView(
        score: _score,
        total: _quizItems.length,
        onDone: _reset,
      );
    }
    return _QuizView(
      category: _activeCategory!,
      questionItem: _quizItems[_questionIndex],
      options: _currentOptions,
      questionNumber: _questionIndex + 1,
      totalQuestions: _quizItems.length,
      score: _score,
      selectedOptionId: _selectedOptionId,
      correctId: _correctId!,
      answered: _answered,
      onSelect: _selectOption,
      onNext: _nextQuestion,
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final void Function(LearningCategory) onSelected;
  const _CategoryPicker({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final content = app.currentLearningContent;

    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: content == null
          ? const Center(child: Text('No content available yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: content.categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = content.categories[index];
                final canQuiz = category.items.length >= 4;
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: canQuiz ? () => onSelected(category) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppTheme.boxPalette[
                                      index % AppTheme.boxPalette.length]
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.quiz,
                                color: AppTheme.boxPalette[
                                    index % AppTheme.boxPalette.length]),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              category.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _QuizView extends StatelessWidget {
  final LearningCategory category;
  final LearningItem questionItem;
  final List<LearningItem> options;
  final int questionNumber;
  final int totalQuestions;
  final int score;
  final String? selectedOptionId;
  final String correctId;
  final bool answered;
  final void Function(LearningItem) onSelect;
  final VoidCallback onNext;

  const _QuizView({
    required this.category,
    required this.questionItem,
    required this.options,
    required this.questionNumber,
    required this.totalQuestions,
    required this.score,
    required this.selectedOptionId,
    required this.correctId,
    required this.answered,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question $questionNumber / $totalQuestions'),
                Text('Score: $score',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: questionNumber / totalQuestions,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              questionItem.character,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text('What is this?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 24),
            ...options.map((option) {
              QuizOptionState state = QuizOptionState.idle;
              if (answered) {
                if (option.id == correctId) {
                  state = QuizOptionState.correct;
                } else if (option.id == selectedOptionId) {
                  state = QuizOptionState.wrong;
                }
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: QuizOption(
                  label: option.word,
                  state: state,
                  onTap: answered ? null : () => onSelect(option),
                ),
              );
            }),
            const Spacer(),
            if (answered)
              ElevatedButton(
                onPressed: onNext,
                child: Text(questionNumber == totalQuestions
                    ? 'See results'
                    : 'Next question'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onDone;

  const _ResultsView({
    required this.score,
    required this.total,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : ((score / total) * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(pct >= 70 ? '🎉' : '💪', style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'You scored $score / $total',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text('$pct% correct',
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDone,
                  child: const Text('Practice another category'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
