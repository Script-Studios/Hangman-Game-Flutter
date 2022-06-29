import 'package:flutter/material.dart';

class Loading {
  static bool _loading = false;
  static void start(BuildContext context, {String message}) {
    if (!_loading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Scaffold(
            body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                message != null ? SizedBox() : CircularProgressIndicator(),
                Text(
                  message ?? "Loading....",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        )),
      );
      _loading = true;
    }
  }

  static void stop(BuildContext context) {
    if (_loading) {
      Navigator.pop(context);
      _loading = false;
    }
  }
}
