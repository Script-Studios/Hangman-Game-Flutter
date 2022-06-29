import 'package:flutter/material.dart';
import 'package:flutter_hangman/screens/onboard.dart';
import 'package:flutter_hangman/screens/score_screen.dart';
import 'package:flutter_hangman/utilities/appConfiguration.dart';
import 'package:flutter_hangman/utilities/connectivity.dart';
import 'package:flutter_hangman/utilities/constants.dart';
import 'package:flutter_hangman/utilities/loading.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class DrawerPage extends StatefulWidget {
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  List<String> profilePaths;
  String currentProfilePath;
  bool music = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    currentProfilePath = UserAccount.profile;
    music = UserAccount.music ?? true;
    profilePaths = List.generate(18, (i) => "images/ProfilePics/${i + 1}.jpg");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_left,
                color: Colors.white,
                size: 40,
              ),
            ),
            title: Text(
              "Settings",
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
              ),
            ),
          ),
          Divider(
            thickness: 1,
            color: Colors.grey[500],
          ),
          Container(
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: selectProfilePic,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: currentProfilePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(250),
                            child: Image.asset(
                              currentProfilePath,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Center(
                            child: Text("Select Profile Pic"),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 0.3,
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(
              Icons.audiotrack,
              color: Colors.white,
              size: 20,
            ),
            title: Text(
              "Audio",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            trailing: Switch(
              value: music ?? false,
              onChanged: (val) async {
                setState(() {
                  music = val;
                });
                UserAccount.music = music;
              },
              activeColor: Colors.purple[700],
              activeTrackColor: Colors.purple[300],
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.blueGrey,
            ),
            onTap: () {
              setState(() {
                music = !music;
              });
              UserAccount.music = music;
            },
          ),
          Divider(
            thickness: 0.3,
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(
              Icons.assessment,
              color: Colors.white,
              size: 20,
            ),
            title: Text(
              "Game  Statistics",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScoreScreen(),
                ),
              );
            },
          ),
          UserAccount.me != null
              ? SizedBox()
              : Divider(
                  thickness: 0.3,
                  color: Colors.grey,
                ),
          UserAccount.me != null
              ? SizedBox()
              : ListTile(
                  leading: Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  title: Text(
                    "Sign in with Google",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () async {
                    if (AppConnectivity.isConnected) {
                      Loading.start(context);
                      await UserAccount.googleSignIn();
                      Loading.stop(context);
                      currentProfilePath = UserAccount.profile;
                      setState(() {});
                    } else {
                      Loading.start(context, message: "No Internet Connected");
                      await Future.delayed(Duration(milliseconds: 1000));
                      Loading.stop(context);
                    }
                  },
                ),
          Divider(
            thickness: 0.3,
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(
              Icons.lock_outline,
              color: Colors.white,
              size: 20,
            ),
            title: Text(
              "Privacy  Policy",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            onTap: () {
              url_launcher.launch(privacyPolicyUrl,
                  statusBarBrightness: Brightness.light, forceWebView: true);
            },
          ),
          Divider(
            thickness: 0.3,
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            title: Text(
              "How  to  Play",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OnBoardingPage(false),
                ),
              );
            },
          ),
          /* Divider(
            thickness: 0.3,
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(
              Icons.people,
              color: Colors.white,
              size: 20,
            ),
            title: Text(
              "About  Us",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            onTap: () {},
          ), */
          Divider(
            thickness: 0.3,
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(
              Icons.rate_review,
              color: Colors.white,
              size: 20,
            ),
            title: Text(
              "Rate this App",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            onTap: () async {
              url_launcher.launch(playStoreUrl);
              /* RateMyApp rateMyApp = new RateMyApp(
                googlePlayIdentifier: "com.scriptstudios.hangman",
                minLaunches: 0,
                minDays: 1,
                remindLaunches: 0
              );
              rateMyApp.showRateDialog(
                context,
                title: "Rate this App",
                message:
                    'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.',
                listener: (button) {
                  print(button);
                  return true;
                },
                dialogStyle: DialogStyle(
                  messageStyle: TextStyle(color: Colors.white),
                  titleStyle: TextStyle(color: Colors.white),
                ),
              ); */
            },
          ),
        ],
      ),
    );
  }

  void selectProfilePic() {
    _scaffoldKey.currentState.showBottomSheet(
      (context) {
        return Container(
          height: 500,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    children: new List<Widget>.generate(
                      profilePaths.length,
                      (i) => GestureDetector(
                        child: Container(
                          padding: EdgeInsets.all(4),
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              profilePaths[i],
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            setState(() {
                              currentProfilePath = profilePaths[i];
                            });
                            UserAccount.profile = currentProfilePath;
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}
