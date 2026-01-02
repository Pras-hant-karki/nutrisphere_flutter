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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_agreedToTerms) {
      SnackbarUtils.showError(
        context,
        'Please agree to Terms & Conditions',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    await ref.read(authViewModelProvider.notifier).register(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          username: _emailController.text.trim().split('@').first,
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(context, 'Registration successful');
        Navigator.pop(context);
      } else if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'Full Name'),
                validator: (v) =>
                    v != null && v.length >= 3 ? null : 'Invalid name',
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Invalid email',
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (v) =>
                    v != null && v.length >= 6 ? null : 'Min 6 chars',
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                validator: (v) => v == _passwordController.text
                    ? null
                    : 'Passwords do not match',
              ),

              const SizedBox(height: 20),

              CheckboxListTile(
                value: _agreedToTerms,
                onChanged: (v) =>
                    setState(() => _agreedToTerms = v ?? false),
                title: const Text('I agree to Terms & Conditions'),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: authState.status == AuthStatus.loading
                    ? null
                    : _handleSignup,
                child: authState.status == AuthStatus.loading
                    ? const CircularProgressIndicator()
                    : const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
