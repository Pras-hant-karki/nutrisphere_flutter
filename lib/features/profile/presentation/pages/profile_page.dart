import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController(text: "Sanyukta Ghimire");
  final _usernameCtrl = TextEditingController(text: "User");
  final _emailCtrl = TextEditingController(text: "piggy69@gmail.com");
  final _phoneCtrl = TextEditingController(text: "+977 9912631770");

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
              // TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Profile",
                    style: Theme.of(context).textTheme.titleLarge,
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

              const SizedBox(height: 20),

              Center(
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage:
                      const AssetImage("assets/images/logo.png"),
                ),
              ),

              const SizedBox(height: 20),

              _editableField("Full name", _nameCtrl),
              _editableField("Username", _usernameCtrl),
              _editableField("Email address", _emailCtrl),
              _editableField("Phone number", _phoneCtrl),

              const SizedBox(height: 10),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Save Changes"),
                ),
              ),

              const Spacer(),

              // LOGOUT BUTTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      "/login",
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Log Out"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
