import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Motion styles applied to a learning visual. Chosen per-category so
/// different kinds of content feel distinct: letters bounce playfully,
/// numbers pulse, colors wiggle, animals gently float.
enum VisualAnimationStyle { bounce, pulse, wiggle, float, spin }

/// Renders an animated visual for a single learning item.
///
/// This app ships fully offline with no bundled photographic/GIF
/// artwork, so "animated image" is delivered as a lightweight built-in
/// motion (bounce/pulse/wiggle/float) applied to an emoji glyph -- e.g.
/// "A for Apple" shows 🍎 gently bouncing. The widget is architected so
/// a real Lottie animation can be dropped in later with zero code
/// changes: if [lottieAsset] is provided and the file exists under
/// assets/animations/, it plays that instead and the built-in motion is
/// skipped automatically.
class AnimatedLearningVisual extends StatefulWidget {
  final String fallbackEmoji;
  final VisualAnimationStyle style;
  final String lottieAsset;
  final String imageAsset;
  final double size;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AnimatedLearningVisual({
    super.key,
    required this.fallbackEmoji,
    required this.style,
    this.lottieAsset = '',
    this.imageAsset = '',
    this.size = 140,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  State<AnimatedLearningVisual> createState() =>
      _AnimatedLearningVisualState();
}

class _AnimatedLearningVisualState extends State<AnimatedLearningVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Duration get _duration {
    switch (widget.style) {
      case VisualAnimationStyle.bounce:
        return const Duration(milliseconds: 1000);
      case VisualAnimationStyle.pulse:
        return const Duration(milliseconds: 900);
      case VisualAnimationStyle.wiggle:
        return const Duration(milliseconds: 1400);
      case VisualAnimationStyle.float:
        return const Duration(milliseconds: 2200);
      case VisualAnimationStyle.spin:
        return const Duration(milliseconds: 2600);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    if (widget.style == VisualAnimationStyle.spin) {
      _controller.repeat();
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _wrapWithMotion(Widget child) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, c) {
        final t = _controller.value;
        switch (widget.style) {
          case VisualAnimationStyle.bounce:
            final dy = -math.sin(t * math.pi) * (widget.size * 0.12);
            return Transform.translate(offset: Offset(0, dy), child: c);
          case VisualAnimationStyle.pulse:
            final scale = 1.0 + (t * 0.12);
            return Transform.scale(scale: scale, child: c);
          case VisualAnimationStyle.wiggle:
            final angle = math.sin(t * math.pi) * 0.12;
            return Transform.rotate(angle: angle, child: c);
          case VisualAnimationStyle.float:
            final dy = -math.sin(t * math.pi) * (widget.size * 0.06);
            return Transform.translate(offset: Offset(0, dy), child: c);
          case VisualAnimationStyle.spin:
            return Transform.rotate(angle: t * 2 * math.pi, child: c);
        }
      },
      child: child,
    );
  }

  Widget _content() {
    if (widget.lottieAsset.isNotEmpty) {
      return Lottie.asset(
        widget.lottieAsset,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _emojiOrImage(),
      );
    }
    return _emojiOrImage();
  }

  Widget _emojiOrImage() {
    if (widget.imageAsset.isNotEmpty) {
      return Image.asset(
        widget.imageAsset,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _emojiText(),
      );
    }
    return _emojiText();
  }

  Widget _emojiText() {
    return Center(
      child: Text(
        widget.fallbackEmoji,
        style: TextStyle(fontSize: widget.size * 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(24);
    final bg = widget.backgroundColor ??
        Theme.of(context).colorScheme.primary.withOpacity(0.08);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: widget.size,
        height: widget.size,
        color: bg,
        alignment: Alignment.center,
        child: _wrapWithMotion(_content()),
      ),
    );
  }
}

/// Maps a category id (alphabet/numbers/colors/animals) to a motion
/// style, so callers don't need to hardcode this mapping everywhere.
VisualAnimationStyle animationStyleForCategory(String categoryId) {
  switch (categoryId) {
    case 'alphabet':
      return VisualAnimationStyle.bounce;
    case 'numbers':
      return VisualAnimationStyle.pulse;
    case 'colors':
      return VisualAnimationStyle.wiggle;
    case 'animals':
      return VisualAnimationStyle.float;
    default:
      return VisualAnimationStyle.bounce;
  }
}
