import 'package:flutter/material.dart';
import 'package:skill_boost/screens/Pronunciation/PronunciationScreen.dart';
import 'package:skill_boost/screens/home/main_screen.dart';
import 'package:skill_boost/screens/speech/SpeechScreen.dart';

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
    if (_currentIndex == index) return; // Don't navigate if already on the tab

    setState(() {
      _currentIndex = index;
    });

    // Navigate to the selected screen
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
        destination = Center(child: Text('Test'));
        break;
      case 4:
        destination = Center(child: Text('Report'));
        break;
      default:
        destination = MainScreen();
    }

    // Replace the current screen with the selected one
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      onTap: onTabTapped,
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black.withOpacity(0.6),
      showSelectedLabels: true,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.book_sharp,
            size: 24,
          ),
          label: 'Vocabulary',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.mic,
            size: 24,
          ),
          label: 'Speech',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.graphic_eq,
            size: 24,
          ),
          label: 'Pronunciation',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.assignment,
            size: 24,
          ),
          label: 'Test',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.bar_chart,
            size: 24,
          ),
          label: 'Report',
        ),
      ],
    );
  }
}
