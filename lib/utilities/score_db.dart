import 'dart:async';
import 'package:flutter_hangman/utilities/appConfiguration.dart';
import 'package:flutter_hangman/utilities/user_scores.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreDatabase {
  static SharedPreferences _preferences;
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static void insertScore(Score score) async {
    if (_preferences != null) {
      List<String> scores = _preferences.getStringList("scores") ?? [];
      scores.add(score.toString());
      await _preferences.setStringList("scores", scores);
      await _preferences.reload();
      UserAccount.coins += score.userScore;
      if (UserAccount.me != null) {
        UserAccount.me.coins += score.userScore;
        List<Score> _scores = ScoreDatabase.getScores();
        UserAccount.me.ref.updateData({
          "scores": List<Map<String, dynamic>>.generate(
            _scores.length,
            (i) => _scores[i].toJson(),
          ),
        });
      }
    } else {
      await init();
      insertScore(score);
    }
  }

  static List<Score> getScores() {
    List<String> scores = _preferences.getStringList("scores") ?? [];
    return List<Score>.generate(
      scores.length,
      (i) => Score.fromString(scores[i]),
    );
  }

  static int getTotalScore() {
    List<Score> scores = ScoreDatabase.getScores();
    int total = 0;
    scores.forEach((s) {
      total += s.userScore;
    });
    return total;
  }
}
