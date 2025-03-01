import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:skill_boost/screens/Pronunciation/PronunciationScreen.dart';
import 'package:skill_boost/screens/home/main_screen.dart';
import 'package:skill_boost/screens/speech/SpeechScreen.dart';
import 'package:skill_boost/screens/test/TestScreen.dart';
import 'package:skill_boost/screens/report/ReportScreen.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int initialIndex;

  const CustomBottomNavigationBar({Key? key, this.initialIndex = 0})
      : super(key: key);

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void onTabTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    Widget destination;
    switch (index) {
      case 0:
        destination = MainScreen();
        break;
      case 1:
        destination = SpeechScreen();
        break;
      case 2:
        destination = PronunciationScreen();
        break;
      case 3:
        destination = TestScreen();
        break;
      case 4:
        destination = ReportScreen();
        break;
      default:
        destination = MainScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        items: <Widget>[
          Tooltip(
            message: 'Vocabulary',
            child: Icon(Icons.book_sharp, size: 30, color: Colors.white),
          ),
          Tooltip(
            message: 'Speech',
            child: Icon(Icons.mic, size: 30, color: Colors.white),
          ),
          Tooltip(
            message: 'Pronunciation',
            child: Icon(Icons.graphic_eq, size: 30, color: Colors.white),
          ),
          Tooltip(
            message: 'Test',
            child: Icon(Icons.assignment, size: 30, color: Colors.white),
          ),
          Tooltip(
            message: 'Report',
            child: Icon(Icons.bar_chart, size: 30, color: Colors.white),
          ),
        ],
        color: Colors.blue.shade600,
        buttonBackgroundColor: Colors.blue.shade700,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: onTabTapped,
        letIndexChange: (index) => true,
      ),
    );
  }
}
