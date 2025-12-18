import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/screens/session_view_screen.dart';
import 'package:nutrisphere_flutter/screens/trainer_detail_screen.dart';
import 'package:nutrisphere_flutter/screens/workout_record_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 242, 240, 247)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  
                  child: Column(
                    children: [
                      _buildDashboardCard(
                        context,
                        title: 'Sessions',
                        subtitle: 'Explore available sessions',
                        icon: Icons.calendar_month_rounded,
                        gradient: LinearGradient(
                          colors: [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 243, 237, 237)],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SessionViewScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDashboardCard(
                        context,
                        title: 'Workout Records',
                        subtitle: 'Track your workouts here everyday',
                        icon: Icons.bar_chart_outlined,
                        gradient: LinearGradient(
                          colors: [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 243, 237, 237)],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WorkoutRecordScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDashboardCard(
                        context,
                        title: 'Trainer Details',
                        subtitle: 'Know your Trainer !',
                        icon: Icons.person_2_outlined,
                        gradient: LinearGradient(
                          colors: [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 243, 237, 237)],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TrainerDetailScreen(),
                            ),
                          );
                        },
                      ),
                      
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20), 
      child: Container( // controll the container
        width: double.infinity,
        padding: const EdgeInsets.all(15), //controll box height
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20), //controll box border radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), //controll box shadow
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container( // controll logo box

              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 208, 208, 208).withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 40, color: const Color.fromARGB(255, 10, 19, 187)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 5),

                  //subtitle
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color.fromARGB(255, 11, 11, 11),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// Text(
//                     "High quality fitness\n guidance below !",
//                     style: textTheme.titleMedium,
//                   ),

//                   Stack(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.notifications_none),
//                         onPressed: () {},
//                       ),
//                       Positioned(
//                         right: 10,
//                         top: 10,
//                         child: Container(
//                           height: 10,
//                           width: 10,
//                           decoration: const BoxDecoration(
//                             color: Colors.red,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       ),

// add these in 