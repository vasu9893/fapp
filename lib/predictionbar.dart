import 'package:flutter/material.dart';
import 'dart:async';
import 'package:html/parser.dart' as html;

class GameLogic {
  int wins = 0;
  int losses = 0;
  String gameTimer = "00:00";

  void updateResults(
      String htmlContent, String prediction, String periodNumber) {
    // Parse the HTML content
    final document = html.parse(htmlContent);
    final spans = document.getElementsByTagName('span');

    // Find the result for the current period
    String result = "";
    for (var span in spans) {
      if (span.text == "Small" || span.text == "Big") {
        result = span.text;
      }
    }

    // Update wins or losses
    if (result == prediction) {
      wins++;
    } else {
      losses++;
    }
  }

  void startGameTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      // Update the game timer (dummy implementation)
      gameTimer = "00:${timer.tick.toString().padLeft(2, '0')}";
    });
  }
}

class PredictionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String gameTimer; // Game timer
  final String wins; // Wins count
  final String losses; // Losses count
  final String prediction; // Prediction: "Small" or "Big"
  final String periodNumber; // Current period number

  const PredictionAppBar({
    required this.gameTimer,
    required this.wins,
    required this.losses,
    required this.prediction,
    required this.periodNumber,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(180),
      child: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade900, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.money, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      "Hack WinGo Prediction",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                        fontFamily: 'SFPro',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Game timer and period number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Game Timer: $gameTimer",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'SFPro',
                      ),
                    ),
                    Text(
                      "Period: $periodNumber",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'SFPro',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Wins, losses, prediction, and multiplier
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$wins win",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.greenAccent,
                            fontFamily: 'SFPro',
                          ),
                        ),
                        Text(
                          "$losses Lose",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent,
                            fontFamily: 'SFPro',
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          "Next Result Is :-",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'SFPro',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            prediction,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'SFPro',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "1x",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                        fontFamily: 'SFPro',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(180);
}
