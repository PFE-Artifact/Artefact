import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:artefacts/screens/AccueilScreen.dart';
import 'package:artefacts/screens/ProfileScreen.dart';
import 'package:artefacts/screens/map_screen.dart';
import 'package:provider/provider.dart';
import 'model/theme.dart';
import 'model/game_state.dart';
import 'BottomNavScreen.dart';

class Quizz extends StatefulWidget {
  @override
  State<Quizz> createState() => _QuizzState();
}

class _QuizzState extends State<Quizz> {
  int _selectedIndex = 0;
  String _selectedCategory = "History";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, "/accueil");
        break;
      case 1:
        Navigator.pushNamed(context, "/map");
        break;
      case 2:
      // Handle Scan action
        break;
      case 3:
      // Handle Favorites action
        break;
      case 4:
        Navigator.pushNamed(context, "/profile");
        break;
    }
  }

  Stream<List<ThemeModel>> _getThemes() {
    return _firestore
        .collection('quizzes')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ThemeModel.fromFirestore({...doc.data(), 'id': doc.id}))
        .toList());
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff003add),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, "/accueil");
          },
        ),
        title: Text(
          "Explore Themes",
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryChip("History",
                    selected: _selectedCategory == "History"),
                _buildCategoryChip("Geography",
                    selected: _selectedCategory == "Geography"),
                _buildCategoryChip("Science",
                    selected: _selectedCategory == "Science"),
                _buildCategoryChip("Economy",
                    selected: _selectedCategory == "Economy"),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ThemeModel>>(
              stream: _getThemes(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final themes = snapshot.data ?? [];

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: themes.length,
                  itemBuilder: (context, index) {
                    final theme = themes[index];
                    return _buildThemeCard(
                      context,
                      theme.title,
                      theme.imageUrl,
                      themeId: theme.id,
                      locked: theme.isLocked,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavScreen(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryChip(String text, {bool selected = false}) {
    return GestureDetector(
      onTap: () => _onCategorySelected(text),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Color(0xff003add) : Color(0xff003add).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 13, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildThemeCard(
      BuildContext context,
      String title,
      String imagePath,
      {required String themeId,
        bool locked = false,}
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          if (!locked) {
            // Set the current theme in GameState before navigating
            final gameState = Provider.of<GameState>(context, listen: false);
            gameState.setCurrentTheme(themeId);

            // Navigate to map screen with theme data
            Navigator.pushNamed(
              context,
              "/map",
              arguments: {
                'title': title,
                'themeId': themeId,
              },
            );
          }
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                imagePath,
                height: 163,
                width: double.infinity,
                fit: BoxFit.cover,
                // Add a placeholder while the image loads
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 163,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                // Handle errors
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 163,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Icon(Icons.error),
                  );
                },
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 16,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  locked ? Icons.lock : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

