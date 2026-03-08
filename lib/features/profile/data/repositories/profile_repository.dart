import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/profile/data/datasources/profile_datasource.dart';
import 'package:nutrisphere_flutter/features/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:nutrisphere_flutter/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepository(
    remoteDataSource: ref.read(profileRemoteDatasourceProvider),
  );
});

class ProfileRepository implements IProfileRepository {
  final IProfileRemoteDataSource _remoteDataSource;

  ProfileRepository({required IProfileRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, String>> uploadProfilePicture(File image) async {
    try {
      final imagePath = await _remoteDataSource.uploadProfilePicture(image);
      return Right(imagePath);
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }
}
