import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/session_manage_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/admin_bio_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/user_management_page.dart';

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
                      title: 'Manage Sessions',
                      subtitle: 'Manage available sessions',
                      icon: Icons.calendar_month_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SessionManagePage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDashboardCard(
                      context,
                      index: 1,
                      title: 'User Management',
                      subtitle: 'Manage users and their roles',
                      icon: Icons.person_2_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserManagementPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDashboardCard(
                      context,
                      index: 2,
                      title: 'My Bio',
                      subtitle: 'Add your certifications, experience, and specialties',
                      icon: Icons.bar_chart_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminBioPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
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

