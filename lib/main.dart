import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hangman/screens/home_screen.dart';
import 'package:flutter_hangman/screens/onboard.dart';
import 'package:flutter_hangman/screens/splash.dart';
import 'package:flutter_hangman/utilities/constants.dart';
import 'package:flutter_hangman/screens/score_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize("ca-app-pub-2769425876266383~8918398585");
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: kTooltipColor,
            borderRadius: BorderRadius.circular(5.0),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        scaffoldBackgroundColor: Color(0xFF421b9b),
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'PatrickHand'),
      ),
      initialRoute: 'splash',
      routes: {
        'homePage': (context) => HomeScreen(),
        'scorePage': (context) => ScoreScreen(),
        'splash': (context) => SplashScreenPage(),
      },
    );
  }
}
