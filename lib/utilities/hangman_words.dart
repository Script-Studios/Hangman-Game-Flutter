import 'dart:math';
import 'package:flutter_hangman/utilities/alphabet.dart';
import 'package:flutter_hangman/utilities/themes.dart';

class HangmanWords {
  int wordCounter = 0;
  List<int> _usedNumbers = [];
  List<String> _words = [];
  Theme theme;

  /* Future readWords() async {
    String fileText = await rootBundle.loadString('res/hangman_words.txt');
    _words = fileText.split('\n');
  } */

  HangmanWords(this.theme) {
    _words = theme.questions;
  }

  void resetWords() {
    wordCounter = 0;
    _usedNumbers = [];
//    _words = [];
  }

  // ignore: missing_return
  String getWord() {
    wordCounter += 1;
    var rand = Random();
    int wordLength = _words.length;
    int randNumber = rand.nextInt(wordLength);
    bool notUnique = true;
    if (wordCounter - 1 == _words.length) {
      notUnique = false;
      return '';
    }
    while (notUnique) {
      if (!_usedNumbers.contains(randNumber)) {
        notUnique = false;
        _usedNumbers.add(randNumber);
        return _words[randNumber];
      } else {
        randNumber = rand.nextInt(wordLength);
      }
    }
  }

  String getHiddenWord(String word) {
    String hiddenWord = '';
    int l = 0;
    for (int i = 0; i < word.length; i++) {
      if (i >= 10 && word[i] == " " && l >= 10) {
        hiddenWord += '\n';
        l = 0;
      } else {
        l += 1;
        hiddenWord +=
            Alphabet.alph.contains(word[i].toLowerCase()) ? '_' : word[i];
      }
    }
    return hiddenWord;
  }
}
