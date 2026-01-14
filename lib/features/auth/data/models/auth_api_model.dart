import 'package:lost_n_found/features/batch/domain/entities/batch_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String? status;

  AuthApiModel({this.id, required this.fullName, this.status});

  // toJSON
  Map<String, dynamic> toJson() {
    return {"fullName": fullName};
  }

  // FromJSON
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] as String,
      fullName: json['fullName'] as String,
      status: json['status'] as String,
    );
  }

  //toEntity
  BatchEntity toEntity() {
    return BatchEntity(batchId: id, batchName: 'UK-$fullName', status: status);
  }

  // fromEntitiy
  factory AuthApiModel.fromEntity(BatchEntity entity) {
    return AuthApiModel(fullName: entity.batchName);
  }

  // toEntityList
  static List<BatchEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  //fromEntityList
}
