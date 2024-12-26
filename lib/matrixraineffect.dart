// ignore_for_file: unused_local_variable, use_super_parameters, library_private_types_in_public_api

import 'dart:math';
import 'package:flutter/material.dart';

class AdvancedMatrixEffect extends StatefulWidget {
  final double height;
  final double width;

  const AdvancedMatrixEffect({
    required this.height,
    required this.width,
    Key? key,
  }) : super(key: key);

  @override
  _AdvancedMatrixEffectState createState() => _AdvancedMatrixEffectState();
}

class _AdvancedMatrixEffectState extends State<AdvancedMatrixEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<MatrixColumn> _columns = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(() {
        for (var column in _columns) {
          column.update();
        }
        setState(() {});
      });

    _initializeColumns();
    _controller.repeat();
  }

  void _initializeColumns() {
    int columnCount = (widget.width / 14).floor(); // Each column is 14px wide
    for (int i = 0; i < columnCount; i++) {
      _columns.add(MatrixColumn(
        xPosition: i * 14.0,
        height: widget.height,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: MatrixPainter(columns: _columns),
    );
  }
}

class MatrixColumn {
  final double xPosition;
  final double height;
  double _currentOffset = 0.0;
  double _speed;
  final Random _random = Random();
  final List<String> _characters = [];
  static const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

  MatrixColumn({required this.xPosition, required this.height})
      : _speed = 2.0 + Random().nextDouble() * 2.0 {
    _initializeCharacters();
  }

  void _initializeCharacters() {
    int count = (height / 20).ceil();
    for (int i = 0; i < count; i++) {
      _characters.add(chars[Random().nextInt(chars.length)]);
    }
  }

  void update() {
    _currentOffset += _speed;

    // Reset column if it moves out of bounds
    if (_currentOffset > height) {
      _currentOffset = -20.0;
      _characters.shuffle();
      _speed = 2.0 + _random.nextDouble() * 2.0; // Randomize speed
    }
  }

  double get currentOffset => _currentOffset;

  List<String> get characters => _characters;
}

class MatrixPainter extends CustomPainter {
  final List<MatrixColumn> columns;

  MatrixPainter({required this.columns});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final TextStyle textStyle = TextStyle(
      color: Colors.greenAccent,
      fontSize: 14,
      fontWeight: FontWeight.w900,
    );

    for (var column in columns) {
      double yOffset = column.currentOffset;
      for (var character in column.characters) {
        final textPainter = TextPainter(
          text: TextSpan(text: character, style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(canvas, Offset(column.xPosition, yOffset));
        yOffset += 20; // Move to next line
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Continuously repaint for animation
  }
}
