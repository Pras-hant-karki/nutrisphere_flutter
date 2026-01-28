import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/core/usecase/usecase.dart';
import 'package:nutrisphere_flutter/features/fitness/data/repositories/fitness_repository.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/repositories/fitness_repository.dart';

class UpdateFitnessParams extends Equatable {
  final String fitnessId;
  final String title;
  final String? description;
  final String? category;
  final String location;
  final String? claimedBy;
  final String? media;
  final String? mediaType;
  final bool? isClaimed;
  final String? status;

  const UpdateFitnessParams({
    required this.fitnessId,
    required this.title,
    this.description,
    this.category,
    required this.location,
    this.claimedBy,
    this.media,
    this.mediaType,
    this.isClaimed,
    this.status,
  });

  @override
  List<Object?> get props => [ // CopyWith method for immutability -enables safe state updates without mutation.
    fitnessId,
    title,
    description,
    category,
    location,
    claimedBy,
    media,
    mediaType,
    isClaimed,
    status,
  ];
}

final updateFitnessUsecaseProvider = Provider<UpdateFitnessUsecase>((ref) {
  final fitnessRepository = ref.read(fitnessRepositoryProvider);
  return UpdateFitnessUsecase(fitnessRepository: fitnessRepository);
});

class UpdateFitnessUsecase implements UsecaseWithParms<bool, UpdateFitnessParams> {
  final IFitnessRepository _fitnessRepository;
  UpdateFitnessUsecase({required IFitnessRepository fitnessRepository})
      : _fitnessRepository = fitnessRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateFitnessParams params) {
    final fitnessEntity = FitnessEntity(
      fitnessId: params.fitnessId,
      title: params.title,
      description: params.description,
      category: params.category,
      media: params.media,
      mediaType: params.mediaType,
    );

    return _fitnessRepository.updateFitness(fitnessEntity);
  }
}
