import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/core/usecase/usecase.dart';
import 'package:nutrisphere_flutter/features/fitness/data/repositories/fitness_repository.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/repositories/fitness_repository.dart';

final uploadPhotoUsecaseProvider = Provider<UploadPhotoUsecase>((ref) {
  final fitnessRepository = ref.read(fitnessRepositoryProvider);
  return UploadPhotoUsecase(fitnessRepository: fitnessRepository);
});

class UploadPhotoUsecase implements UsecaseWithParms<String, File> {
  final IFitnessRepository _fitnessRepository;  
  UploadPhotoUsecase({required IFitnessRepository fitnessRepository})
      : _fitnessRepository = fitnessRepository;

  @override
  Future<Either<Failure, String>> call(File photo) {
    return _fitnessRepository.uploadPhoto(photo);
  }
}


