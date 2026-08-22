import 'package:flutter/material.dart';

/// Displays a local asset image, but never crashes or shows Flutter's
/// red error box if the asset is missing -- it falls back to a friendly
/// colored placeholder showing [fallbackEmoji] instead. This makes it
/// trivial to swap in real artwork later: just drop a matching file into
/// the asset path and it will be picked up automatically.
class AppImage extends StatelessWidget {
  final String assetPath;
  final String fallbackEmoji;
  final double size;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    required this.assetPath,
    required this.fallbackEmoji,
    this.size = 96,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    final bg = backgroundColor ??
        Theme.of(context).colorScheme.primary.withOpacity(0.08);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size,
        height: size,
        color: bg,
        alignment: Alignment.center,
        child: assetPath.isEmpty
            ? Text(fallbackEmoji, style: TextStyle(fontSize: size * 0.45))
            : Image.asset(
                assetPath,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Text(
                  fallbackEmoji,
                  style: TextStyle(fontSize: size * 0.45),
                ),
              ),
      ),
    );
  }
}
