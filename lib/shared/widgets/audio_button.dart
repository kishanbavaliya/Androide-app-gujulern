import 'package:flutter/material.dart';

/// A speaker/replay button with a small pulse animation while speaking.
/// Used everywhere the app plays Text-to-Speech pronunciation.
class AudioButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onPressed;
  final double size;

  const AudioButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
    this.size = 64,
  });

  @override
  State<AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale =
            widget.isPlaying ? 1.0 + (_controller.value * 0.08) : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: Material(
        color: scheme.primary,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.onPressed,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Icon(
              widget.isPlaying ? Icons.volume_up_rounded : Icons.volume_up,
              color: Colors.white,
              size: widget.size * 0.45,
            ),
          ),
        ),
      ),
    );
  }
}
