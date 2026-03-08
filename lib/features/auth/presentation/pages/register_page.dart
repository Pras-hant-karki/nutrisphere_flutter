import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/utils/snackbar_utils.dart';
import 'package:nutrisphere_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:nutrisphere_flutter/features/auth/presentation/view_model/auth_view_model.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreedToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  /// Validates full name - min 2 chars, letters and spaces only
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Full name can only contain letters and spaces';
    }
    return null;
  }

  /// Validates email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password - min 6 chars
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates confirm password matches password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleSignup() async {
    if (!_agreedToTerms) {
      SnackbarUtils.showError(context, 'Please agree to Terms & Conditions');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // Call register with confirmPassword
    await ref.read(authViewModelProvider.notifier).register(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          confirmPassword: _confirmPasswordController.text.trim(),
        );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        // Auto-login after registration - navigate to dashboard
        Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
      } else if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(context, next.errorMessage ?? 'Registration failed');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Full Name Field
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                validator: _validateFullName,
                icon: Icons.person_outline,
              ),

              // Email Field
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
              ),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: _validatePassword,
                decoration: _buildInputDecoration(
                  label: 'Password',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                validator: _validateConfirmPassword,
                decoration: _buildInputDecoration(
                  label: 'Confirm Password',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Terms & Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (v) =>
                        setState(() => _agreedToTerms = v ?? false),
                  ),
                  const Expanded(
                    child: Text('I agree to the Terms & Conditions'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      authState.status == AuthStatus.loading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: authState.status == AuthStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Log in',
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
    );
  }

  /// Helper to build text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        validator: validator,
        decoration: _buildInputDecoration(
          label: label,
          icon: icon,
        ),
      ),
    );
  }

  /// Helper to build input decoration
  InputDecoration _buildInputDecoration({
    required String label,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    const borderRadius = BorderRadius.all(Radius.circular(20));

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.transparent,
      prefixIcon: icon != null ? Icon(icon) : null,
      suffixIcon: suffixIcon,
      // NORMAL STATE
      enabledBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: Colors.brown,
          width: 1.5,
        ),
      ),
      // FOCUSED STATE
      focusedBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: Colors.brown,
          width: 2,
        ),
      ),
      // ERROR STATE
      errorBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
      // FOCUSED ERROR STATE
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }
}

