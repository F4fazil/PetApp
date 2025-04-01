import 'package:flutter/material.dart';

class CurvedSplitPainter extends CustomPainter {
  final Color primaryContainerColor;
  final Color tertiaryFixedVariantColor;

  CurvedSplitPainter({
    required this.primaryContainerColor,
    required this.tertiaryFixedVariantColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    // First color
    paint.color = primaryContainerColor;
    Path leftPath =
        Path()
          ..lineTo(size.width * 0.5, 0)
          ..quadraticBezierTo(
            size.width * 0.75,
            size.height * 0.5,
            0,
            size.height,
          )
          ..close();
    canvas.drawPath(leftPath, paint);

    // Second color
    paint.color = tertiaryFixedVariantColor;
    Path rightPath =
        Path()
          ..moveTo(size.width * 0.5, 0)
          ..quadraticBezierTo(
            size.width * 0.25,
            size.height * 0.5,
            size.width,
            size.height,
          )
          ..lineTo(size.width, 0)
          ..close();
    canvas.drawPath(rightPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
