import 'package:equatable/equatable.dart';

enum Gender { male, female, other }

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String username;
  final String email;
  final String? password;
  final String? profilePicture;

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.username,
    required this.email,
    this.password,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
        authId,
        fullName,
        username,
        email,
        password,
        profilePicture,
      ];
}
