// ignore_for_file: use_super_parameters, library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TradePage extends StatefulWidget {
  final String gameTimer;
  final String wins;
  final String losses;
  final String prediction;
  final String periodNumber;

  const TradePage({
    required this.gameTimer,
    required this.wins,
    required this.losses,
    required this.prediction,
    required this.periodNumber,
    Key? key,
  }) : super(key: key);

  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  late WebViewController _webViewController;
  Timer? _autoTradeTimer;
  bool _isAutoTrading = false;
  int _currentLevel = 0;

  final List<int> _tradeValues = [5, 10, 25, 60, 130, 280, 600, 1300];

  @override
  void dispose() {
    _autoTradeTimer?.cancel();
    super.dispose();
  }

  void startAutoTrade() {
    if (_isAutoTrading) return; // Prevent duplicate timers
    if (!isTimeSufficient(widget.gameTimer)) {
      print("Insufficient time remaining for auto-trade.");
      return;
    }

    print("Starting auto-trade...");
    setState(() {
      _isAutoTrading = true;
    });

    _autoTradeTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (_currentLevel >= _tradeValues.length) {
        print("Reached maximum trade level. Stopping auto-trade.");
        stopAutoTrade();
        return;
      }

      performTrade(widget.prediction);
    });
  }

  void stopAutoTrade() {
    print("Stopping auto-trade...");
    setState(() {
      _isAutoTrading = false;
    });
    _autoTradeTimer?.cancel();
  }

  bool isTimeSufficient(String timer) {
    final timeParts = timer.split(':').map(int.tryParse).toList();
    if (timeParts.length != 2 || timeParts.any((part) => part == null)) {
      print("Invalid timer format.");
      return false;
    }

    final minutes = timeParts[0]!;
    final seconds = timeParts[1]!;
    return (minutes * 60 + seconds) > 10;
  }

  void performTrade(String prediction) async {
    final tradeValue = _tradeValues[_currentLevel];
    final script = '''
      const prediction = "$prediction";
      const bigButton = document.querySelector(".Betting__C-foot-b");
      const smallButton = document.querySelector(".Betting__C-foot-s");
      const inputField = document.querySelector("input[type='tel']");
      const tradeButton = document.querySelector(".Betting__Popup-foot-s");

      if (prediction.toLowerCase() === "big" && bigButton) {
        bigButton.click();
      } else if (smallButton) {
        smallButton.click();
      }

      if (inputField) {
        inputField.value = "$tradeValue";
        const event = new Event('input', { bubbles: true });
        inputField.dispatchEvent(event);
      }

      if (tradeButton) {
        tradeButton.click();
      }
    ''';

    await _webViewController.runJavascript(script);
    print("Executed trade: $prediction with amount ₹$tradeValue");

    // Simulate trade result
    bool tradeWon = Random().nextBool();
    if (tradeWon) {
      print("Trade won. Resetting to level 1.");
      _currentLevel = 0;
    } else {
      print("Trade lost. Moving to the next level.");
      _currentLevel = min(_currentLevel + 1, _tradeValues.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBig = widget.prediction.toLowerCase() == 'big';

    return Scaffold(
      appBar: AppBar(
        title: Text("Trading App - ${widget.periodNumber}"),
        backgroundColor: isBig ? Colors.green : Colors.blue,
        actions: [
          TextButton(
            onPressed: _isAutoTrading ? stopAutoTrade : startAutoTrade,
            child: Text(
              _isAutoTrading ? "Stop Auto-Trade" : "Start Auto-Trade",
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: WebView(
        initialUrl: 'https://example.com', // Replace with actual trading URL
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TradePage(
      gameTimer: "02:28",
      wins: "3",
      losses: "1",
      prediction: "Big",
      periodNumber: "Period 5",
    ),
  ));
}
