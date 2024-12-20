import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HackWingoApp extends StatefulWidget {
  @override
  _HackWingoAppState createState() => _HackWingoAppState();
}

class _HackWingoAppState extends State<HackWingoApp> {
  late WebViewController _webViewController;

  final String correctUserNumber = "8955559119";
  final String correctPassword = "krish0123";

  String _gameTimer = "Loading...";
  String _gamePeriod = "Loading...";
  String _prediction = "Loading...";
  Color _predictionColor = Colors.green;

  Timer? _updateTimer;
  bool _showPredictionBar = false;

  @override
  void initState() {
    super.initState();
    _startTimerUpdates();
  }

  void _startTimerUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_showPredictionBar) {
        await _fetchGameData();
      }
    });
  }

  Future<void> _fetchGameData() async {
    try {
      const fetchGameTimerScript = """
        (() => {
          const activeItem = document.querySelector('.GameList__C-item.active > div');
          if (activeItem) {
            return activeItem.innerHTML.split('<br>')[1].trim();
          }
          return 'N/A';
        })();
      """;

      const fetchGamePeriodScript = """
        (() => {
          const periodElement = document.querySelector('.TimeLeft__C-id');
          if (periodElement) {
            return periodElement.innerText;
          }
          return 'N/A';
        })();
      """;

      final gameTimerResult = await _webViewController
          .runJavascriptReturningResult(fetchGameTimerScript);
      final gamePeriodResult = await _webViewController
          .runJavascriptReturningResult(fetchGamePeriodScript);

      String activeGameTimer = gameTimerResult.replaceAll('"', '');
      String gamePeriod = gamePeriodResult.replaceAll('"', '');

      setState(() {
        if (_gameTimer != activeGameTimer && activeGameTimer != "N/A") {
          _updatePrediction();
        }

        _gameTimer = activeGameTimer != 'N/A' ? activeGameTimer : "Not Found";
        _gamePeriod = gamePeriod != 'N/A' ? gamePeriod : "Not Found";
      });
    } catch (e) {
      print("Error fetching game data: $e");
    }
  }

  void _updatePrediction() {
    final random = Random();
    final isBig = random.nextBool();

    setState(() {
      _prediction = isBig ? "BIG" : "SMALL";
      _predictionColor = isBig ? Colors.yellow : Colors.lightBlue;
    });
  }

  void _injectLoginValidation() {
    const loginValidationScript = """
      (function() {
        const loginButton = document.querySelector('button.active');
        if (loginButton) {
          loginButton.addEventListener('click', function(event) {
            event.preventDefault();

            const userNumberInput = document.querySelector('input[name="userNumber"]');
            const passwordInput = document.querySelector('input[name="password"]');

            const userNumber = userNumberInput ? userNumberInput.value.trim() : '';
            const password = passwordInput ? passwordInput.value.trim() : '';

            // Flutter-level validation
            window.flutter_inappwebview.callHandler('validateCredentials', userNumber, password);
          });
        }
      })();
    """;

    _webViewController.runJavascript(loginValidationScript);
  }

  void _checkPageUrl(String url) {
    setState(() {
      _showPredictionBar = url.contains("/home/AllLotteryGames/WinGo?id=1");
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showPredictionBar
          ? PreferredSize(
              preferredSize: Size.fromHeight(110),
              child: AppBar(
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF079436), Color(0xFF50C878)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "💸 HACK WINGO PREDICTION 💸",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Game Timer: $_gameTimer",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        Text(
                          "Game Period: $_gamePeriod",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        color: _predictionColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _prediction,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                backgroundColor: Colors.black,
              ),
            )
          : null,
      body: WebView(
        initialUrl: "https://diuwin.bet/#/login",
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          _webViewController = controller;
          _webViewController.addJavaScriptHandler(
            handlerName: 'validateCredentials',
            callback: (args) {
              String userNumber = args[0];
              String password = args[1];

              if (userNumber == correctUserNumber &&
                  password == correctPassword) {
                _webViewController.loadUrl(
                    "https://diuwin.bet/#/home/AllLotteryGames/WinGo?id=1");
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Invalid Credentials"),
                    content: Text(
                        "The provided credentials are incorrect. Please try again."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("OK"),
                      )
                    ],
                  ),
                );
              }
            },
          );
        },
        onPageFinished: (url) {
          if (url.contains("login")) {
            _injectLoginValidation();
          }
          _checkPageUrl(url);
        },
      ),
    );
  }
}

extension on WebViewController {
  void addJavaScriptHandler(
      {required String handlerName,
      required Null Function(dynamic args) callback}) {}
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HackWingoApp(),
  ));
}
