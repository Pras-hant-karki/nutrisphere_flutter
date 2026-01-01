import 'package:hive/hive.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: 0)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String password;

  AuthHiveModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
  });
}
