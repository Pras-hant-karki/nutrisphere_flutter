import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool rememberMe = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    // TODO (Sprint 3): Call AuthRepository.login()
    // final result = await authRepo.login(...);

    Navigator.pushReplacementNamed(context, "/dashboard");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                IconButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, "/onboarding"),
                  icon: const Icon(Icons.arrow_back),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Log in",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter username" : null,
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? "Min 6 characters" : null,
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (v) =>
                              setState(() => rememberMe = v!),
                        ),
                        const Text("Remember me"),
                      ],
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, "/forgot"),
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text("Log in", style: TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 15),

                _socialButton(
                  icon: Icons.g_mobiledata,
                  label: "Continue with Google",
                ),
                const SizedBox(height: 10),
                _socialButton(
                  icon: Icons.apple,
                  label: "Continue with Apple",
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, "/register"),
                      child: const Text(
                        "Register!",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton({required IconData icon, required String label}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
