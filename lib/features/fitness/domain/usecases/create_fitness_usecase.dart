import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/core/usecase/usecase.dart';
import 'package:nutrisphere_flutter/features/fitness/data/repositories/fitness_repository.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/repositories/fitness_repository.dart';

class CreateFitnessParams extends Equatable {
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

  const CreateFitnessParams({
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

  @override
  List<Object?> get props => [
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
}

final createFitnessUsecaseProvider = Provider<CreatefitnessUsecase>((ref) {
  final fitnessRepository = ref.read(fitnessRepositoryProvider);
  return CreatefitnessUsecase(fitnessRepository: fitnessRepository);
});

class CreatefitnessUsecase implements UsecaseWithParms<bool, CreateFitnessParams> {
  final IFitnessRepository _fitnessRepository;

  CreatefitnessUsecase({required IFitnessRepository fitnessRepository})
    : _fitnessRepository = fitnessRepository;

  @override
  Future<Either<Failure, bool>> call(CreateFitnessParams params) {
    final fitnessEntity = FitnessEntity(
      fitnessId: params.fitnessId,
      title: params.title,
      description: params.description,
      category: params.category,
      media: params.media,
      mediaType: params.mediaType,
    );

    return _fitnessRepository.createFitness(fitnessEntity);
  }
}
