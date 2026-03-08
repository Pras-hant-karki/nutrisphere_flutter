import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';

abstract class IProfileRepository {
  Future<Either<Failure, String>> uploadProfilePicture(File image);
}
