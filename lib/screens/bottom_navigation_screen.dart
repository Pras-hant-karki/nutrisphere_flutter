import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/screens/bottom_screens/appointment_screen.dart';
import 'package:nutrisphere_flutter/screens/bottom_screens/fitness_guide_screen.dart';
import 'package:nutrisphere_flutter/screens/bottom_screens/home_screen.dart';
import 'package:nutrisphere_flutter/screens/bottom_screens/profile_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {

   int _selectedIndex = 0;

  final List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const FitnessGuideScreen(),
    const AppointmentScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.amber,
           ),
        body: lstBottomScreen[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.amber,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey[700],
          currentIndex: _selectedIndex,
          onTap: (index) =>setState(() {
            _selectedIndex=index;
          }) ,
          type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_day_rounded),
            label: "Appointment",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Req Plans",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );

  }
}