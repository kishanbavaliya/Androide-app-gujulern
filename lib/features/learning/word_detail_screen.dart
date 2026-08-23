import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../data/models/learning_content_model.dart';
import '../../shared/widgets/animated_learning_visual.dart';
import '../../shared/widgets/audio_button.dart';

/// Detail screen for a single letter/word. Swiping left/right moves
/// through the rest of the category. Automatically pronounces the word
/// using the correct locale for the selected learning language.
class WordDetailScreen extends StatefulWidget {
  final LearningCategory category;
  final int initialIndex;

  const WordDetailScreen({
    super.key,
    required this.category,
    required this.initialIndex,
  });

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late int _current = widget.initialIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onPageShown(_current));
  }

  Future<void> _onPageShown(int index) async {
    final app = context.read<AppProvider>();
    final item = widget.category.items[index];
    await app.markItemCompleted(item, widget.category);
  }

  Future<void> _speak() async {
    final app = context.read<AppProvider>();
    if (!app.soundEnabled) return;
    final locale = app.learningLanguage?.locale ?? 'en-US';
    final item = widget.category.items[_current];
    final available = await app.tts.isLanguageAvailable(locale);
    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'This device does not have a $locale voice installed for pronunciation.'),
        ),
      );
      return;
    }
    await app.tts.speak(item.word, locale);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.title)),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.category.items.length,
        onPageChanged: (index) {
          setState(() => _current = index);
          _onPageShown(index);
        },
        itemBuilder: (context, index) {
          final item = widget.category.items[index];
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.category.id != 'numbers')
                    Text(
                      item.character,
                      style: const TextStyle(
                          fontSize: 56, fontWeight: FontWeight.w800),
                    ),
                  if (widget.category.id != 'numbers') const SizedBox(height: 12),
                  AnimatedLearningVisual(
                    fallbackEmoji: item.displayEmoji,
                    style: animationStyleForCategory(widget.category.id),
                    imageAsset: item.image,
                    size: 170,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    item.word,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.translation,
                    style: const TextStyle(
                        fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),
                  AudioButton(
                    isPlaying: app.tts.isSpeaking,
                    onPressed: _speak,
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap to hear pronunciation',
                      style: TextStyle(color: Colors.black45, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
