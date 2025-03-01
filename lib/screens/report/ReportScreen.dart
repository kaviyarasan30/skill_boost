import 'package:flutter/material.dart';
import 'package:skill_boost/utils/CustomBottomNavigationBar.dart';

class ReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Progress Report',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.account_circle, color: Colors.black, size: 30),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallProgress(),
            SizedBox(height: 24),
            Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildActivityList(),
            SizedBox(height: 24),
            Text(
              'Skill Breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildSkillBreakdown(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(initialIndex: 4),
    );
  }

  Widget _buildOverallProgress() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressItem('Lessons\nCompleted', '24'),
              _buildProgressItem('Hours\nSpent', '12.5'),
              _buildProgressItem('Average\nScore', '85%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {
        'title': 'Vocabulary Test',
        'score': '90%',
        'date': '2 hours ago',
        'icon': Icons.spellcheck,
        'color': Colors.green,
      },
      {
        'title': 'Speech Practice',
        'score': '85%',
        'date': 'Yesterday',
        'icon': Icons.mic,
        'color': Colors.orange,
      },
      {
        'title': 'Pronunciation Lesson',
        'score': '75%',
        'date': '2 days ago',
        'icon': Icons.record_voice_over,
        'color': Colors.purple,
      },
    ];

    return Column(
      children: activities.map((activity) {
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (activity['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                activity['icon'] as IconData,
                color: activity['color'] as Color,
              ),
            ),
            title: Text(
              activity['title'] as String,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(activity['date'] as String),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                activity['score'] as String,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillBreakdown() {
    final skills = [
      {
        'name': 'Vocabulary',
        'progress': 0.85,
        'color': Colors.blue,
      },
      {
        'name': 'Speaking',
        'progress': 0.75,
        'color': Colors.orange,
      },
      {
        'name': 'Pronunciation',
        'progress': 0.70,
        'color': Colors.purple,
      },
      {
        'name': 'Grammar',
        'progress': 0.80,
        'color': Colors.green,
      },
    ];

    return Column(
      children: skills.map((skill) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    skill['name'] as String,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${((skill['progress'] as double) * 100).toInt()}%',
                    style: TextStyle(
                      color: skill['color'] as Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: skill['progress'] as double,
                backgroundColor: (skill['color'] as Color).withOpacity(0.1),
                valueColor:
                    AlwaysStoppedAnimation<Color>(skill['color'] as Color),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
