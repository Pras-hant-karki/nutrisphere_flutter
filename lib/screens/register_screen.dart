import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Gender selection variable
  String? selectedGender;

  // Date picker text controller
  TextEditingController dobController = TextEditingController();

  // Date picker 
  Future<void> pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(2025),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        dobController.text =
            "${date.day}/${date.month}/${date.year}"; // show date in textfield
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Back arrow
                IconButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, "/login"),
                  icon: const Icon(Icons.arrow_back),
                ),

                const SizedBox(height: 10),

                const Center(
                  child: Text(
                    "Registration",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Username
                const TextField(
                  decoration: InputDecoration(
                    labelText: "Username *",
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Country *",
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Phone number *",
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const TextField(
                  decoration: InputDecoration(
                    labelText: "Email *",
                  ),
                ),

                const SizedBox(height: 20),

                // Gender section
                const Text(
                  "Gender",
                  style: TextStyle(fontSize: 15),
                ),

                Row(
                  children: [
                    Radio(
                      value: "Male",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value.toString();
                        });
                      },
                    ),
                    const Text("Male"),

                    Radio(
                      value: "Female",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value.toString();
                        });
                      },
                    ),
                    const Text("Female"),
                  ],
                ),

                const SizedBox(height: 10),

                // Date of birth
                GestureDetector(
                  onTap: pickDate,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: dobController,
                      decoration: const InputDecoration(
                        labelText: "Date of birth",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const TextField(
                  decoration: InputDecoration(
                    labelText: "Password",
                  ),
                  obscureText: true,
                ),

                const SizedBox(height: 20),

                const TextField(
                  decoration: InputDecoration(
                    labelText: "Re-enter Password",
                  ),
                  obscureText: true,
                ),

                const SizedBox(height: 20),

                const TextField(
                  decoration: InputDecoration(
                    labelText: "Address",
                  ),
                ),

                const SizedBox(height: 40),

                // Register button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, "/login"),
                    child: const Text(
                      "Register",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
