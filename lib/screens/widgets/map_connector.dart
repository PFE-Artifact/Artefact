import 'package:flutter/material.dart';

class MapConnector extends StatelessWidget {
  final bool isActive;
  final Axis direction;
  final double length;

  const MapConnector({
    super.key,
    this.isActive = false,
    this.direction = Axis.vertical,
    this.length = 70.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: direction == Axis.horizontal ? length : 2,
      height: direction == Axis.vertical ? length : 2,
      child: Center(
        child: Container(
          width: direction == Axis.horizontal ? length : 2,
          height: direction == Axis.vertical ? length : 2,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}