import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hangman/utilities/connectivity.dart';
import 'package:flutter_hangman/utilities/score_db.dart';
import 'package:flutter_hangman/utilities/themes.dart';
import 'package:flutter_hangman/utilities/user_scores.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAccount {
  static FirebaseAuth _firebaseAuth;
  static Firestore _firestore;
  static GoogleSignIn _googleSignIn;
  static User me;
  static SharedPreferences _preference;
  static String _selectedTheme;

  static String get selectedTheme => _selectedTheme;

  static set selectedTheme(String id) {
    _selectedTheme = id;
    _preference.setString("currentTheme", id);
  }

  static String get profile => _preference.getString("profile");

  static bool get music => _preference.getBool("music");

  static List<String> get themesOpen =>
      _preference.getStringList("themesOpen") ?? [];

  static set themesOpen(List<String> list) {
    _preference
        .setStringList("themesOpen", list)
        .then((_) => _preference.reload());
  }

  static set profile(String s) {
    _preference.setString("profile", s);
    if (UserAccount.me != null) {
      UserAccount.me.ref.updateData({"profile": s});
    }
  }

  static int get coins => _preference.getInt("coins") ?? 0;

  static set coins(int coins) {
    _preference.setInt("coins", coins).then((_) => _preference.reload());
    if (UserAccount.me != null) UserAccount.me.ref.updateData({"coins": coins});
  }

  static set music(bool m) {
    _preference.setBool("music", m);
  }

  static Future<void> init() async {
    if (_preference == null) {
      _firebaseAuth = FirebaseAuth.instance;
      _firestore = Firestore.instance;
      _googleSignIn = GoogleSignIn();
      _preference = await SharedPreferences.getInstance();
      _selectedTheme = _preference.getString("currentTheme");
    }
    if (AppConnectivity.isConnected) await getCurrentUser();
  }

  static Future<void> setCurrentUser(User user) async {
    _preference.setString("currentUser", jsonEncode(user.toJson()));
  }

  static Future<void> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    if (user != null) {
      QuerySnapshot qs = await _firestore
          .collection("users")
          .where("email", isEqualTo: user.email)
          .limit(1)
          .getDocuments();
      if (qs.documents.isNotEmpty) {
        DocumentSnapshot doc = qs.documents.first;
        if (doc.data["email"].toString() == user.email) {
          UserAccount.me = User.fromJson(doc);
        }
      }
    }
  }

  static Future<void> googleSignIn() async {
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();

    if (googleSignInAccount == null) {
      return false;
    }

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount?.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult =
        await _firebaseAuth.signInWithCredential(credential);

    final FirebaseUser user = authResult.user;
    await registerUser(user);
  }

  static Future<void> registerUser(FirebaseUser firebaseUser) async {
    QuerySnapshot qs = await _firestore
        .collection("users")
        .where("email", isEqualTo: firebaseUser.email)
        .limit(1)
        .getDocuments();
    bool newUser = false;
    if (qs.documents.isEmpty) {
      newUser = true;
    } else {
      DocumentSnapshot doc = qs.documents.first;
      if (doc.data["email"].toString() != firebaseUser.email) {
        newUser = true;
      }
    }
    if (newUser) {
      DocumentReference ref = _firestore.collection("users").document();
      User user = new User(
          firebaseUser.displayName, firebaseUser.email, ref.documentID);
      user.ref = ref;
      await ref.setData(user.toJson());
      UserAccount.me = user;
    } else {
      DocumentSnapshot doc = qs.documents.first;
      UserAccount.me = User.fromJson(doc);
    }
    _preference.setString("profile", UserAccount.me.profile);
  }

  static Future<void> setLocalThemes() async {
    Themes.themes = new List<Theme>();
    if (AppConnectivity.isConnected) {
      QuerySnapshot qs =
          await _firestore.collection("locThemes").getDocuments();
      qs.documents.forEach((doc) {
        Themes.themes.add(new Theme.fromJson(doc));
      });
    } else {
      Themes.getThemesFromApp();
    }
    Themes.sortThemes();
  }
}

class User {
  String name, email, uid, profile;
  List<Score> scores;
  int coins;
  DocumentReference ref;

  User(this.name, this.email, this.uid) {
    this.scores = ScoreDatabase.getScores();
    this.coins = ScoreDatabase.getTotalScore();
    this.profile = UserAccount.profile;
  }

  User.fromJson(DocumentSnapshot doc) {
    this.ref = doc.reference;
    this.name = doc.data["name"];
    this.email = doc.data["email"];
    this.uid = doc.data["uid"];
    this.profile = doc.data["profile"];
    this.coins = doc.data["coins"];
    this.scores = List<Score>.generate(
      doc.data["scores"].length,
      (i) => Score.fromJson(doc.data["scores"][i]),
    );
  }

  Map<String, dynamic> toJson() => {
        "name": this.name,
        "email": this.email,
        "uid": this.uid,
        "profile": this.profile,
        "coins": this.coins,
        "scores": List<Map<String, dynamic>>.generate(
          this.scores.length,
          (i) => this.scores[i].toJson(),
        ),
      };
}
