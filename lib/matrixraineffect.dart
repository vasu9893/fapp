// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';

class MatrixRainEffect extends CustomPainter {
  final Random random = Random();
  final int columns; // Number of columns in the effect
  final List<String> characters;

  MatrixRainEffect(this.columns)
      : characters =
            List.generate(128, (index) => String.fromCharCode(33 + index));

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Column width
    final double columnWidth = size.width / columns;

    for (int column = 0; column < columns; column++) {
      // Generate a vertical position for the character
      double dy = random.nextDouble() * size.height;

      for (int i = 0; i < 10; i++) {
        // Limit number of characters per column
        String char = characters[random.nextInt(characters.length)];

        final textStyle = TextStyle(
          color:
              Colors.greenAccent.withOpacity(0.5 + random.nextDouble() * 0.5),
          fontSize: 14 + random.nextInt(6).toDouble(),
          fontFamily: 'Courier',
        );

        textPainter.text = TextSpan(text: char, style: textStyle);
        textPainter.layout();

        // Offset for each character
        final dx = column * columnWidth + random.nextDouble() * 5 - 2.5;
        final yPosition = dy + (i * 20); // Staggered vertical placement

        // Paint character
        textPainter.paint(canvas, Offset(dx, yPosition % size.height));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
