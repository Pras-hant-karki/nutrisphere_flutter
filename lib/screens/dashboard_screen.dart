import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/screens/bottom_screens/appointment_screen.dart';
import 'package:nutrisphere_flutter/screens/bottom_screens/fitness_guide_screen.dart';
import 'package:nutrisphere_flutter/screens/bottom_screens/home_screen.dart';
import 'package:nutrisphere_flutter/screens/bottom_screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  final List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const FitnessGuideScreen(),
    const AppointmentScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      
      // TOP APP BAR SECTION
      
      body: SafeArea(
        child: Column(
          children: [
            // Top Row (Avatar + Text + Notification)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  // Back arrow
                IconButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
                icon: const Icon(Icons.arrow_back),
                ),

                  const Text(
                    "Hi User!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // Notification Icon
                  Stack(
                    children: [
                      // Notification Icon
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none),
                      ),

                      // Small red dot
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              "",
                              style: TextStyle(fontSize: 8, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            
            // cards
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    dashboardCard(
                      title: "Today's workout",
                      subtitle: "Lets crush it !",
                      onTap: () {},
                      icon: Icons.fitness_center, 
                    ),

                    dashboardCard(
                      title: "Sessions",
                      subtitle: "Circuit workout\n(Starts at 8 AM, 11/23/025)",
                      onTap: () {},
                      icon: Icons.event_note, 
                    ),

                    dashboardCard(
                      title: "Workout Records",
                      subtitle: "Track your workouts here everyday",
                      onTap: () {},
                      icon: Icons.bar_chart, 
                    ),

                    dashboardCard(
                      title: "Trainer Details",
                      subtitle: "Know your Trainer !",
                      onTap: () {},
                      icon: Icons.person_outline, 
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      
      // bottom navigation bar
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: "Fitness guide",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "App/Req",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  
  Widget dashboardCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required IconData icon, 
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // left icon
              Icon(
                icon,
                size: 30,
                color: Colors.blue, 
              ),

              const SizedBox(width: 18),

              // title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
