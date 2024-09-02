import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_boost/providers/auth_provider.dart';
import 'package:skill_boost/screens/vocabulary/VocabularyLessonListPage.dart';
import 'package:skill_boost/utils/CustomBottomNavigationBar.dart';
import 'package:skill_boost/utils/button_style.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Vocabulary',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.account_circle, color: Colors.black, size: 30),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBar(),
            SizedBox(height: 20),
            DifficultyFilter(),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Number of items
                itemBuilder: (context, index) {
                  return VocabularyCard();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100], // Slightly off-white background
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class DifficultyFilter extends StatefulWidget {
  @override
  _DifficultyFilterState createState() => _DifficultyFilterState();
}

class _DifficultyFilterState extends State<DifficultyFilter> {
  String selectedDifficulty = 'Beginner';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildFilterOption('Beginner'),
        SizedBox(width: 10),
        _buildFilterOption('Intermediate'),
        SizedBox(width: 10),
        _buildFilterOption('Advanced'),
      ],
    );
  }

  Widget _buildFilterOption(String label) {
    bool isSelected = selectedDifficulty == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDifficulty = label;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            if (isSelected)
              Icon(Icons.check_box, color: Colors.black, size: 18),
            if (!isSelected)
              Icon(Icons.check_box_outline_blank,
                  color: Colors.black, size: 18),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VocabularyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basic Nouns',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Learn everyday common nouns',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  text: 'Difficulty: ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: 'Beginner',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Start Button
          ElevatedButton(
            style: globalButtonStyle,
            child: const Text('Start'),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => VocabularyLessonListPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
