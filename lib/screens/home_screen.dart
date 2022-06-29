import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_hangman/components/action_button.dart';
import 'package:flutter_hangman/screens/drawer.dart';
import 'package:flutter_hangman/screens/score_screen.dart';
import 'package:flutter_hangman/screens/select_themes.dart';
import 'package:flutter_hangman/utilities/appConfiguration.dart';
import 'package:flutter_hangman/utilities/connectivity.dart';
import 'package:flutter_hangman/utilities/hangman_words.dart';
import 'game_screen.dart';
import 'package:flutter_hangman/utilities/themes.dart' as th;
import 'package:rate_my_app/rate_my_app.dart';
import 'package:flutter_hangman/screens/selectMode.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  th.Theme selectedTheme;
  GameMode mode = GameMode.normal;
  GlobalKey<ScaffoldState> _scafoldKey = new GlobalKey<ScaffoldState>();

  void rateMyAppCheck() async {
    RateMyApp rateMyApp = new RateMyApp(
      googlePlayIdentifier: "com.scriptstudios.hangman",
      minLaunches: 4,
      remindLaunches: 5,
      remindDays: 3,
      minDays: 0,
    );
    await rateMyApp.init();
    if (rateMyApp.shouldOpenDialog) {
      rateMyApp.showRateDialog(
        context,
        title: "Rate this App",
        message:
            'If you enjoy playing Hangman, would you mind taking a moment to rate it? It wouldn’t take more than a minute. Thanks for your support!',
        listener: (button) {
          return true;
        },
        dialogStyle: DialogStyle(
          messageStyle: TextStyle(color: Colors.white),
          titleStyle: TextStyle(color: Colors.white),
        ),
      );
    } else {
      print("Waiting for rating dialog");
    }
  }

  @override
  void initState() {
    super.initState();
    rateMyAppCheck();
    if (UserAccount.selectedTheme?.isNotEmpty ?? false) {
      int index = th.Themes.themes
          .indexWhere((theme) => theme.id == UserAccount.selectedTheme);
      if (index >= 0) {
        selectedTheme = th.Themes.themes[index];
      } else {
        selectedTheme = th.Themes.themes.first;
      }
    } else {
      selectedTheme = th.Themes.themes.first;
    }
  }

  void themeSelected(th.Theme selectedTheme) {
    setState(() {
      this.selectedTheme = selectedTheme;
    });
    UserAccount.selectedTheme = selectedTheme.id;
  }

  void modeSelected(GameMode mode) {
    setState(() {
      this.mode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppConnectivity.context = context;
    double height = MediaQuery.of(context).size.height,
        width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scafoldKey,
      endDrawer: DrawerPage(),
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Row(
            children: [
              Spacer(flex: 2),
              Text(
                'HANGMAN',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 58.0,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 3.0),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  _scafoldKey.currentState.openEndDrawer();
                },
              ),
            ],
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset(
                'images/gallow.png',
                height: height * 0.5,
              ),
            ),
          ),
          Spacer(),
          Center(
            child: Column(
              children: <Widget>[
                Container(
                  width: 155,
                  height: 64,
                  child: ActionButton(
                    buttonTitle: 'Start',
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreenWithAd(
                            hangmanObject: HangmanWords(
                              selectedTheme,
                            ),
                            mode: mode,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 45),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 155,
                      height: 64,
                      child: ActionButton(
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Change Theme",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            Spacer(),
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                selectedTheme.name,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectThemesPage(
                                  selectedTheme, themeSelected, mode),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 155,
                      height: 64,
                      child: ActionButton(
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Change Mode",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            Spacer(),
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                modeName[mode],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 22),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SelectModePage(mode, modeSelected),
                            ),
                          );
                        },
                      ),
                    ),
                    /* FlatButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectThemesPage(
                                themes, selectedTheme, themeSelected, mode),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedTheme.name,
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(Icons.arrow_right, color: Colors.white),
                        ],
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SelectModePage(mode, modeSelected),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            modeName[mode],
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(Icons.arrow_right, color: Colors.white),
                        ],
                      ),
                    ), */
                  ],
                ),
                /* Container(
                  width: 155,
                  height: 64,
                  child: ActionButton(
                    buttonTitle: 'High Scores',
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScoreScreen(),
                        ),
                      );
                    },
                  ),
                ), */
              ],
            ),
          ),
          Spacer(),
        ],
      )),
    );
  }
}
