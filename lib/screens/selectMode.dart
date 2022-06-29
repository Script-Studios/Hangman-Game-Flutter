import 'package:flutter/material.dart';

class SelectModePage extends StatefulWidget {
  GameMode mode;
  SelectModePage(this.mode, this.modeSelected);
  final Function(GameMode) modeSelected;
  @override
  _SelectModePageState createState() => _SelectModePageState();
}

enum GameMode { normal, timed }

Map<GameMode, String> modeName = {
  GameMode.normal: "Normal",
  GameMode.timed: "Timed",
};

class _SelectModePageState extends State<SelectModePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "Select a mode",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      ),
      floatingActionButton: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.white),
        ),
        elevation: 20,
        onPressed: () {
          widget.modeSelected(widget.mode);
          Navigator.pop(context);
        },
        color: Color(0xFF421b9b),
        child: Text(
          "DONE",
          style: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
              fontWeight: FontWeight.w300,
              letterSpacing: 3.0),
        ),
      ),
      body: Column(
        children: [
          Opacity(
            opacity: widget.mode == GameMode.normal ? 1 : 0.4,
            child: ListTile(
              title: Text(
                "Normal Mode",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
              subtitle: Text(
                "For each correct word guess, your score would increase by remaining part of your Hanging State.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                ),
              ),
              onTap: () {
                setState(() {
                  widget.mode = GameMode.normal;
                });
              },
            ),
          ),
          Opacity(
            opacity: widget.mode == GameMode.timed ? 1 : 0.4,
            child: ListTile(
              title: Text(
                "Timed Mode",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
              subtitle: Text(
                "Your will be given 60 seconds for guessing the correct word. For each correct word guess, your score would increase by a point for every remaining 5 seconds.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                ),
              ),
              onTap: () {
                setState(() {
                  widget.mode = GameMode.timed;
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
