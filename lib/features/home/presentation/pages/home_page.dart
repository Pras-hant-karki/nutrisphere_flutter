import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/features/home/presentation/pages/session_view_page.dart';
import 'package:nutrisphere_flutter/features/home/presentation/pages/trainer_detail_page.dart';
import 'package:nutrisphere_flutter/features/home/presentation/pages/workout_record_page.dart';
import 'package:nutrisphere_flutter/features/notifications/presentation/widgets/notification_bell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _activeCardIndex;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Notification Bell in top right
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: NotificationBell(),
              ),
            ),
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
                      index: 0,
                      title: 'Sessions',
                      subtitle: 'Explore available sessions',
                      icon: Icons.calendar_month_rounded,
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
                      index: 1,
                      title: 'Workout Records',
                      subtitle: 'Track your workouts here everyday',
                      icon: Icons.bar_chart_outlined,
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
                      index: 2,
                      title: 'Trainer Details',
                      subtitle: 'Know your Trainer !',
                      icon: Icons.person_2_outlined,
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
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required int index,
  }) {
    final isActive = _activeCardIndex == index;
    return InkWell(
      onTap: () {
        onTap();
      },
      onTapDown: (_) => setState(() => _activeCardIndex = index),
      onTapCancel: () => setState(() => _activeCardIndex = null),
      onTapUp: (_) => setState(() => _activeCardIndex = null),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(color: AppColors.silver, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryDark,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 40, color: AppColors.primary),
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
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

