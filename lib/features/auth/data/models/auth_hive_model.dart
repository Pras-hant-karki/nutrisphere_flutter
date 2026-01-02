import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:nutrisphere_flutter/core/constants/hive_table_constants.dart';
import 'package:nutrisphere_flutter/features/auth/domain/entities/auth_entity.dart';

// dart run command to generate the adapter:
// flutter packages pub run build_runner build --delete-conflicting-outputs
// dart run build_runner build -d
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

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
  }) : authId = authId ?? Uuid().v4();

  // From entity to Hive model
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      username: entity.username,
      email: entity.email,
      password: entity.password ?? '',
    );
  }

  // From Hive model to entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      username: username,
      email: email,
      password: password,
    );
  }

  // to entity list
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
