import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/core/usecase/usecase.dart';
import 'package:nutrisphere_flutter/features/profile/data/repositories/profile_repository.dart';
import 'package:nutrisphere_flutter/features/profile/domain/repositories/profile_repository.dart';

final uploadProfilePictureUsecaseProvider = Provider<UploadProfilePictureUsecase>((ref) {
  final profileRepository = ref.read(profileRepositoryProvider);
  return UploadProfilePictureUsecase(profileRepository: profileRepository);
});

class UploadProfilePictureUsecase implements UsecaseWithParms<String, File> {
  final IProfileRepository _profileRepository;  
  UploadProfilePictureUsecase({required IProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  @override
  Future<Either<Failure, String>> call(File profilePicture) {
    return _profileRepository.uploadProfilePicture(profilePicture);
  }
}
