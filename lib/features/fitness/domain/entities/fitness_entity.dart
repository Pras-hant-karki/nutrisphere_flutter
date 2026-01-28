import 'package:equatable/equatable.dart';

class FitnessEntity extends Equatable {
  final String? fitnessId;
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

  const FitnessEntity({
    this.fitnessId,
    required this.title,
    this.description,
    this.category,
    this.media,
    this.mediaType,
    this.createdBy,
    this.createdByName,
    this.duration,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [ //prps enables equality checks
    fitnessId,
    title,
    description,
    category,
    media,
    mediaType,
    createdBy,
    createdByName,
    duration,
    createdAt,
    updatedAt,
  ];
  // ======================== PROPS EXAMPLE ========================
  // Example of how props are used for equality checks:

  // final entity1 = FitnessEntity(fitnessId: '1', title: 'Yoga');
  // final entity2 = FitnessEntity(fitnessId: '1', title: 'Yoga');
  // print(entity1 == entity2); // true

  // Without props: fitness1 == fitness2 → false (different objects)
  // With props: fitness1 == fitness2 → true (same values)
  // ========================= PROPS END ========================



  // CopyWith method for immutability -
  // enables safe state updates without mutation creating a new instance
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

  // ======================== copyWith EXAMPLE ========================
  // final originalFitness = FitnessEntity(
  //   title: 'Yoga',
  //   category: 'stretching',
  //   duration: 30,
  // );

  // Update only the duration, keep title and category
  // final updatedFitness = originalFitness.copyWith(duration: 45);

  // Result: title='Yoga', category='stretching', duration=45
  // originalFitness remains unchanged (immutable)
  // ========================= copyWith END ========================
  

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
}


