import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_boost/models/lesson_model.dart';
import 'package:skill_boost/providers/lesson_provider.dart';
import 'package:skill_boost/screens/vocabulary/VocabularyLessonListPage.dart';
import 'package:skill_boost/utils/CustomBottomNavigationBar.dart';
import 'package:skill_boost/utils/colors.dart';
import 'package:skill_boost/utils/global_app_bar.dart';
import 'package:lottie/lottie.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  bool _showFilterOptions = false;
  late LessonProvider _lessonProvider;
  final GlobalKey _filterButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Using addPostFrameCallback to access context safely after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lessonProvider = Provider.of<LessonProvider>(context, listen: false);
      _lessonProvider.fetchLessons();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Lesson> _filterLessons(List<Lesson> lessons) {
    // Filter by search text
    var filteredLessons = _searchController.text.isEmpty
        ? lessons
        : lessons
            .where((lesson) => lesson.lessonName
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();

    // Filter by difficulty level
    if (_selectedFilter != 'All') {
      filteredLessons = filteredLessons
          .where((lesson) => lesson.level == _selectedFilter)
          .toList();
    }

    // Filter by tab
    switch (_tabController!.index) {
      case 0: // All
        return filteredLessons;
      case 1: // Review
        return filteredLessons;

      case 2: // Completed
        return filteredLessons;

      default:
        return filteredLessons;
    }
  }

  void _showFilterDropdown() {
    final RenderBox renderBox =
        _filterButtonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate position that aligns with the filter button
    final dropdownWidth = 200.0;
    final left = min(screenWidth - dropdownWidth - 16,
        position.dx - dropdownWidth + size.width);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: left,
              top: position.dy + size.height + 5,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                child: Container(
                  width: dropdownWidth,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Filter by Level',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildFilterChip('All'),
                      SizedBox(height: 8),
                      _buildFilterChip('Basic'),
                      SizedBox(height: 8),
                      _buildFilterChip('Intermediate'),
                      SizedBox(height: 8),
                      _buildFilterChip('Advanced'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GlobalAppBar(
        title: 'Vocabulary',
        achievementCount: 3,
      ),
      body: Column(
        children: [
          _buildSearchFilterBar(),
          SizedBox(height: 16),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLessonsList(filter: 'all'),
                _buildLessonsList(filter: 'review'),
                _buildLessonsList(filter: 'completed'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  Widget _buildSearchFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search lessons',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon:
                      Icon(Icons.search, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            key: _filterButtonKey,
            onTap: _showFilterDropdown,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.filter_list,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  if (_selectedFilter != 'All')
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    Color chipColor;

    switch (label) {
      case 'Basic':
        chipColor = AppColors.basicLevel;
        break;
      case 'Intermediate':
        chipColor = AppColors.intermediateLevel;
        break;
      case 'Advanced':
        chipColor = AppColors.advancedLevel;
        break;
      default:
        chipColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          Navigator.pop(context); // Close the popup after selection
        });
      },
      child: Container(
        width: double.infinity, // Make all chips the same width
        padding: EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center, // Center the text
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: isSelected ? chipColor : AppColors.textLight,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? chipColor : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accent, AppColors.primaryLight],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          tabs: [
            _buildTab('All', 0),
            _buildTab('Review', 1),
            _buildTab('Completed', 2),
          ],
          onTap: (_) => setState(() {}),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _tabController!.index == index;
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(text),
          ),
          if (isSelected)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 30,
                height: 3,
                margin: EdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonsList({required String filter}) {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        if (lessonProvider.isLoading) {
          return Center(
            child: Lottie.network(
              'https://assets1.lottiefiles.com/packages/lf20_qm8eqzse.json',
              width: 200,
              height: 200,
            ),
          );
        } else if (lessonProvider.error.isNotEmpty) {
          return Center(child: Text('Error: ${lessonProvider.error}'));
        } else if (lessonProvider.lessons.isEmpty) {
          return Center(child: Text('No lessons available'));
        }

        // Apply filters
        final filteredLessons = _filterLessons(lessonProvider.lessons);

        if (filteredLessons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.textLight,
                ),
                SizedBox(height: 16),
                Text(
                  'No lessons match your filters',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
          itemCount: filteredLessons.length,
          itemBuilder: (context, index) {
            final lesson = filteredLessons[index];
            return EnhancedVocabularyCard(
              lesson: lesson,
              isLocked: index > 2,
              progress: index == 0 ? 1.0 : (index == 1 ? 0.6 : 0.0),
            );
          },
        );
      },
    );
  }
}

class EnhancedVocabularyCard extends StatelessWidget {
  final Lesson lesson;
  final bool isLocked;
  final double progress;

  const EnhancedVocabularyCard({
    Key? key,
    required this.lesson,
    this.isLocked = false,
    this.progress = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 0,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _buildLessonIcon(),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson.lessonName,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 22,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                _buildDifficultyBadge(lesson.level),
                                SizedBox(width: 12),
                                _buildWordCountBadge(lesson.questions.length),
                              ],
                            ),
                            if (progress > 0 && progress < 1.0)
                              SizedBox(height: 12),
                            if (progress > 0 && progress < 1.0)
                              _buildProgressIndicator(),
                          ],
                        ),
                      ),
                      if (!isLocked) _buildActionButton(context),
                    ],
                  ),
                ),
              ],
            ),
            if (isLocked) _buildLockedOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getDifficultyColor(lesson.level).withOpacity(0.7),
            _getDifficultyColor(lesson.level),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _getDifficultyColor(lesson.level).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _getDifficultyIcon(lesson.level),
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String level) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getDifficultyColor(level).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getDifficultyColor(level).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getDifficultyIcon(level),
            color: _getDifficultyColor(level),
            size: 12,
          ),
          SizedBox(width: 4),
          Text(
            level,
            style: TextStyle(
              color: _getDifficultyColor(level),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCountBadge(int wordCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.book_outlined,
            color: AppColors.info,
            size: 12,
          ),
          SizedBox(width: 4),
          Text(
            '$wordCount words',
            style: TextStyle(
              color: AppColors.info,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.success,
                  ),
                  minHeight: 8,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: progress == 1.0
              ? [AppColors.success, AppColors.success.withOpacity(0.7)]
              : [AppColors.accent, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: (progress == 1.0 ? AppColors.success : AppColors.accent)
                .withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Text(
          progress == 1.0 ? 'Review' : 'Start',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VocabularyLessonListPage(lesson: lesson),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLockedOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.overlay.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Complete previous lessons',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String level) {
    switch (level.toLowerCase()) {
      case 'basic':
        return AppColors.basicLevel;
      case 'intermediate':
        return AppColors.intermediateLevel;
      case 'advanced':
        return AppColors.advancedLevel;
      default:
        return AppColors.info;
    }
  }

  IconData _getDifficultyIcon(String level) {
    switch (level.toLowerCase()) {
      case 'basic':
        return Icons.star_border;
      case 'intermediate':
        return Icons.star_half;
      case 'advanced':
        return Icons.star;
      default:
        return Icons.star_border;
    }
  }
}
