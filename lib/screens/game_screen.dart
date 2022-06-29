import 'dart:async';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hangman/screens/selectMode.dart';
import 'package:flutter_hangman/utilities/alphabet.dart';
import 'package:flutter_hangman/components/word_button.dart';
import 'package:flutter_hangman/utilities/constants.dart';
import 'package:flutter_hangman/utilities/functions.dart';
import 'package:flutter_hangman/utilities/hangman_words.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:math';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_hangman/utilities/score_db.dart';
import 'package:flutter_hangman/utilities/user_scores.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_animation_set/widget/transition_animations.dart';
import 'package:flutter_animation_set/widget/behavior_animations.dart';

class GameScreenWithAd extends StatelessWidget {
  GameScreenWithAd({@required this.hangmanObject, @required this.mode});

  final HangmanWords hangmanObject;
  final GameMode mode;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GameScreen(
            hangmanObject: hangmanObject,
            mode: mode,
          ),
        ),
        /* Container(
          color: Color(0xFF421b9b),
          width: double.maxFinite,
          child: AdmobBanner(
            adSize: AdmobBannerSize.BANNER,
            adUnitId: adUnitId[ADType.Banner],
            // TODO: remove the test string when for production //Test banner ad id: "ca-app-pub-3940256099942544/6300978111"
          ),
        ), */
      ],
    );
  }
}

class GameScreen extends StatefulWidget {
  GameScreen({@required this.hangmanObject, @required this.mode});

  final HangmanWords hangmanObject;
  final GameMode mode;

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Widget> lives = [
        Container(
          child: YYPumpingHeart(),
        ),
        Container(
          child: YYPumpingHeart(),
        ),
        Container(
          child: YYPumpingHeart(),
        ),
      ],
      lifeGone = new List<Widget>();
  int initialLives = 3;
  Alphabet englishAlphabet = Alphabet();
  String word;
  String hiddenWord;
  List<String> wordList = [];
  List<int> hintLetters = [];
  List<bool> buttonStatus;
  bool hintStatus;
  int hangState = 0;
  int score = 0;
  bool finishedGame = false;
  bool resetGame = false;
  String alphabet = "";
  bool hasVibration = false, hasCustomVibration = false;
  AdmobReward rewardAd;
  bool rewardAdAvailable = false;
  bool rewarded = false;
  int hints = 3;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool showNumbers = false;
  int timeSeconds;
  Timer gameTimer;

  void newGame() {
    setState(() {
      widget.hangmanObject.resetWords();
      englishAlphabet = Alphabet();
      lives = [
        Container(
          child: YYPumpingHeart(),
        ),
        Container(
          child: YYPumpingHeart(),
        ),
        Container(
          child: YYPumpingHeart(),
        ),
      ];
      lifeGone = new List<Widget>();
      score = 0;
      hints = 3;
      finishedGame = false;
      resetGame = false;
      initWords();
    });
  }

  Widget createButton(int index,
      {bool wildCard, String extra, Function onPress}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5, vertical: 6.0),
      child: Center(
        child: WordButton(
          buttonTitle: extra ?? englishAlphabet.alphabet[index].toUpperCase(),
          onPress: onPress ??
              (buttonStatus[index] == null ? () => wordPress(index) : null),
          status: wildCard != null ? wildCard : buttonStatus[index],
        ),
      ),
    );
  }

  void returnHomePage() {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void gotHintReward() {
    print(
        "-------------------------------hint Rewarded-------------------------------");
    int rand = Random().nextInt(hintLetters.length);
    hints -= 1;
    rewardAd.load();
    wordPress(englishAlphabet.alphabet
        .indexOf(wordList[hintLetters[rand]].toLowerCase()));
    /* if (hints == 0) {
      Timer(Duration(seconds: 30), () {
        if (this.mounted && hints < 3) {
          setState(() {
            hints += 1;
          });
        }
      });
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!New Hint Timer started");
    } */
  }

  void initWords() {
    finishedGame = false;
    resetGame = false;
    hintStatus = true;
    if (widget.mode == GameMode.timed) {
      timeSeconds = 60;
      if (gameTimer != null && gameTimer.isActive) {
        gameTimer.cancel();
      }
      gameTimer = new Timer.periodic(Duration(seconds: 1), (timer) {
        if (timeSeconds > 0) {
          timeSeconds -= 1;
          if (this.mounted) setState(() {});
          if (timeSeconds == 0) gameTimer.cancel();
        }
      });
    }
    hangState = 0;
    buttonStatus = List.generate(36, (index) {
      return null;
    });
    wordList = [];
    hintLetters = [];
    word = widget.hangmanObject.getWord();
//    print
    print('this is word ' + word);
    if (word.length != 0) {
      hiddenWord = widget.hangmanObject.getHiddenWord(word);
    } else {
      returnHomePage();
    }

    for (int i = 0; i < word.length; i++) {
      if (hiddenWord[i] == "_") {
        wordList.add(word[i]);
        hintLetters.add(i);
      } else {
        wordList.add("");
      }
    }
  }

  void wordPress(int index) {
    if (lives.length == 0) {
      returnHomePage();
    }

    if (finishedGame) {
      setState(() {
        resetGame = true;
      });
      return;
    }

    bool check = false;
    setState(() {
      for (int i = 0; i < wordList.length; i++) {
        if (wordList[i].toLowerCase() == englishAlphabet.alphabet[index]) {
          check = true;
          wordList[i] = '';
          hiddenWord = replaceCharAt(i, hiddenWord, word[i]);
        }
      }
      for (int i = 0; i < wordList.length; i++) {
        if (wordList[i] == '') {
          hintLetters.remove(i);
        }
      }
      if (!check) {
        hangState += 1;
        if (hasVibration && hasCustomVibration) {
          Vibration.vibrate(duration: 200);
        } else if (hasVibration) {
          Vibration.vibrate();
        }
      }

      if (hangState == 6) {
        if (gameTimer != null && gameTimer.isActive) {
          gameTimer.cancel();
        }
        finishedGame = true;
        lives.removeLast();
        setState(() {
          lifeGone.add(
            Container(
              child: YYSingleLike(),
            ),
          );
        });
        lifeRemoved(initialLives - lives.length - 1);

        if (lives.length < 1) {
          Alert(
              style: kGameOverAlertStyle,
              context: context,
              title: "Game Over!",
              desc: "Your score is $score",
              buttons: [
                DialogButton(
                  width: 62,
                  onPressed: () {
                    if (score > 0) {
                      Score userScore = Score(
                          id: widget.hangmanObject.theme.id,
                          scoreDate: DateTime.now(),
                          userScore: score);
                      ScoreDatabase.insertScore(userScore);
                    }
                    returnHomePage();
                  },
                  child: Icon(
                    MdiIcons.home,
                    size: 30.0,
                  ),
                  color: kDialogButtonColor,
                ),
                DialogButton(
                  width: 62,
                  onPressed: () {
                    newGame();
                    Navigator.pop(context);
                  },
                  child: Icon(MdiIcons.refresh, size: 30.0),
                  color: kDialogButtonColor,
                ),
              ]).show();
        } else {
          Alert(
            context: context,
            style: kFailedAlertStyle,
            type: AlertType.error,
            title: word,
            buttons: [
              DialogButton(
                radius: BorderRadius.circular(10),
                child: Icon(
                  MdiIcons.arrowRightThick,
                  size: 30.0,
                ),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                    initWords();
                  });
                },
                width: 127,
                color: kDialogButtonColor,
                height: 52,
              ),
            ],
          ).show();
        }
      }

      buttonStatus[index] = check;
      if (hintLetters.isEmpty) {
        finishedGame = true;
        if (gameTimer != null && gameTimer.isActive) {
          gameTimer.cancel();
        }
        Alert(
          context: context,
          style: kSuccessAlertStyle,
          type: AlertType.success,
          title: word,
//          desc: "You guessed it right!",
          buttons: [
            DialogButton(
              radius: BorderRadius.circular(10),
              child: Icon(
                MdiIcons.arrowRightThick,
                size: 30.0,
              ),
              onPressed: () {
                setState(() {
                  score += expectedScore();
                  Navigator.pop(context);
                  initWords();
                });
              },
              width: 127,
              color: kDialogButtonColor,
              height: 52,
            )
          ],
        ).show();
      }
    });
  }

  void lifeRemoved(int i) async {
    await Future.delayed(Duration(milliseconds: 1500));
    setState(() {
      lifeGone[i] = Spacer();
    });
  }

  void startHintAd() async {
    bool adsAvailable = await rewardAd.isLoaded;
    if (adsAvailable) {
      Alert(
        context: context,
        style: kSuccessAlertStyle,
        type: AlertType.info,
        title: "",
        buttons: [
          DialogButton(
            radius: BorderRadius.circular(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Watch a Video",
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                SizedBox(width: 15),
                Icon(Icons.ondemand_video),
              ],
            ),
            onPressed: () async {
              if (adsAvailable) {
                rewardAd.show();
              } else {
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      "No Videos available. Try after some time",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
                rewardAd.load();
                print("Reward Ad Not Loaded");
              }
              Navigator.pop(context);
            },
            color: kDialogButtonColor,
            height: 52,
          ),
        ],
      ).show();
    } else {
      bool _poped = false;
      Alert(
        context: context,
        title: "Loading...",
        buttons: [],
        type: AlertType.info,
        style: kSuccessAlertStyle,
      ).show().then((value) {
        _poped = true;
      });
      await Future.delayed(Duration(milliseconds: 3000));
      if (!_poped) {
        Navigator.pop(context);
        gotHintReward();
      }
    }
  }

  void startMusic() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool music = pref.getBool("music") ?? true;
    if (music) {
      Flame.bgm.initialize();
      Flame.bgm.play("gameAudio1.mp3", volume: 0.1);
    }
  }

  int expectedScore() {
    if (widget.mode == GameMode.normal) {
      return 7 - hangState;
    } else {
      return (timeSeconds / 5).floor();
    }
  }

  @override
  void initState() {
    super.initState();
    startMusic();
    initWords();
    rewardAd = AdmobReward(
        adUnitId: adUnitId[ADType.Reward],
        //reward ad test ad id: "ca-app-pub-3940256099942544/5224354917"
        listener: (AdmobAdEvent event, Map<String, dynamic> value) {
          print("AD listener: $event  $value---------------------");
          if (event == AdmobAdEvent.rewarded) {
            rewarded = true;
          } else if (event == AdmobAdEvent.closed) {
            if (rewarded) {
              gotHintReward();
              rewarded = false;
            }
          } else if (event == AdmobAdEvent.failedToLoad) {
            print("Failed to load the reward Ad");
          }
        });
    rewardAd.load();
    rewardAd.isLoaded.then((loaded) {
      setState(() {
        rewardAdAvailable = loaded;
        print("rewardAdAvailable  $rewardAdAvailable");
      });
    });
    Vibration.hasVibrator().then((value) {
      hasVibration = value;
    });
    Vibration.hasCustomVibrationsSupport().then((value) {
      hasCustomVibration = value;
    });
  }

  @override
  void dispose() {
    if (Flame.bgm.isPlaying) Flame.bgm.stop();
    Flame.bgm.dispose();
    if (gameTimer != null && gameTimer.isActive) {
      gameTimer.cancel();
    }
    rewardAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (resetGame) {
      setState(() {
        initWords();
      });
    }
    return WillPopScope(
      onWillPop: () {
        return Alert(
          context: context,
          style: kSuccessAlertStyle,
          type: AlertType.warning,
          title: "Your current score would be lost!!\nSure to quit?",
          buttons: [
            DialogButton(
              radius: BorderRadius.circular(10),
              child: Icon(
                Icons.close,
                size: 30.0,
                color: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              width: 127,
              color: kDialogButtonColor,
              height: 52,
            ),
            DialogButton(
              radius: BorderRadius.circular(10),
              child: Icon(
                Icons.check,
                size: 30.0,
              ),
              onPressed: () {
                if (score > 0) {
                  Score userScore = Score(
                      id: widget.hangmanObject.theme.id,
                      scoreDate: DateTime.now(),
                      userScore: score);
                  ScoreDatabase.insertScore(userScore);
                }
                Navigator.pop(context);
                Navigator.pop(context);
              },
              width: 127,
              color: kDialogButtonColor,
              height: 52,
            )
          ],
        ).show();
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                  flex: 3,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6.0, 8.0, 6.0, 8.0),
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width / 3,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: lives + lifeGone,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 25),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: score.toString(),
                                      style: kWordCounterTextStyle,
                                    ),
                                    TextSpan(
                                      text: " + ${expectedScore()}",
                                      style: kWordCounterTextStyle.copyWith(
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Spacer(),
                            Container(
                              child: Stack(
                                children: [
                                  IconButton(
                                    tooltip: 'Hint',
                                    iconSize: 39,
                                    icon: Icon(MdiIcons.lightbulb),
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onPressed: hints > 0 ? startHintAd : null,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.yellow,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        hints.toString(),
                                        style: TextStyle(
                                          color: Color(0xFF421b9b),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ) /* 
                                : SizedBox() */
                            ,
                          ],
                        ),
                      ),
                      widget.mode == GameMode.timed
                          ? Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Icon(
                                      Icons.timer,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Text(
                                      timeSeconds.toString(),
                                      style: TextStyle(
                                        color: timeSeconds <= 5
                                            ? Colors.red
                                            : Colors.white,
                                        fontSize: 25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: FittedBox(
                            child: Image.asset(
                              'images/$hangState.png',
                              height: 1001,
                              width: 991,
                              gaplessPlayback: true,
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 30.0),
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              hiddenWord,
                              style: kWordTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              Container(
                padding: EdgeInsets.fromLTRB(6.0, 2.0, 6.0, 10.0),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  //columnWidths: {1: FlexColumnWidth(10)},
                  children: showNumbers
                      ? [
                          TableRow(children: [
                            TableCell(
                              child: Text(''),
                            ),
                            TableCell(
                              child: Text(''),
                            ),
                            TableCell(
                              child: createButton(26),
                            ),
                            TableCell(
                              child: createButton(27),
                            ),
                            TableCell(
                              child: createButton(28),
                            ),
                            TableCell(
                              child: Text(''),
                            ),
                            TableCell(
                              child: Text(''),
                            ),
                          ]),
                          TableRow(children: [
                            TableCell(
                              child: Text(''),
                            ),
                            TableCell(
                              child: Text(''),
                            ),
                            TableCell(
                              child: createButton(29),
                            ),
                            TableCell(
                              child: createButton(30),
                            ),
                            TableCell(
                              child: createButton(31),
                            ),
                            TableCell(
                              child: Text(''),
                            ),
                            TableCell(
                              child: Text(''),
                            ),
                          ]),
                          TableRow(children: [
                            TableCell(
                              child: Text(''),
                            ),
                            TableCell(
                              child: Text(''),
                            ),
                            TableCell(
                              child: createButton(32),
                            ),
                            TableCell(
                              child: createButton(33),
                            ),
                            TableCell(
                              child: createButton(34),
                            ),
                            TableCell(
                              child: Text(''),
                            ),
                            TableCell(
                              child: Text(''),
                            ),
                          ]),
                          TableRow(children: [
                            TableCell(
                              child: Text(''),
                            ),
                            TableCell(
                              child: Text(''),
                            ),
                            TableCell(
                              child: Text(''),
                            ),
                            TableCell(
                              child: createButton(35),
                            ),
                            TableCell(
                              child: Text(''),
                            ),
                            TableCell(
                              child: Text(''),
                            ),
                            TableCell(
                              child: createButton(25, extra: "AB", onPress: () {
                                setState(() {
                                  showNumbers = false;
                                });
                              }, wildCard: true),
                            ),
                          ]),
                        ]
                      : [
                          TableRow(children: [
                            TableCell(
                              child: createButton(0),
                            ),
                            TableCell(
                              child: createButton(1),
                            ),
                            TableCell(
                              child: createButton(2),
                            ),
                            TableCell(
                              child: createButton(3),
                            ),
                            TableCell(
                              child: createButton(4),
                            ),
                            TableCell(
                              child: createButton(5),
                            ),
                            TableCell(
                              child: createButton(6),
                            ),
                          ]),
                          TableRow(children: [
                            TableCell(
                              child: createButton(7),
                            ),
                            TableCell(
                              child: createButton(8),
                            ),
                            TableCell(
                              child: createButton(9),
                            ),
                            TableCell(
                              child: createButton(10),
                            ),
                            TableCell(
                              child: createButton(11),
                            ),
                            TableCell(
                              child: createButton(12),
                            ),
                            TableCell(
                              child: createButton(13),
                            ),
                          ]),
                          TableRow(children: [
                            TableCell(
                              child: createButton(14),
                            ),
                            TableCell(
                              child: createButton(15),
                            ),
                            TableCell(
                              child: createButton(16),
                            ),
                            TableCell(
                              child: createButton(17),
                            ),
                            TableCell(
                              child: createButton(18),
                            ),
                            TableCell(
                              child: createButton(19),
                            ),
                            TableCell(
                              child: createButton(20),
                            ),
                          ]),
                          TableRow(children: [
                            TableCell(
                              child: createButton(21),
                            ),
                            TableCell(
                              child: createButton(22),
                            ),
                            TableCell(
                              child: createButton(23),
                            ),
                            TableCell(
                              child: createButton(24),
                            ),
                            TableCell(
                              child: createButton(25),
                            ),
                            TableCell(
                              child: createButton(25, extra: "12", onPress: () {
                                setState(() {
                                  showNumbers = true;
                                });
                              }, wildCard: true),
                            ),
                            TableCell(
                              child: Text(''),
                            ),
                          ]),
                        ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
