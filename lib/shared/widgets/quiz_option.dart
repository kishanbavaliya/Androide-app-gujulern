import 'package:flutter/material.dart';

enum QuizOptionState { idle, correct, wrong }

class QuizOption extends StatelessWidget {
  final String label;
  final QuizOptionState state;
  final VoidCallback? onTap;

  const QuizOption({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor = Colors.black87;
    IconData? trailingIcon;

    switch (state) {
      case QuizOptionState.correct:
        bg = const Color(0xFFE7F8ED);
        border = const Color(0xFF35C56A);
        textColor = const Color(0xFF1F8A45);
        trailingIcon = Icons.check_circle;
        break;
      case QuizOptionState.wrong:
        bg = const Color(0xFFFCEBEC);
        border = const Color(0xFFE5484D);
        textColor = const Color(0xFFC2373C);
        trailingIcon = Icons.cancel;
        break;
      case QuizOptionState.idle:
        bg = Colors.white;
        border = Colors.transparent;
        break;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}
