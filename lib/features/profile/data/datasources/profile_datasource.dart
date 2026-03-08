import 'dart:io';

abstract class IProfileRemoteDataSource {
  Future<String> uploadProfilePicture(File image);
}
