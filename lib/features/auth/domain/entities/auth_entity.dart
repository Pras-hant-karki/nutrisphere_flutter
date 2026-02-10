import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String password;
  final String? confirmPassword;
  final String? role;
  final String? phone;

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    required this.password,
    this.confirmPassword,
    this.role,
    this.phone,
  });

  @override
  List<Object?> get props => [
        authId,
        fullName,
        email,
        password,
        confirmPassword,
        role,
        phone,
      ];
}
