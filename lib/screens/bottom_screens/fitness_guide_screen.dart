import 'package:flutter/material.dart';

class FitnessGuideScreen extends StatelessWidget {
  const FitnessGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    "High quality fitness\n guidance below !",
                    style: textTheme.titleMedium,
                  ),

                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 20),

                    _imageCard(
                      imagePath: 'assets/images/test.png',
                    ),

                    const SizedBox(height: 20),

                    _imageCard(
                      imagePath: 'assets/images/dose.png',
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // image card
  Widget _imageCard({required String imagePath}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }
}
