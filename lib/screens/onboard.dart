import 'package:flutter/material.dart';

class OnBoardingPage extends StatefulWidget {
  final bool firstInstall;
  OnBoardingPage(this.firstInstall);
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  PageController _pageController =
      new PageController(initialPage: 0, keepPage: true);
  List<String> imagePaths =
          new List.generate(3, (i) => "images/onboard/onb${i + 1}.png"),
      desc = [
        "Guess the alphabets of hidden words",
        "Use the hints to get out of brain wreck\nYou only got 7 chances until being hanged",
        "Select the theme of your interest and\nwin coins to unlock more themes"
      ];
  int page = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1089ff),
      body: PageView.builder(
        controller: _pageController,
        itemCount: imagePaths.length,
        onPageChanged: (p) {
          setState(() {
            page = p;
          });
        },
        itemBuilder: (context, i) {
          return Column(
            children: [
              Spacer(),
              Expanded(
                flex: 5,
                child: Image.asset(
                  imagePaths[i],
                  fit: BoxFit.fitHeight,
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    desc[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    skipButton(),
                    nextOrDoneButton(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget nextOrDoneButton() {
    if (page < imagePaths.length - 1)
      return FlatButton(
        onPressed: () {
          _pageController.nextPage(
              duration: Duration(milliseconds: 500), curve: Curves.ease);
        },
        child: Text(
          "Next",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      );
    else
      return FlatButton(
        onPressed: () {
          if (widget.firstInstall) {
            Navigator.pushNamed(context, "homePage");
          } else {
            Navigator.pop(context);
          }
        },
        child: Text(
          "Done",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      );
  }

  Widget skipButton() {
    if (page < imagePaths.length - 1)
      return FlatButton(
        onPressed: () {
          _pageController.animateToPage(imagePaths.length - 1,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
        },
        child: Text(
          "Skip",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      );
    else
      return FlatButton(onPressed: null, child: null);
  }
}
