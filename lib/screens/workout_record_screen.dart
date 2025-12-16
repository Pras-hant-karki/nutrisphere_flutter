import 'package:flutter/material.dart';

class WorkoutRecordScreen extends StatefulWidget {
  const WorkoutRecordScreen({super.key});

  @override
  State<WorkoutRecordScreen> createState() => _WorkoutRecordScreenState();
}

class _WorkoutRecordScreenState extends State<WorkoutRecordScreen> {
  final TextEditingController _controller = TextEditingController();

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
                  const Text(
                    "Workout Records",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Scrollable writing pad
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null, // unlimited lines
                    expands: true, // fills available space
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          "Week-1\nFriday:\n1. Leg Press - 200kg 4x12\n2. Hack Squat - 60kg 4x12\n3. Romanian Deadlift - 60kg 4x12\n\nWeek-2\nSunday:\n",
                      hintStyle: TextStyle(
                      fontFamily: 'Montserrat LightItalic',
                      fontWeight: FontWeight.w900, 
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
