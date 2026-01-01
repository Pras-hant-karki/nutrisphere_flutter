import 'package:flutter/material.dart';

class SessionViewScreen extends StatelessWidget {
  const SessionViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context); // back to Home
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Sessions",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                ],
              ),
            ),

            const SizedBox(height: 10),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Group Session card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Group Session",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          "more details",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.black54),
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Workout details card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Circuit Workout (Starts at 8 AM, 11/23/2025)",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("1. Devils Press"),
                        Text("2. Air Bike"),
                        Text("3. Bodyweight Squats"),
                        Text("4. Pushup"),
                        Text("5. Farmer walk"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade300,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
