import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/screens/bottom_screens/appointment_screen.dart';
import 'package:nutrisphere_flutter/screens/bottom_screens/fitness_guide_screen.dart';
import 'package:nutrisphere_flutter/screens/bottom_screens/home_screen.dart';
import 'package:nutrisphere_flutter/screens/bottom_screens/profile_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> lstBottomScreen = const [
    HomeScreen(),
    FitnessGuideScreen(),
    AppointmentScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontFamily: "OpenSans Bold", 
          ),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true, 
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: lstBottomScreen,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.amber,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: "Guide",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "App/Req",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
