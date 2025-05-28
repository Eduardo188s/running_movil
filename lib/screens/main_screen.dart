import 'package:flutter/material.dart';
import 'package:recorrido_salud/screens/exercise.dart';
import 'package:recorrido_salud/screens/home.dart';
import 'package:recorrido_salud/screens/profile.dart';
import 'package:recorrido_salud/screens/watch.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final screens = const [
    HomePage(),
    ExercisePage(),
    WatchPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run_outlined),
            activeIcon: Icon(Icons.directions_run),
            label: 'Exercise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_outlined),
            activeIcon: Icon(Icons.watch),
            label: 'Devices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
