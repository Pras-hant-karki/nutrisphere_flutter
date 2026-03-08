import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/profile/domain/repositories/profile_repository.dart';
import 'package:nutrisphere_flutter/features/profile/domain/usecases/upload_profile_picture_usecase.dart';

class _FakeProfileRepository implements IProfileRepository {
  @override
  Future<Either<Failure, String>> uploadProfilePicture(File image) async {
    return const Right('/uploads/profile.jpg');
  }
}

void main() {
  test('UploadProfilePictureUsecase returns uploaded url', () async {
    final usecase = UploadProfilePictureUsecase(profileRepository: _FakeProfileRepository());

    final result = await usecase(File('profile.jpg'));

    expect(result, const Right('/uploads/profile.jpg'));
  });
}