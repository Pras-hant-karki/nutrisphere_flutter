import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/admin_appointment_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/admin_fitness_guide_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/admin_home_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/admin_profile_page.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';

class AdminBottomNavigationPage extends StatefulWidget {
  const AdminBottomNavigationPage({super.key});

  @override
  State<AdminBottomNavigationPage> createState() =>
      _AdminBottomNavigationPageState();
}

class _AdminBottomNavigationPageState extends State<AdminBottomNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> lstBottomScreen = const [
    AdminHomePage(),
    AdminAppointmentPage(),
    AdminFitnessGuidePage(),
    AdminProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text(
          "Admin Dashboard",
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
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.secondaryDark,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Fitness",
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