import 'package:flutter/material.dart';
import 'package:flutter_hangman/utilities/constants.dart';

class WordButton extends StatelessWidget {
  WordButton({this.buttonTitle, this.onPress, this.status});

  final Function onPress;
  final String buttonTitle;
  final bool status;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(4.0),
      color: kWordButtonColor,
      onPressed: onPress,
      disabledColor: status != null && status ? Colors.grey : Colors.red,
      child: Text(
        buttonTitle,
        textAlign: TextAlign.center,
        style: kWordButtonTextStyle,
      ),
    );
  }
}
