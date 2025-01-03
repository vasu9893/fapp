// ignore_for_file: avoid_print, unused_element, use_key_in_widget_constructors, library_private_types_in_public_api, unused_field, prefer_final_fields
import 'dart:async';
import 'dart:math';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:hack/predictionbar.dart';
import 'package:hack/redirect%20logic.dart';
import 'package:hack/register%20popup.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'hackereffect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

class HackWingoApp extends StatefulWidget {
  @override
  _HackWingoAppState createState() => _HackWingoAppState();
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showPredictionBar = false;
  String gameTimer = "00:30";
  String wins = "0";
  String losses = "0";
  String prediction = "Big";
  String periodNumber = "12";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PredictionAppBar(
        gameTimer: gameTimer,
        wins: wins,
        losses: losses,
        prediction: prediction,
        periodNumber: periodNumber,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              // Simulate updating the wins and losses
              wins = "1";
              losses = "0";
            });
          },
          child: const Text("Update Results"),
        ),
      ),
    );
  }
}

class _HackWingoAppState extends State<HackWingoApp> {
  late WebViewController _webViewController;
  bool _isAppEnabled = true;

  final String correctUserNumber = "8955559119";
  final String correctPassword = "krish0123";

// Declare initial values for the game state
  String _gameTimer = "Loading...";
  String _gamePeriod = "Loading...";
  String _prediction = "Loading...";
  int _wins = 0;
  int _losses = 0;
  Color _predictionColor = Colors.green;

  Timer? _updateTimer;
  bool _showPredictionBar = false;

  void _checkPageUrl(String url) {
    setState(() {
      // Update visibility of PredictionAppBar based on URL
      _showPredictionBar =
          url.contains("/home/AllLotteryGames/WinGo?id=1"); // Only show here
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _checkLoginStatus();
    _showHackerEffectPopup(); // Show the hacker effect popup
    _startTimerUpdates();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    await _checkAppStatus();
  }

  Future<void> _checkAppStatus() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      // Set default values
      await remoteConfig.setDefaults({'is_app_enabled': true});

      // Configure settings to allow frequent fetches during testing
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 10),
        minimumFetchInterval: Duration.zero, // Always fetch during testing
      ));

      // Fetch and activate remote config
      await remoteConfig.fetchAndActivate();

      setState(() {
        _isAppEnabled = remoteConfig.getBool('is_app_enabled');
      });
    } catch (e) {
      print("Error fetching Remote Config: $e");
    }
  }

  void _showHackerEffectPopup() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissal
        builder: (BuildContext context) {
          return HackerEffectPopup(
            onComplete: () {
              Navigator.pop(context); // Close the popup after effect finishes
            },
          );
        },
      );
    });
  }

  void _showRegisterPopup() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible:
            false, // Prevent closing the dialog without user action
        builder: (BuildContext context) {
          return RegisterPopup(
            onClose: () {
              Navigator.pop(context); // Close the popup
            },
          );
        },
      );
    });
  }

  void _startTimerUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_showPredictionBar) {
        await _fetchGameData();
      }
    });
  }

  void _injectRedirectLogic() {
    final redirectScript = JavaScriptHelper.getRedirectLogicScript();
    _webViewController.runJavascript(redirectScript);
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _getLoginStatus();
    if (isLoggedIn) {
      // Navigate directly to the home page URL
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _webViewController
            .loadUrl("https://diuwin.bet/#/home/AllLotteryGames/WinGo?id=1");
      });
    }
  }

  Future<void> _saveLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true); // Mark user as logged in
  }

  Future<bool> _getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false; // Return false if not set
  }

  Future<void> _clearLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Clear the login status
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

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAppEnabled) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text(
              "The app is currently disabled. Please try again later.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _showPredictionBar
          ? PredictionAppBar(
              gameTimer: _gameTimer,
              wins: _wins.toString(),
              losses: _losses.toString(),
              prediction: _prediction,
              periodNumber: _gamePeriod,
            )
          : null,
      body: WebView(
        initialUrl: "https://diuwin.bet/#/register",
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

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures Firebase initializes properly
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HackWingoApp(),
  ));
}
