import 'package:hive/hive.dart';
import 'package:nutrisphere_flutter/core/constants/hive_table_constants.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';
import 'package:uuid/uuid.dart';

part 'fitness_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.fitnessTypeId)
class FitnessHiveModel extends HiveObject {
  @HiveField(0)
  final String? fitnessId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String category; // 'yoga', 'cardio', 'strength', 'stretching', etc.

  @HiveField(4)
  final String? media; // URL to image/video

  @HiveField(5)
  final String? mediaType; // 'image' or 'video'

  @HiveField(6)
  final String? createdBy; // Admin ID who posted

  @HiveField(7)
  final String? difficulty; // 'beginner', 'intermediate', 'advanced'

  @HiveField(8)
  final int? duration; // duration in minutes

  FitnessHiveModel({
    String? fitnessId,
    required this.title,
    this.description,
    required this.category,
    this.media,
    this.mediaType,
    this.createdBy,
    this.difficulty,
    this.duration,
  }) : fitnessId = fitnessId ?? const Uuid().v4();

  FitnessEntity toEntity() {
    return FitnessEntity(
      fitnessId: fitnessId,
      title: title,
      description: description,
      category: category,
      media: media,
      mediaType: mediaType,
      createdBy: createdBy,
      difficulty: difficulty,
      duration: duration,
    );
  }

  factory FitnessHiveModel.fromEntity(FitnessEntity entity) {
    return FitnessHiveModel(
      fitnessId: entity.fitnessId,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      media: entity.media,
      mediaType: entity.mediaType,
      createdBy: entity.createdBy,
      difficulty: entity.difficulty,
      duration: entity.duration,
    );
  }

  static List<FitnessEntity> toEntityList(List<FitnessHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
