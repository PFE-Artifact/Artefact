import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.showResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    if (showResult) {
      if (isSelected && isCorrect) {
        backgroundColor = Colors.green;
        textColor = Colors.white;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red;
        textColor = Colors.white;
      } else if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.3);
        textColor = Colors.white;
      } else {
        backgroundColor = Colors.white.withOpacity(0.2);
        textColor = Colors.white;
      }
    } else {
      backgroundColor = isSelected ? Colors.white : Colors.white.withOpacity(0.2);
      textColor = isSelected ? Colors.purple : Colors.white;
    }

    return GestureDetector(
      onTap: showResult ? null : onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}