import 'package:nutrisphere_flutter/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? authId;
  final String fullName;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? role;
  final String? phone;
  final String? profilePicture;

  AuthApiModel({
    this.authId,
    required this.fullName,
    required this.email,
    this.password,
    this.confirmPassword,
    this.role,
    this.phone,
    this.profilePicture,
  });

  // =======================
  // TO JSON (APP → API)
  // =======================
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      if (confirmPassword != null) 'confirmPassword': confirmPassword,
      if (phone != null) 'phone': phone,
      if (profilePicture != null) 'profilePicture': profilePicture,
    };
  }

  // =======================
  // FROM JSON (API → APP)
  // =======================
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      authId: json['_id'] as String? ?? json['id'] as String?,
      fullName: json['fullName'] as String? ?? json['fullname'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      role: json['role'] as String?,
      phone: json['phone'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  // =======================
  // TO ENTITY (DATA → DOMAIN)
  // =======================
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email, 
      password: password ?? '',
      role: role,
      phone: phone,
      profilePicture: profilePicture,
    );
  }

  // =======================
  // FROM ENTITY (DOMAIN → DATA)
  // =======================
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      fullName: entity.fullName,
      email: entity.email,
      password: entity.password,
    );    
  }

  // =======================
  // TO ENTITY LIST (DATA → DOMAIN)
  // =======================
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
