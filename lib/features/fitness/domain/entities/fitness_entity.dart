import 'package:equatable/equatable.dart';

class FitnessEntity extends Equatable {
  final String? fitnessId;
  final String title;
  final String? description;
  final String category; // 'yoga', 'cardio', 'strength', 'stretching', etc.
  final String? media; // URL to image/video
  final String? mediaType; // 'image' or 'video'
  final String? createdBy; // Admin ID who posted
  final String? createdByName; // Admin name for display
  final int? duration; // duration in minutes
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FitnessEntity({
    this.fitnessId,
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

  // CopyWith method for immutability
  FitnessEntity copyWith({
    String? fitnessId,
    String? title,
    String? description,
    String? category,
    String? media,
    String? mediaType,
    String? createdBy,
    String? createdByName,
    int? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FitnessEntity(
      fitnessId: fitnessId ?? this.fitnessId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      media: media ?? this.media,
      mediaType: mediaType ?? this.mediaType,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

