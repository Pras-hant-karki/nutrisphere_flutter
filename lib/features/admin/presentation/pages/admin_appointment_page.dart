import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/view_request_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/view_appointment_page.dart';

class AdminAppointmentPage extends StatefulWidget {
  const AdminAppointmentPage({super.key});

  @override
  State<AdminAppointmentPage> createState() => _AdminAppointmentPageState();
}

class _AdminAppointmentPageState extends State<AdminAppointmentPage> {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "View Members Requests",
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox.shrink(),
                ],
              ),

              const SizedBox(height: 30),

              _actionButton(
                context,
                index: 0,
                title: "View Plan &\nRequests",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ViewRequestPage(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _actionButton(
                context,
                index: 1,
                title: "View PT\nAppointment",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ViewAppointmentPage(),
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
