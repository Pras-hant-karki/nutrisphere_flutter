import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/features/appointment/presentation/pages/appointment_page.dart';
import 'package:nutrisphere_flutter/features/fitness/presentation/pages/fitness_guide_page.dart';
import 'package:nutrisphere_flutter/features/home/presentation/pages/home_page.dart';
import 'package:nutrisphere_flutter/features/profile/presentation/pages/profile_page.dart';

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
        backgroundColor: const Color.fromARGB(255, 244, 227, 169),
        centerTitle: true,
        title: Text(
          "Dashboard",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 26, 
              ),
        ),
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: lstBottomScreen,
      ),
      bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color.fromARGB(255, 244, 227, 169),
      selectedItemColor: Colors.brown,
      unselectedItemColor: Colors.brown.withOpacity(0.6),
      showUnselectedLabels: true,
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
