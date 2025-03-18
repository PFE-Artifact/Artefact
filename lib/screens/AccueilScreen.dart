import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:artefacts/main.dart'; // Adjust the import path if needed
import 'BottomNavScreen.dart'; // Import BottomNavScreen
import './widgets/latest_blogs_section.dart';
import 'blog_detail_screen.dart';

class AccueilScreen extends StatefulWidget {
  @override
  _AccueilScreenState createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  int _selectedIndex = 0;

  // Function to handle BottomNavigationBar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the respective screen based on the selected index
    if (index == 1) {
      // Navigate to Map when the Map tab is selected
      Navigator.pushNamed(context, '/map');
    }
    if (index == 4) {
      // Navigate to Profile when the Profile tab is selected
      Navigator.pushNamed(context, '/profile');
    }
    if (index == 3) {
      // Navigate to Profile when the Profile tab is selected
      Navigator.pushNamed(context, '/maprome');
    }
  }

  // Function to handle blog tap
  void _onBlogTap(String blogId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogDetailScreen(blogId: blogId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the localizations
    final localizations = AppLocalizations.of(context)!;
    // Get the locale provider to check current language
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isRTL = localeProvider.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavScreen(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              SizedBox(height:50), // Adds space at the top
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isRTL)
                    Text(
                      localizations.myArtifacts,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  if (!isRTL)
                    Icon(Icons.search, size: 28, color: Colors.black54),
                  if (isRTL)
                    Icon(Icons.search, size: 28, color: Colors.black54),
                  if (isRTL)
                    Text(
                      localizations.myArtifacts,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              SizedBox(height: 50),

              // Scan Button
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                label: Text(localizations.scanArtifact),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF003ADD),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Games Section
              Text(
                localizations.games,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
              ),
              SizedBox(height: 16),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isRTL) Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/quizz");
                          },
                          child: GameCard(
                            title: localizations.quizz,
                            gameNumber: localizations.game1,
                            imagePath: "assets/cross.png",
                            lineColor: Colors.blue,
                            isRTL: isRTL,
                          ),
                        ),
                      ),
                      if (!isRTL) SizedBox(width: 32), // Space between Quizz and Puzzle
                      if (!isRTL) Expanded(
                        child: GameCard(
                          title: localizations.puzzle,
                          gameNumber: localizations.game3,
                          imagePath: "assets/puzzle.png",
                          lineColor: Colors.blue,
                          isRTL: isRTL,
                        ),
                      ),
                      // For RTL layout
                      if (isRTL) Expanded(
                        child: GameCard(
                          title: localizations.puzzle,
                          gameNumber: localizations.game3,
                          imagePath: "assets/puzzle.png",
                          lineColor: Colors.blue,
                          isRTL: isRTL,
                        ),
                      ),
                      if (isRTL) SizedBox(width: 32), // Space between Puzzle and Quizz
                      if (isRTL) Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/quizz");
                          },
                          child: GameCard(
                            title: localizations.quizz,
                            gameNumber: localizations.game1,
                            imagePath: "assets/cross.png",
                            lineColor: Colors.blue,
                            isRTL: isRTL,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32), // Space between Game 1 and Game 2

                  Row(
                    mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      GameCard(
                        title: localizations.treasureHunt,
                        gameNumber: localizations.game2,
                        imagePath: "assets/direction.png",
                        lineColor: Colors.blue,
                        isRTL: isRTL,
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 16),

              // Our Latest Work Section with Blogs
              Text(
                localizations.ourLatestWork,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
              ),
              SizedBox(height: 16),

              // Latest Blogs Section
              LatestBlogsSection(
                isRTL: isRTL,
                onBlogTap: _onBlogTap,
              ),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String title;
  final String gameNumber;
  final String imagePath;
  final Color lineColor;
  final bool isRTL;

  const GameCard({
    required this.title,
    required this.gameNumber,
    required this.imagePath,
    required this.lineColor,
    this.isRTL = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isRTL)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(imagePath, width: 40, height: 40),
                ),
                Positioned(
                  left: 0,
                  top: 12,
                  bottom: 12,
                  child: Container(width: 4, color: lineColor),
                ),
              ],
            ),
          ),
        if (!isRTL) SizedBox(width: 10),
        if (!isRTL)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gameNumber,
                style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
        // For RTL layout
        if (isRTL)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                gameNumber,
                style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
        if (isRTL) SizedBox(width: 10),
        if (isRTL)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(imagePath, width: 40, height: 40),
                ),
                Positioned(
                  right: 0, // Changed from left to right for RTL
                  top: 12,
                  bottom: 12,
                  child: Container(width: 4, color: lineColor),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
