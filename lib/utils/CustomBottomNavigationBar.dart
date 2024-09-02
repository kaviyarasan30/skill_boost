import 'package:flutter/material.dart';
import 'package:skill_boost/screens/home/main_screen.dart';
import 'package:skill_boost/utils/UnderDevelopmentPage.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    MainScreen(),
    UnderDevelopmentPage(),
    Center(child: Text('Pronounciation')),
    Center(child: Text('Test')),
    Center(child: Text('Report')),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      onTap: onTabTapped,
      currentIndex: _currentIndex,
      type: BottomNavigationBarType
          .fixed, // This keeps the labels even when not selected
      selectedItemColor: Colors.black, // Color when an item is selected
      unselectedItemColor:
          Colors.black.withOpacity(0.6), // Color when not selected
      showSelectedLabels: true, // Hide labels for selected items
      showUnselectedLabels: false, // Hide labels for unselected items
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.book_sharp,
            size: 24, // Adjust size if needed
          ),
          label: 'Vocabulary',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.mic,
            size: 24, // Adjust size if needed
          ),
          label: 'Speech',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.graphic_eq,
            size: 24, // Adjust size if needed
          ),
          label: 'Pronounciation',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.assignment,
            size: 24, // Adjust size if needed
          ),
          label: 'Test',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.bar_chart,
            size: 24, // Adjust size if needed
          ),
          label: 'Report',
        ),
      ],
    );
  }
}
