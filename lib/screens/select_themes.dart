import 'dart:math';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hangman/components/action_button.dart';
import 'package:flutter_hangman/screens/game_screen.dart';
import 'package:flutter_hangman/screens/selectMode.dart';
import 'package:flutter_hangman/utilities/appConfiguration.dart';
import 'package:flutter_hangman/utilities/connectivity.dart';
import 'package:flutter_hangman/utilities/constants.dart';
import 'package:flutter_hangman/utilities/hangman_words.dart';
import 'package:flutter_hangman/utilities/loading.dart';
import 'package:flutter_hangman/utilities/themes.dart' as th;
import 'package:rflutter_alert/rflutter_alert.dart';

class SelectThemesPage extends StatefulWidget {
  th.Theme selectedTheme;
  final Function(th.Theme) themeSelected;
  final GameMode mode;
  SelectThemesPage(this.selectedTheme, this.themeSelected, this.mode);
  @override
  _SelectThemesPageState createState() => _SelectThemesPageState();
}

class _SelectThemesPageState extends State<SelectThemesPage> {
  AdmobReward rewardAd;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(),
      _scaffoldKey2 = new GlobalKey<ScaffoldState>();
  List<th.Theme> themes;
  bool rewarded = false;
  bool _loadingCustomThemes = true, _loadingMyThemes = true;
  List<th.Theme> customThemes = [], myThemes = [];
  List<bool> myThemeOpen = [], themeSaved = [];
  List<TextEditingController> _controllers = [];
  Firestore firestore = Firestore.instance;
  ScrollController _scrollController = new ScrollController();
  int coins = UserAccount.coins;
  List<String> themesOpen = UserAccount.themesOpen;

  @override
  void initState() {
    super.initState();
    getCustomThemes();
    getMyThemes();
    int l = themesOpen.length;
    th.Themes.themes.forEach((e) {
      if (e.minScore == 0 && !themesOpen.contains(e.id)) {
        themesOpen.add(e.id);
      }
    });
    if (themesOpen.length > l) UserAccount.themesOpen = themesOpen;
    themes = List.from(th.Themes.themes);
    rewardAd = AdmobReward(
        adUnitId: adUnitId[ADType.Reward],
        //reward ad test ad id: "ca-app-pub-3940256099942544/5224354917"
        listener: (AdmobAdEvent event, Map<String, dynamic> value) {
          print("AD listener: $event  $value---------------------");
          if (event == AdmobAdEvent.rewarded) {
            rewarded = true;
            print(
                "-------------------------------Rewarded  $rewarded-------------------------");
          } else if (event == AdmobAdEvent.closed) {
            if (rewarded) {
              print("-------------yes i got rewarded-----------------");
              gotReward();
            }
          } else if (event == AdmobAdEvent.failedToLoad) {
            print("Failed to load the reward Ad");
          }
        });
    rewardAd.load();
  }

  void gotReward() {
    int index = Random().nextInt(themes.length);
    rewardAd.load();
    Alert(
      context: context,
      type: AlertType.info,
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: false,
        isOverlayTapDismiss: true,
        animationDuration: Duration(milliseconds: 500),
        backgroundColor: Color(0xFF2C1E68),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        titleStyle: TextStyle(
          color: Color(0xFF00e676),
          fontWeight: FontWeight.bold,
          fontSize: 30.0,
          letterSpacing: 1.5,
        ),
      ),
      title: "You got:\n${themes[index].name}",
      buttons: [
        DialogButton(
          radius: BorderRadius.circular(10),
          color: Color(0x00000000),
          height: 52,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Play",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              SizedBox(width: 15),
              Icon(Icons.play_arrow),
            ],
          ),
          onPressed: () async {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameScreen(
                  mode: widget.mode,
                  hangmanObject: HangmanWords(
                    themes[index],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ).show();
  }

  void showRandomThemeAlert() {
    Alert(
      context: context,
      type: AlertType.info,
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: false,
        isOverlayTapDismiss: true,
        animationDuration: Duration(milliseconds: 500),
        backgroundColor: Color(0xFF2C1E68),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        titleStyle: TextStyle(
          color: Color(0xFF00e676),
          fontWeight: FontWeight.bold,
          fontSize: 30.0,
          letterSpacing: 1.5,
        ),
      ),
      title: "Play a Random theme once",
      buttons: [
        DialogButton(
          radius: BorderRadius.circular(10),
          color: Color(0x00000000),
          height: 52,
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
            if (await rewardAd.isLoaded) {
              rewardAd.show();
            } else {
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    "No videos available right now. Please try again later.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
              rewardAd.load();
            }
            Navigator.pop(context);
          },
        ),
      ],
    ).show();
  }

  void saveTheme(int index) {
    th.Theme theme = myThemes[index];
    if (theme.ref == null) {
      theme.ref = firestore.collection("themes").document();
      theme.id = theme.ref.documentID;
      var data = theme.toJson();
      data.addAll({"email": UserAccount.me.email});
      theme.ref.setData(data);
    } else {
      var data = theme.toJson();
      data.addAll({"email": UserAccount.me.email});
      theme.ref.setData(data);
    }
    themeSaved[index] = true;
  }

  void showErrorMessage(String message) {
    _scaffoldKey2.currentState.showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  bool validate(th.Theme theme) {
    bool valid = theme.name.isNotEmpty;
    if (valid) {
      valid = valid && theme.questions.every((q) => q.isNotEmpty);
      if (valid) {
        valid = valid && theme.questions.length >= 10;
        if (!valid) {
          showErrorMessage("Add atleast 10 question words");
        }
      } else {
        showErrorMessage("Make sure every question word isn't empty");
      }
    } else {
      showErrorMessage("Enter name of the theme");
    }
    return valid;
  }

  Future<void> getMyThemes() async {
    setState(() {
      _loadingMyThemes = true;
    });
    if (UserAccount.me != null) {
      QuerySnapshot qs = await firestore
          .collection("themes")
          .where("email", isEqualTo: UserAccount.me.email)
          .getDocuments();
      qs.documents.forEach((doc) {
        myThemes.add(new th.Theme.fromJson(doc));
        myThemeOpen.add(false);
        themeSaved.add(true);
      });
    }
    setState(() {
      _loadingMyThemes = false;
    });
  }

  Future<void> getCustomThemes() async {
    setState(() {
      customThemes.clear();
      _loadingCustomThemes = true;
    });
    QuerySnapshot qs = await firestore.collection("themes").getDocuments();
    qs.documents.forEach((doc) {
      customThemes.add(new th.Theme.fromJson(doc));
    });
    setState(() {
      _loadingCustomThemes = false;
    });
  }

  void passwordAlert(th.Theme theme) {
    TextEditingController _controller = new TextEditingController();
    Alert(
      context: context,
      title: "Enter Password",
      style: kSuccessAlertStyle,
      type: AlertType.warning,
      buttons: <DialogButton>[
        DialogButton(
          radius: BorderRadius.circular(10),
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          color: kActionButtonColor,
        ),
        DialogButton(
          radius: BorderRadius.circular(10),
          child: Text(
            "Submit",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          onPressed: () {
            if (_controller.value.text == theme.password) {
              setState(() {
                widget.selectedTheme = theme;
              });
              Navigator.pop(context);
            }
          },
          color: kActionButtonColor,
        ),
      ],
      content: TextFormField(
        controller: _controller,
        decoration: InputDecoration(labelText: "Password"),
        style: TextStyle(color: Colors.white),
        autovalidate: true,
        validator: (s) {
          if (s.isNotEmpty && s != theme.password)
            return "Password Incorrect";
          else
            return null;
        },
      ),
    ).show();
  }

  void editTheme(int index) {
    setState(() {
      for (int i = 0; i < myThemeOpen.length; i++) {
        if (myThemeOpen[i]) {
          myThemeOpen[i] = false;
        }
      }
      myThemeOpen[index] = true;
      themeSaved[index] = false;
      if (_controllers.length > myThemes[index].questions.length)
        _controllers =
            _controllers.sublist(0, myThemes[index].questions.length);
      while (_controllers.length < myThemes[index].questions.length) {
        _controllers.add(TextEditingController());
      }
      for (int i = 0; i < _controllers.length; i++) {
        _controllers[i].text = myThemes[index].questions[i];
      }
    });
  }

  void addTheme() {
    setState(() {
      for (int i = 0; i < myThemeOpen.length; i++) {
        if (myThemeOpen[i]) {
          myThemeOpen[i] = false;
        }
      }
      myThemes.add(new th.Theme("", "", [], 0, password: ""));
      myThemeOpen.add(true);
      themeSaved.add(false);
    });
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 250), curve: Curves.ease);
  }

  void openTheme(th.Theme theme) {
    setState(() {
      coins -= theme.minScore;
      themesOpen.add(theme.id);
      widget.selectedTheme = theme;
      UserAccount.themesOpen = themesOpen;
      th.Themes.sortThemes();
      themes = List.from(th.Themes.themes);
    });
    UserAccount.coins = coins;
  }

  @override
  void dispose() {
    rewardAd.dispose();
    _controllers.forEach((e) {
      e.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color mainPurpleColor = Color(0xFF421b9b);
    var size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          bottom: TabBar(
            labelStyle: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w300,
                fontFamily: 'PatrickHand',
                letterSpacing: 3.0),
            isScrollable: true,
            tabs: <Tab>[
              Tab(
                text: "Select Theme",
              ),
              Tab(
                text: "Custom Theme",
              ),
              Tab(
                text: "My Themes",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Scaffold(
              key: _scaffoldKey,
              floatingActionButton: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.white),
                ),
                elevation: 20,
                onPressed: () {
                  widget.themeSelected(widget.selectedTheme);
                  Navigator.pop(context);
                },
                color: mainPurpleColor,
                child: Text(
                  "DONE",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 3.0),
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 15),
                        Text(
                          "Coins: $coins",
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.shuffle),
                          onPressed: showRandomThemeAlert,
                        ),
                      ],
                    ),
                    Expanded(
                      child: GridView.count(
                        physics: BouncingScrollPhysics(),
                        crossAxisCount: 2,
                        children: themes.map<Widget>((e) {
                              bool open = themesOpen.contains(e.id);
                              return GestureDetector(
                                onTap: open
                                    ? () {
                                        setState(() {
                                          widget.selectedTheme = e;
                                        });
                                      }
                                    : null,
                                child: Stack(
                                  children: <Widget>[
                                        Opacity(
                                          opacity: open
                                              ? (widget.selectedTheme.id == e.id
                                                  ? 1
                                                  : 0.5)
                                              : 0.1,
                                          child: Container(
                                            height: 150,
                                            margin: EdgeInsets.all(15),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Text(
                                              e.name,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: mainPurpleColor,
                                                  fontSize: 25.0,
                                                  fontWeight: FontWeight.w300,
                                                  letterSpacing: 3.0),
                                            ),
                                          ),
                                        ),
                                      ] +
                                      (open
                                          ? <Widget>[]
                                          : <Widget>[
                                              coins >= e.minScore
                                                  ? Positioned(
                                                      top: 20,
                                                      right: 20,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          openTheme(e);
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 5),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              10,
                                                            ),
                                                            color: Colors.green,
                                                          ),
                                                          child: Text(
                                                            "Open",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              Positioned(
                                                bottom: 20,
                                                right: 20,
                                                child: Icon(
                                                  Icons.lock_outline,
                                                  color: Colors.white,
                                                  size: 25,
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 20,
                                                left: 20,
                                                child: Text(
                                                  "$coins/${e.minScore}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: coins >= e.minScore
                                                        ? Colors.green
                                                        : Colors.white,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                ),
                              );
                            }).toList() +
                            <Widget>[
                              SizedBox(height: 150),
                              SizedBox(height: 150),
                            ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Scaffold(
              floatingActionButton: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.white),
                ),
                elevation: 20,
                onPressed: () {
                  widget.themeSelected(widget.selectedTheme);
                  Navigator.pop(context);
                },
                color: mainPurpleColor,
                child: Text(
                  "DONE",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 3.0),
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: !AppConnectivity.isConnected
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: size.width,
                                  margin: EdgeInsets.symmetric(vertical: 15),
                                  child: Text(
                                    "No Internet Connected!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                                Container(
                                  width: 155,
                                  height: 64,
                                  child: ActionButton(
                                    buttonTitle: 'Refresh',
                                    onPress: () {
                                      if (AppConnectivity.isConnected) {
                                        getCustomThemes();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          : _loadingCustomThemes
                              ? Center(
                                  child: Text(
                                    "Loading...",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 25),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: () async {
                                    getCustomThemes();
                                  },
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    children: customThemes.map<Widget>((e) {
                                          bool open = coins >= e.minScore;
                                          bool protected = e.password != null &&
                                              e.password.isNotEmpty;
                                          return GestureDetector(
                                            onTap: open
                                                ? () {
                                                    if (protected &&
                                                        widget.selectedTheme
                                                                .id !=
                                                            e.id) {
                                                      passwordAlert(e);
                                                    } else {
                                                      setState(() {
                                                        widget.selectedTheme =
                                                            e;
                                                      });
                                                    }
                                                  }
                                                : null,
                                            child: Stack(
                                              children: <Widget>[
                                                    Opacity(
                                                      opacity: open
                                                          ? (widget.selectedTheme
                                                                      .id ==
                                                                  e.id
                                                              ? 1
                                                              : 0.5)
                                                          : 0.1,
                                                      child: Container(
                                                        height: 150,
                                                        margin:
                                                            EdgeInsets.all(15),
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child: Text(
                                                          e.name,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                                  mainPurpleColor,
                                                              fontSize: 25.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              letterSpacing:
                                                                  3.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ] +
                                                  (protected
                                                      ? <Widget>[
                                                          Positioned(
                                                            bottom: 20,
                                                            right: 20,
                                                            child: Icon(
                                                              Icons
                                                                  .lock_outline,
                                                              color: widget
                                                                          .selectedTheme
                                                                          .id ==
                                                                      e.id
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .white,
                                                            ),
                                                          ),
                                                        ]
                                                      : open
                                                          ? <Widget>[]
                                                          : <Widget>[
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .lock_outline,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 40,
                                                                    ),
                                                                    Text(
                                                                      "Score:\n$coins/${e.minScore}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            40,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ]),
                                            ),
                                          );
                                        }).toList() +
                                        <Widget>[
                                          SizedBox(height: 150),
                                          SizedBox(height: 150),
                                        ],
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ),
            Scaffold(
              key: _scaffoldKey2,
              floatingActionButton: UserAccount.me == null
                  ? null
                  : RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.white),
                      ),
                      elevation: 20,
                      onPressed: () {
                        addTheme();
                      },
                      color: mainPurpleColor,
                      child: Text(
                        "Add",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 3.0),
                      ),
                    ),
              body: !AppConnectivity.isConnected
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width,
                          margin: EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            "No Internet Connected!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        Container(
                          width: 155,
                          height: 64,
                          child: ActionButton(
                            buttonTitle: 'Refresh',
                            onPress: () {
                              if (AppConnectivity.isConnected) {
                                getCustomThemes();
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  : UserAccount.me == null
                      ? Center(
                          child: Container(
                            height: 64,
                            child: ActionButton(
                              buttonTitle: 'Login with Google',
                              onPress: () async {
                                Loading.start(context);
                                await UserAccount.googleSignIn();
                                Loading.stop(context);
                                getMyThemes();
                              },
                            ),
                          ),
                        )
                      : _loadingMyThemes
                          ? Center(
                              child: Text(
                                "Loading...",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemCount: myThemes.length,
                              itemBuilder: (context, i) {
                                var t = myThemes[i];
                                bool edit = myThemeOpen[i];
                                return Column(
                                  children: [
                                    ListTile(
                                      trailing: Container(
                                        child: Stack(
                                          children: <Widget>[
                                                ActionButton(
                                                  buttonTitle:
                                                      edit ? "Save" : "Edit",
                                                  onPress: () {
                                                    if (myThemeOpen[i]) {
                                                      if (validate(
                                                          myThemes[i])) {
                                                        saveTheme(i);
                                                        setState(() {
                                                          myThemeOpen[i] =
                                                              false;
                                                        });
                                                      }
                                                    } else {
                                                      editTheme(i);
                                                    }
                                                  },
                                                ),
                                              ] +
                                              (themeSaved[i]
                                                  ? <Widget>[]
                                                  : <Widget>[
                                                      Positioned(
                                                        right: 10,
                                                        top: 10,
                                                        child: Container(
                                                          height: 8,
                                                          width: 8,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ]),
                                        ),
                                      ),
                                      title: edit
                                          ? TextFormField(
                                              initialValue: t.name,
                                              onChanged: (s) {
                                                myThemes[i].name = s;
                                              },
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: "Theme Name",
                                              ),
                                            )
                                          : Text(
                                              t.name.isEmpty
                                                  ? "Theme   ${i + 1}"
                                                  : t.name,
                                              style: TextStyle(
                                                color: t.name.isEmpty
                                                    ? Colors.grey
                                                    : Colors.white,
                                              ),
                                            ),
                                    ),
                                    edit
                                        ? ListTile(
                                            title: TextFormField(
                                              initialValue: t.password,
                                              onChanged: (s) {
                                                myThemes[i].password = s;
                                              },
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                              decoration: InputDecoration(
                                                labelText: "Theme Password",
                                                hintText:
                                                    "Keep it empty for no password",
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                    edit
                                        ? Container(
                                            alignment: Alignment.centerRight,
                                            child: ActionButton(
                                              widget: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    "Add Word",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              onPress: () {
                                                setState(() {
                                                  myThemes[i]
                                                      .questions
                                                      .insert(0, "");
                                                  _controllers.insert(
                                                    0,
                                                    TextEditingController(
                                                        text: ""),
                                                  );
                                                });
                                              },
                                            ),
                                          )
                                        : SizedBox(),
                                    edit
                                        ? ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: t.questions.length,
                                            itemBuilder: (context, j) {
                                              return ListTile(
                                                title: TextFormField(
                                                  controller: _controllers[j],
                                                  onChanged: (s) {
                                                    myThemes[i].questions[j] =
                                                        s;
                                                  },
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                  decoration: InputDecoration(
                                                    labelText: "Question Word",
                                                    suffix: IconButton(
                                                      icon: Icon(
                                                          Icons.delete_outline),
                                                      onPressed: () {
                                                        setState(() {
                                                          myThemes[i]
                                                              .questions
                                                              .removeAt(j);
                                                          _controllers
                                                              .removeAt(j);
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : SizedBox(),
                                  ],
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
