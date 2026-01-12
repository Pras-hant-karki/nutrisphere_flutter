import 'package:equatable/equatable.dart';

enum Gender { male, female, other }

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String username;
  final String email;
  final String? password;
  final String? profilePicture;

  // 🔥 NEW FIELDS (Sprint 4)
  final String? address;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final String? phoneNumber; // include country code, e.g. +97798xxxxxxx

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.username,
    required this.email,
    this.password,
    this.profilePicture,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [
        authId,
        fullName,
        username,
        email,
        password,
        profilePicture,
        address,
        dateOfBirth,
        gender,
        phoneNumber,
      ];
}
