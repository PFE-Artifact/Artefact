import 'package:flutter/material.dart';
import 'dart:math' as math;

enum HexagonNodeStatus {
  locked,
  unlocked,
  completed,
  current,
}

class HexagonNode extends StatelessWidget {
  final int levelNumber;
  final HexagonNodeStatus status;
  final VoidCallback onTap;
  final bool showNumber;
  final bool showReward;

  const HexagonNode({
    super.key,
    required this.levelNumber,
    required this.status,
    required this.onTap,
    this.showNumber = true,
    this.showReward = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: status == HexagonNodeStatus.locked ? null : onTap,
      child: CustomPaint(
        size: const Size(60, 60),
        painter: HexagonPainter(
          color: _getBackgroundColor(),
          borderColor: Colors.white.withOpacity(0.5),
        ),
        child: SizedBox(
          width: 60,
          height: 60,
          child: Center(
            child: _getIcon(),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case HexagonNodeStatus.locked:
        return Colors.grey.withOpacity(0.5);
      case HexagonNodeStatus.unlocked:
        return Colors.white.withOpacity(0.5);
      case HexagonNodeStatus.completed:
        return const Color(0xFF1DE9B6); // Teal
      case HexagonNodeStatus.current:
        return const Color(0xFFFF9E80); // Orange

    }
  }

  Widget _getIcon() {
    if (showReward) {
      return const Icon(
        Icons.card_giftcard,
        color: Colors.white,
        size: 24,
      );
    }

    switch (status) {
      case HexagonNodeStatus.locked:
        return const Icon(
          Icons.lock,
          color: Colors.white,
          size: 24,
        );
      case HexagonNodeStatus.unlocked:
      case HexagonNodeStatus.completed:
        if (!showNumber) {
          return const Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 24,
          );
        }
        return Text(
          levelNumber.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      case HexagonNodeStatus.current:
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

class HexagonPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  HexagonPainter({
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final double width = size.width;
    final double height = size.height;
    final double centerX = width / 2;
    final double centerY = height / 2;
    final double radius = math.min(width, height) / 2;

    for (int i = 0; i < 6; i++) {
      double angle = (i * 60 + 30) * math.pi / 180;
      double x = centerX + radius * math.cos(angle);
      double y = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();

    // Add shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 4.0, true);

    // Draw hexagon
    canvas.drawPath(path, paint);

    // Draw border
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}