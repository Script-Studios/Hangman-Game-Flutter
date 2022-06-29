import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hangman/screens/onboard.dart';
import 'package:flutter_hangman/utilities/appConfiguration.dart';
import 'package:flutter_hangman/utilities/connectivity.dart';
import 'package:flutter_hangman/utilities/score_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with TickerProviderStateMixin {
  bool showPresents = false, showHangman = false;
  int hangState = -1;
  Animation<int> iconAnim;
  AnimationController _cont;
  bool onboardingFinished;

  void checkIfOnboardingFinished() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    onboardingFinished = pref.getBool("onboardingFinished") ?? false;
    if (!onboardingFinished) {
      pref.setBool("onboardingFinished", true);
    }
  }

  void init() async {
    ScoreDatabase.init();
    await AppConnectivity.init();
    await UserAccount.init();
    await UserAccount.setLocalThemes();
  }

  @override
  void initState() {
    checkIfOnboardingFinished();
    init();
    Timer(Duration(milliseconds: 250), () async {
      if (this.mounted) {
        setState(() {
          showPresents = true;
        });
        await Future.delayed(Duration(milliseconds: 300));
        _cont.forward();
      }
    });
    _cont = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 2250));
    iconAnim = new Tween<int>(begin: 0, end: 6).animate(_cont);
    _cont.addListener(() {
      if (_cont.value >= (hangState + 1) / 7 && hangState < 6) {
        setState(() {
          hangState += 1;
        });
      }
      if (hangState >= 6) {
        setState(() {
          showHangman = true;
        });
      }
    });
    _cont.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future.delayed(Duration(milliseconds: 500));
        if (onboardingFinished ?? false) {
          Navigator.pushReplacementNamed(context, "homePage");
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OnBoardingPage(true),
            ),
          );
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff0b0f1b),
      body: Column(
        children: [
          SizedBox(height: size.height * 0.1),
          Container(
            height: size.height * 0.25,
            child: Image.asset("images/ss.gif"),
            color: Color(0xff0b0f1b),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: AnimatedCrossFade(
              firstChild: Container(),
              secondChild: Text(
                "PRESENTS",
                style: TextStyle(color: Colors.cyan[800], fontSize: 25),
              ),
              crossFadeState: showPresents
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 500),
              firstCurve: Curves.ease,
              secondCurve: Curves.ease,
            ),
          ),
          hangState >= 0
              ? Container(
                  height: size.height * 0.4,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'images/$hangState.png',
                      gaplessPlayback: true,
                    ),
                  ),
                )
              : SizedBox(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: AnimatedCrossFade(
              firstChild: Container(),
              secondChild: Text(
                "HANG MAN",
                style: TextStyle(color: Colors.cyan[800], fontSize: 40),
              ),
              crossFadeState: showHangman
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 500),
              firstCurve: Curves.bounceInOut,
              secondCurve: Curves.bounceIn,
            ),
          ),
        ],
      ),
    );
  }
}
