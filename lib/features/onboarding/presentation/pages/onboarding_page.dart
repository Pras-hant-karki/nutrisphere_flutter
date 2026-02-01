import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/pt.png",
      "title": "Personal Training",
      "subtitle": "Get all personalized instruction and workout tips staying at home",
    },
    {
      "image": "assets/images/plan.png",
      "title": "Personal Plans",
      "subtitle": "Get personalized diet and workout plans based on your goal",
    },
    {
      "image": "assets/images/track.png",
      "title": "Progress Tracking",
      "subtitle": "Track all your fitness progress in one place",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 300,
                          child: Image.asset(
                            onboardingData[index]["image"]!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        Text(
                          onboardingData[index]["title"]!,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        Text(
                          onboardingData[index]["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.silver,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 5),
                  height: 8,
                  width: _currentPage == index ? 20 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.secondaryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Next / Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (_currentPage == onboardingData.length - 1) {
                      Navigator.pushReplacementNamed(context, "/login");
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    _currentPage == onboardingData.length - 1
                        ? "Get Started"
                        : "Next",
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            
            // Skip Button
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, "/login");
              },
              child: const Text(
                "Skip",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
