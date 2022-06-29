import 'package:flutter/material.dart';

class Score {
  String _id;
  DateTime _scoreDate;
  int _userScore;

  Score(
      {@required String id,
      @required DateTime scoreDate,
      @required int userScore}) {
    this._id = id;
    this._scoreDate = scoreDate;
    this._userScore = userScore;
  }

  Score.fromJson(Map<String, dynamic> data) {
    this._id = data["id"];
    this._scoreDate = DateTime.parse(data["scoreDate"]);
    this._userScore = int.parse(data["userScore"].toString());
  }

  Score.fromString(String s) {
    this._userScore = int.parse(s.split(",")[0]);
    this._scoreDate = DateTime.parse(s.split(",")[1]);
    this._id = s.split(",")[2];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'scoreDate': _scoreDate.toIso8601String(),
      'userScore': _userScore,
    };
  }

  String get id => _id;

  DateTime get scoreDate => _scoreDate;

  int get userScore => _userScore;

  @override
  String toString() {
    return '$_userScore,${_scoreDate.toIso8601String()},$_id';
  }
}
