import 'package:flutter/material.dart';

/// A large, colorful, rounded tappable box used to display a single
/// letter/character on the lesson screen -- sized for easy tapping by
/// children and beginners alike.
class LearningBox extends StatelessWidget {
  final String character;
  final Color color;
  final bool completed;
  final VoidCallback onTap;

  const LearningBox({
    super.key,
    required this.character,
    required this.color,
    required this.onTap,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Center(
                child: Text(
                  character,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (completed)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(Icons.check_circle,
                      color: Colors.white, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
