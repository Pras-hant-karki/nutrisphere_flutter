import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';

class FitnessApiModel {
  final String? id;
  final String title;
  final String? description;
  final String? category; // 'yoga', 'cardio', 'strength', 'stretching', etc.
  final String? media; // URL to image/video
  final String? mediaType; // 'image' or 'video'
  final String? createdBy; // Admin ID who posted
  final String? createdByName; // Admin name for display
  final int? duration; // duration in minutes
  final DateTime? createdAt;
  final DateTime? updatedAt;

//constructor
  FitnessApiModel({
    this.id,
    required this.title,
    this.description,
    required this.category,
    this.media,
    this.mediaType,
    this.createdBy,
    this.createdByName,
    this.duration,
    this.createdAt,
    this.updatedAt,
  });

  String? get fitnessId => id;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      if (description != null) 'description': description,
      if (media != null) 'media': media,
      if (mediaType != null) 'mediaType': mediaType,
      if (duration != null) 'duration': duration,
    };
  }

  factory FitnessApiModel.fromJson(Map<String, dynamic> json) {
    // Handle nested objects - server returns createdBy as object sometimes
    String? extractId(dynamic value) {
      if (value == null) return null;
      if (value is Map) return value['_id'] as String?;
      return value as String?;
    }

    String? extractName(dynamic value) {
      if (value == null) return null;
      if (value is Map) return value['fullName'] as String? ?? value['name'] as String?;
      return value as String?;
    }

    // Handle backend response format
    String? category;
    String? media;
    String? mediaType;

    // Backend returns 'tags' as array, take first one as category
    if (json['tags'] is List && (json['tags'] as List).isNotEmpty) {
      category = (json['tags'] as List).first as String?;
    }

    // Backend returns 'image', map to media and mediaType
    if (json['image'] != null) {
      media = json['image'] as String;
      mediaType = 'image';
    }

    return FitnessApiModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: category,
      media: media,
      mediaType: mediaType,
      createdBy: extractId(json['createdBy']),
      createdByName: json['adminName'] as String?, // Backend uses adminName
      duration: json['duration'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  FitnessEntity toEntity() {
    return FitnessEntity(
      fitnessId: id,
      title: title,
      description: description,
      category: category,
      media: media,
      mediaType: mediaType,
      createdBy: createdBy,
      createdByName: createdByName,
      duration: duration,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory FitnessApiModel.fromEntity(FitnessEntity entity) {
    return FitnessApiModel(
      id: entity.fitnessId,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      media: entity.media,
      mediaType: entity.mediaType,
      createdBy: entity.createdBy,
      createdByName: entity.createdByName,
      duration: entity.duration,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<FitnessEntity> toEntityList(List<FitnessApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
