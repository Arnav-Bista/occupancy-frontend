import 'dart:math';

import 'package:flutter/material.dart';

class CustomProgressIndicator extends CustomPainter {
  CustomProgressIndicator({
    required this.progress,
    this.startAngle,
    this.progressColor,
    this.emptyColor,
  });

  final double progress;
  double? startAngle;
  final Color? progressColor;
  final Color? emptyColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double finalAngle = (startAngle ?? 0) * pi / 180;
    final progressAngle = (pi + finalAngle * 2) * progress;
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(
        rect,
        pi + finalAngle,
        pi - finalAngle * 2,
        false,
        Paint()
          ..color = emptyColor ?? Colors.grey[200]!
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke);
    canvas.drawArc(
        rect,
        pi + finalAngle,
        progressAngle * 2,
        false,
        Paint()
          ..color = progressColor ?? Colors.blue
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(CustomProgressIndicator oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.startAngle != startAngle;
  }
}
