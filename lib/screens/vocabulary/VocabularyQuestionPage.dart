import 'package:flutter/material.dart';
import 'package:skill_boost/utils/CustomBottomNavigationBar.dart';

class VocabularyQuestionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vocabulary'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline),
            onPressed: () {
              // Handle profile action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.arrow_back),
            title: Text('Basic Nouns'),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildQuestionCard('New Word', 'Choose the best definition'),
                _buildAnswerTile('Differentiate'),
                _buildAnswerTile('Identify differences between'),
                _buildAnswerTile('create'),
                _buildAnswerTile('vary randomly'),
                _buildAnswerTile('disagree'),
                _buildAnswerTile('I\'m not sure'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  Widget _buildQuestionCard(String title, String subtitle) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(subtitle),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerTile(String answer) {
    return ListTile(
      title: Text(answer),
      onTap: () {
        // Handle answer selection
      },
    );
  }
}