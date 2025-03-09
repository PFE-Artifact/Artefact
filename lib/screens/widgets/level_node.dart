import 'package:flutter/material.dart';

enum LevelNodeStatus {
  locked,
  unlocked,
  completed,
  current,
}

class LevelNode extends StatelessWidget {
  final int levelNumber;
  final LevelNodeStatus status;
  final VoidCallback onTap;

  const LevelNode({
    super.key,
    required this.levelNumber,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: status == LevelNodeStatus.locked ? null : onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getBackgroundColor(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: _getIcon(),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case LevelNodeStatus.locked:
        return Colors.grey.shade300;
      case LevelNodeStatus.unlocked:
        return Colors.white;
      case LevelNodeStatus.completed:
        return const Color(0xFF1DE9B6); // Teal
      case LevelNodeStatus.current:
        return const Color(0xFFFF9E80); // Orange
    }
  }

  Widget _getIcon() {
    switch (status) {
      case LevelNodeStatus.locked:
        return const Icon(
          Icons.lock,
          color: Colors.grey,
          size: 24,
        );
      case LevelNodeStatus.unlocked:
        return Text(
          levelNumber.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        );
      case LevelNodeStatus.completed:
        return const Icon(
          Icons.card_giftcard,
          color: Colors.white,
          size: 24,
        );
      case LevelNodeStatus.current:
        return Text(
          levelNumber.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
    }
  }
}