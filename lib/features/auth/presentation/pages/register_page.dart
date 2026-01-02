import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  String? gender;

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _dobCtrl.text = "${date.day}/${date.month}/${date.year}";
    }
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    // TODO (Sprint 3): Call AuthRepository.register()

    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                IconButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, "/login"),
                  icon: const Icon(Icons.arrow_back),
                ),

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

                _field("Username", _usernameCtrl),
                _field("Email", _emailCtrl,
                    validator: (v) =>
                        v!.contains("@") ? null : "Invalid email"),

                const SizedBox(height: 10),
                const Text("Gender"),

                Row(
                  children: [
                    Radio(
                      value: "Male",
                      groupValue: gender,
                      onChanged: (v) => setState(() => gender = v),
                    ),
                    const Text("Male"),
                    Radio(
                      value: "Female",
                      groupValue: gender,
                      onChanged: (v) => setState(() => gender = v),
                    ),
                    const Text("Female"),
                  ],
                ),

                GestureDetector(
                  onTap: pickDate,
                  child: AbsorbPointer(
                    child: _field("Date of Birth", _dobCtrl,
                        suffix: const Icon(Icons.calendar_today)),
                  ),
                ),

                _field("Password", _passwordCtrl, obscure: true),
                _field("Confirm Password", _confirmCtrl,
                    obscure: true,
                    validator: (v) => v != _passwordCtrl.text
                        ? "Passwords do not match"
                        : null),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _register,
                    child: const Text("Register",
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        validator: validator ??
            (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
