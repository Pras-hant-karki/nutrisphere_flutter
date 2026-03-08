import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/features/appointment/presentation/pages/appointment_booking_page.dart';
import 'package:nutrisphere_flutter/features/appointment/presentation/pages/request_plan_page.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int? _activeCardIndex;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // HEADER
              Text(
                "Choose any service below !",
                style: textTheme.titleMedium,
              ),

              const SizedBox(height: 30),

              _actionButton(
                context,
                index: 0,
                title: "Request Diet &\nWorkout Plan",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RequestPlanScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _actionButton(
                context,
                index: 1,
                title: "Book PT\nAppointment",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppointmentBookingScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    required int index,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 130,
      child: InkWell(
        onTap: onTap,
        onTapDown: (_) => setState(() => _activeCardIndex = index),
        onTapCancel: () => setState(() => _activeCardIndex = null),
        onTapUp: (_) => setState(() => _activeCardIndex = null),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: _activeCardIndex == index
                ? Border.all(color: AppColors.silver, width: 1.5)
                : null,
            boxShadow: AppColors.softShadow,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
