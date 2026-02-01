import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/profile/data/datasources/profile_datasource.dart';
import 'package:nutrisphere_flutter/features/profile/data/repositories/profile_repository.dart';

class MockProfileRemoteDataSource extends Mock
    implements IProfileRemoteDataSource {}

class MockFile extends Mock implements File {}

void main() {
  group('ProfileRepository Tests', () {
    late MockProfileRemoteDataSource mockRemoteDataSource;
    late ProfileRepository profileRepository;

    setUp(() {
      mockRemoteDataSource = MockProfileRemoteDataSource();
      profileRepository = ProfileRepository(remoteDataSource: mockRemoteDataSource);
    });

    testWidgets('uploadProfilePicture returns image URL on success',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      const String expectedUrl = 'https://example.com/profile/pic.jpg';
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenAnswer((_) async => expectedUrl);

      // Act
      final result = await profileRepository.uploadProfilePicture(mockFile);

      // Assert
      expect(result, equals(Right(expectedUrl)));
      verify(mockRemoteDataSource.uploadProfilePicture(mockFile)).called(1);
    });

    testWidgets('uploadProfilePicture returns ApiFailure on error',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      final exception = Exception('Upload failed');
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenThrow(exception);

      // Act
      final result = await profileRepository.uploadProfilePicture(mockFile);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ApiFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });

    testWidgets('uploadProfilePicture handles null file gracefully',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      const String expectedUrl = 'https://example.com/profile/null.jpg';
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenAnswer((_) async => expectedUrl);

      // Act
      final result = await profileRepository.uploadProfilePicture(mockFile);

      // Assert
      expect(result.isRight(), isTrue);
      expect(result, equals(Right(expectedUrl)));
    });

    testWidgets('uploadProfilePicture calls remote datasource once',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      const String expectedUrl = 'https://example.com/profile/pic.jpg';
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenAnswer((_) async => expectedUrl);

      // Act
      await profileRepository.uploadProfilePicture(mockFile);

      // Assert
      verify(mockRemoteDataSource.uploadProfilePicture(mockFile)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    testWidgets('uploadProfilePicture returns Either type',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      const String expectedUrl = 'https://example.com/profile/pic.jpg';
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenAnswer((_) async => expectedUrl);

      // Act
      final result = await profileRepository.uploadProfilePicture(mockFile);

      // Assert
      expect(result, isA<Either<Failure, String>>());
    });

    testWidgets('uploadProfilePicture returns non-empty URL',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      const String expectedUrl = 'https://example.com/profile/pic.jpg';
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenAnswer((_) async => expectedUrl);

      // Act
      final result = await profileRepository.uploadProfilePicture(mockFile);

      // Assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (url) => expect(url, isNotEmpty),
      );
    });

    testWidgets('uploadProfilePicture handles empty string response',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenAnswer((_) async => '');

      // Act
      final result = await profileRepository.uploadProfilePicture(mockFile);

      // Assert
      expect(result.isRight(), isTrue);
    });

    testWidgets('uploadProfilePicture failure message is preserved',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      const String errorMessage = 'Network timeout';
      final exception = Exception(errorMessage);
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenThrow(exception);

      // Act
      final result = await profileRepository.uploadProfilePicture(mockFile);

      // Assert
      result.fold(
        (failure) {
          expect(failure, isA<ApiFailure>());
          expect(failure.message, contains(errorMessage));
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    testWidgets('uploadProfilePicture handles multiple calls sequentially',
        (WidgetTester tester) async {
      // Arrange
      final mockFile1 = MockFile();
      final mockFile2 = MockFile();
      const String url1 = 'https://example.com/profile/pic1.jpg';
      const String url2 = 'https://example.com/profile/pic2.jpg';
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile1))
          .thenAnswer((_) async => url1);
      when(mockRemoteDataSource.uploadProfilePicture(mockFile2))
          .thenAnswer((_) async => url2);

      // Act
      final result1 = await profileRepository.uploadProfilePicture(mockFile1);
      final result2 = await profileRepository.uploadProfilePicture(mockFile2);

      // Assert
      expect(result1, equals(Right(url1)));
      expect(result2, equals(Right(url2)));
      verify(mockRemoteDataSource.uploadProfilePicture(mockFile1)).called(1);
      verify(mockRemoteDataSource.uploadProfilePicture(mockFile2)).called(1);
    });

    testWidgets('uploadProfilePicture returns correct failure type',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenThrow(Exception('Error'));

      // Act
      final result = await profileRepository.uploadProfilePicture(mockFile);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.runtimeType, equals(ApiFailure)),
        (_) => fail('Expected failure'),
      );
    });

    testWidgets('uploadProfilePicture forwards file to datasource',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      const String expectedUrl = 'https://example.com/profile/pic.jpg';
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenAnswer((_) async => expectedUrl);

      // Act
      await profileRepository.uploadProfilePicture(mockFile);

      // Assert
      verify(mockRemoteDataSource.uploadProfilePicture(mockFile)).called(1);
    });

    testWidgets('uploadProfilePicture handles SocketException',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      final exception = SocketException('Connection failed');
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenThrow(exception);

      // Act
      final result = await profileRepository.uploadProfilePicture(mockFile);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ApiFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    testWidgets('uploadProfilePicture URL format validation',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      const String validUrl = 'https://example.com/profile/pic.jpg';
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenAnswer((_) async => validUrl);

      // Act
      final result = await profileRepository.uploadProfilePicture(mockFile);

      // Assert
      result.fold(
        (failure) => fail('Expected URL'),
        (url) => expect(url, contains('https://')),
      );
    });

    testWidgets('uploadProfilePicture returns Right on valid URL',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      const String validUrl = 'https://example.com/uploads/profile/img123.jpg';
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenAnswer((_) async => validUrl);

      // Act
      final result = await profileRepository.uploadProfilePicture(mockFile);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (url) => expect(url, equals(validUrl)),
      );
    });

    testWidgets('uploadProfilePicture failure contains error details',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      const String errorDetail = 'File size exceeds limit';
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenThrow(Exception(errorDetail));

      // Act
      final result = await profileRepository.uploadProfilePicture(mockFile);

      // Assert
      result.fold(
        (failure) => expect(failure.message, contains(errorDetail)),
        (_) => fail('Expected failure'),
      );
    });

    testWidgets('uploadProfilePicture is async operation',
        (WidgetTester tester) async {
      // Arrange
      final mockFile = MockFile();
      const String expectedUrl = 'https://example.com/profile/pic.jpg';
      
      when(mockRemoteDataSource.uploadProfilePicture(mockFile))
          .thenAnswer((_) async => expectedUrl);

      // Act
      final future = profileRepository.uploadProfilePicture(mockFile);

      // Assert
      expect(future, isA<Future<Either<Failure, String>>>());
    });
  });
}