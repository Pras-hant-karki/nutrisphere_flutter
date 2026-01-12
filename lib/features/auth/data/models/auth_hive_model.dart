import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:nutrisphere_flutter/core/constants/hive_table_constants.dart';
import 'package:nutrisphere_flutter/features/auth/domain/entities/auth_entity.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String password;

  // 🔥 NEW FIELDS (Sprint 4)
  @HiveField(5)
  final String? address;

  @HiveField(6)
  final DateTime? dateOfBirth;

  /// Stored as String: male / female / other
  @HiveField(7)
  final String? gender;

  /// Full phone number with country code (+97798xxxxxxx)
  @HiveField(8)
  final String? phoneNumber;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.phoneNumber,
  }) : authId = authId ?? const Uuid().v4();

  // ===================== MAPPERS =====================

  /// Entity → Hive
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      username: entity.username,
      email: entity.email,
      password: entity.password ?? '',
      address: entity.address,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender?.name, // enum → string
      phoneNumber: entity.phoneNumber,
    );
  }

  /// Hive → Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      username: username,
      email: email,
      password: password,
      address: address,
      dateOfBirth: dateOfBirth,
      gender: gender != null ? Gender.values.byName(gender!) : null,
      phoneNumber: phoneNumber,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
