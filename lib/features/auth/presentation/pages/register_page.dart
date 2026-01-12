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
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _agreedToTerms = false;
  String _selectedCountryCode = '+977';
  String _gender = 'Male';
  DateTime? _dob;

  Future<void> _handleSignup() async {
    if (!_agreedToTerms) {
      SnackbarUtils.showError(context, 'Please agree to Terms & Conditions');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    await ref.read(authViewModelProvider.notifier).register(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          username: _nameController.text.trim().split(' ').first,
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
      appBar: AppBar(title: const Text('Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _input(_nameController, 'Full Name *'),

              // Country + Phone
              Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCountryCode,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        border: UnderlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: '+977', child: Text('+977')),
                        DropdownMenuItem(value: '+91', child: Text('+91')),
                        DropdownMenuItem(value: '+1', child: Text('+1')),
                      ],
                      onChanged: (v) => setState(() => _selectedCountryCode = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _input(
                      _phoneController,
                      'Phone number *',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),

              _input(_emailController, 'Email *'),

              // Gender
              const SizedBox(height: 8),
              const Text('Gender'),
              Row(
                children: [
                  Radio<String>(
                    value: 'Male',
                    groupValue: _gender,
                    onChanged: (v) => setState(() => _gender = v!),
                  ),
                  const Text('Male'),
                  Radio<String>(
                    value: 'Female',
                    groupValue: _gender,
                    onChanged: (v) => setState(() => _gender = v!),
                  ),
                  const Text('Female'),
                ],
              ),

              // Date of Birth
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    initialDate: DateTime(2000),
                  );
                  if (picked != null) setState(() => _dob = picked);
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Date of birth',
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _dob == null
                          ? ''
                          : '${_dob!.year}-${_dob!.month}-${_dob!.day}',
                    ),
                  ),
                ),
              ),

              _input(_passwordController, 'Password', obscure: true),
              _input(
                _confirmPasswordController,
                'Re-enter Password',
                obscure: true,
                validator: (v) =>
                    v == _passwordController.text ? null : 'Passwords do not match',
              ),

              _input(_addressController, 'Address'),

              const SizedBox(height: 12),

              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (v) =>
                        setState(() => _agreedToTerms = v ?? false),
                  ),
                  const Expanded(
                    child: Text('I agree to terms and condition'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.status == AuthStatus.loading
                      ? null
                      : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: authState.status == AuthStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator ??
            (v) => v != null && v.isNotEmpty ? null : 'Required',
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }
}
