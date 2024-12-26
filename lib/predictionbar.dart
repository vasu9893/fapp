// ignore_for_file: use_super_parameters, library_private_types_in_public_api, deprecated_member_use, use_key_in_widget_constructors, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class AdvancedMatrixEffect extends StatefulWidget {
  final double height;
  final double width;

  const AdvancedMatrixEffect(
      {required this.height, required this.width, Key? key})
      : super(key: key);

  @override
  _AdvancedMatrixEffectState createState() => _AdvancedMatrixEffectState();
}

class _AdvancedMatrixEffectState extends State<AdvancedMatrixEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<List<String>> _matrix;
  late int rows, columns;

  @override
  void initState() {
    super.initState();

    rows = (widget.height / 20).ceil();
    columns = (widget.width / 12).ceil();
    _matrix = List.generate(
        rows, (_) => List.generate(columns, (_) => _randomChar()));

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100))
      ..addListener(() {
        setState(() {
          for (int i = 0; i < rows; i++) {
            for (int j = 0; j < columns; j++) {
              if (Random().nextDouble() > 0.95) {
                _matrix[i][j] = _randomChar();
              }
            }
          }
        });
      })
      ..repeat();
  }

  String _randomChar() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return chars[Random().nextInt(chars.length)];
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
      painter: MatrixPainter(_matrix, rows, columns),
    );
  }
}

class MatrixPainter extends CustomPainter {
  final List<List<String>> matrix;
  final int rows;
  final int columns;

  MatrixPainter(this.matrix, this.rows, this.columns);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        final textStyle = TextStyle(
          color: Colors.greenAccent.shade400.withOpacity(Random().nextDouble()),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        );
        textPainter.text = TextSpan(text: matrix[i][j], style: textStyle);
        textPainter.layout();
        textPainter.paint(canvas, Offset(j * 12.0, i * 20.0));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PredictionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String gameTimer;
  final String wins;
  final String losses;
  final String prediction;
  final String periodNumber;

  const PredictionAppBar({
    required this.gameTimer,
    required this.wins,
    required this.losses,
    required this.prediction,
    required this.periodNumber,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBig = prediction.toLowerCase() == 'big';

    return PreferredSize(
      preferredSize: const Size.fromHeight(310),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3AAF4D), Color(0xFF01CE86)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: AppBar(
          backgroundColor:
              Colors.transparent, // Make AppBar background transparent
          elevation: 0,
          flexibleSpace: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 0,
              left: 7,
              right: 7,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title: Hack Wingo Prediction
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8), // Black overlay
                      border: Border.all(
                        color: Colors.lightGreenAccent,
                        width: 0,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "💸 DiuWin Hack Prediction 💸",
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Combined container with a white line
                Container(
                  height: 95,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Left half: Confined Matrix effect
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: AdvancedMatrixEffect(
                            height: 200,
                            width: MediaQuery.of(context).size.width / 2,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        color: Colors.white, // White line separator
                      ),
                      // Right half: Game details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Game timer
                              Text(
                                "Time: $gameTimer",
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Period number
                              Text(
                                "$periodNumber",
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 7),
                              // Wins and losses
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.greenAccent, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        "$wins Wins",
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.cancel,
                                          color: Colors.redAccent, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        "$losses Losses",
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                // Centered Prediction Box
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.3,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isBig ? Colors.yellow : Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    prediction,
                    style: GoogleFonts.roboto(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: isBig ? Colors.red : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(185);
}
