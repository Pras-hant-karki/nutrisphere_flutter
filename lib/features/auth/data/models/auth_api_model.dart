import 'package:nutrisphere_flutter/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? authId;
  final String fullname;
  final String email;
  final String? password;

  AuthApiModel({
    this.authId,
    required this.fullname,
    required this.email,
    this.password,
  });

  // =======================
  // TO JSON (APP → API)
  // =======================
  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'email': email,
      'password': password,
    };
  }

  // =======================
  // FROM JSON (API → APP)
  // =======================
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      authId: json['_authId'] as String,
      fullname: json['fullname'] as String,
      email: json['email'] as String,
    );
  }

  // =======================
  // TO ENTITY (DATA → DOMAIN)
  // =======================
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullname,
      email: email,
    );
  }

  // =======================
  // FROM ENTITY (DOMAIN → DATA)
  // =======================
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      fullname: entity.fullName,
      email: entity.email,
    );    
  }

  // =======================
  // TO ENTITY LIST (DATA → DOMAIN)
  // =======================
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
