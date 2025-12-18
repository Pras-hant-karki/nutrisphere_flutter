import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Edit Profile", style: Theme.of(context).textTheme.titleLarge),

              const SizedBox(height: 20),

              Center(
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage(
                    "assets/images/logo.png", // keep placeholder
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _info("Full name", "Sanyukta Ghimire"),
              _info("Username", "User"),
              _info("Email address", "shooy69@gmail.com"),
              _info("Phone number", "+977 9912631770"),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text("Log Out"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value),
          const Divider(),
        ],
      ),
    );
  }
}
