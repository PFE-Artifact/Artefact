import 'package:flutter/material.dart';


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
      // Navigate to Profile when the Profile tab is selected
      Navigator.pushNamed(context, '/map');
    }
    if (index == 3) {
      // Navigate to Profile when the Profile tab is selected
      Navigator.pushNamed(context, '/profile');
    }
    if (index == 2) {
      // Navigate to Profile when the Profile tab is selected
      Navigator.pushNamed(context, '/map');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Search
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Artifacts",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.search, size: 28, color: Colors.black54),
              ],
            ),
            SizedBox(height: 50),

            // Scan Button
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.qr_code_scanner, color: Colors.white),
              label: Text("Scan and identify the artifact"),
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
              "Games",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/quizz");
                        },
                        child: GameCard(
                          title: "Quizz",
                          gameNumber: "Game 1",
                          imagePath: "assets/cross.png",
                          lineColor: Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(width: 32), // Space between Quizz and Puzzle
                    Expanded(
                      child: GameCard(
                        title: "Puzzle",
                        gameNumber: "Game 3",
                        imagePath: "assets/puzzle.png",
                        lineColor: Colors.blue,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32), // Space between Game 1 and Game 2

                Row(
                  children: [
                    GameCard(
                      title: "Treasure hunt",
                      gameNumber: "Game 2",
                      imagePath: "assets/direction.png",
                      lineColor: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            Text(
              "Our latest work",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
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

  const GameCard({
    required this.title,
    required this.gameNumber,
    required this.imagePath,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
        SizedBox(width: 10),
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
      ],
    );
  }
}


