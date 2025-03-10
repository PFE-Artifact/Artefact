import 'package:artefacts/screens/AccueilScreen.dart';
import 'package:artefacts/screens/ProfileScreen.dart';
import 'package:artefacts/screens/map_screen.dart';
import 'package:flutter/material.dart';


class BottomNavScreen extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavScreen({Key? key, required this.selectedIndex, required this.onItemTapped}) : super(key: key);

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black54,
      currentIndex: widget.selectedIndex, // Use widget to access passed value
      onTap: widget.onItemTapped, // Use widget to access passed function
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
