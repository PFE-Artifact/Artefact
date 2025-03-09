import 'package:flutter/material.dart';

class Level1T_H extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Stack(
        children: [
          // Background Box
          Container(
            width: 590,
            height: 844,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Beginner Achievement Box (Now Clickable)
          Positioned(
            top: 120,
            left: 32,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/BeginnerT1H");
              },
              child: Container(
                width: 325,
                height: 117,
                decoration: BoxDecoration(
                  color: Color(0xff90adff).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xff003add), width: 1),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 13,
                      top: 16,
                      child: Container(
                        width: 91,
                        height: 85,
                        decoration: BoxDecoration(
                          color: Color(0xff003add).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 120,
                      child: Text(
                        "Beginner",
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xff003add),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 44,
                      left: 120,
                      child: Text(
                        "Unlock your first card!",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff003add).withOpacity(0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Collector Achievement Box
          Positioned(
            top: 260,
            left: 32,
            child: Container(
              width: 325,
              height: 117,
              decoration: BoxDecoration(
                color: Color(0xff90adff).withOpacity(0.4),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xff003add).withOpacity(0.4), width: 1),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 13,
                    top: 16,
                    child: Container(
                      width: 91,
                      height: 85,
                      decoration: BoxDecoration(
                        color: Color(0xff003add).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 120,
                    child: Text(
                      "Collector",
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xff003add),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 44,
                    left: 120,
                    child: Text(
                      "Collect 10 different Cards!",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff003add).withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Master Achievement Box
          Positioned(
            top: 400,
            left: 32,
            child: Container(
              width: 325,
              height: 117,
              decoration: BoxDecoration(
                color: Color(0xff90adff).withOpacity(0.4),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xff003add), width: 1),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 13,
                    top: 16,
                    child: Container(
                      width: 91,
                      height: 85,
                      decoration: BoxDecoration(
                        color: Color(0xff003add).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 120,
                    child: Text(
                      "Master",
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xff003add),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 44,
                    left: 120,
                    child: Text(
                      "Unlock all Cards!",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff003add).withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        currentIndex: 0, // Adjust index as needed
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, "/accueil");
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About us"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}
