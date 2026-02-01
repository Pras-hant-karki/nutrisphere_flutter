import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CreatefitnessUsecase createFitnessUsecase;
  late MockFitnessRepository mockFitnessRepository;

  setUp(() {
    mockFitnessRepository = MockFitnessRepository();
    createFitnessUsecase = CreatefitnessUsecase(
      fitnessRepository: mockFitnessRepository,
    );
  });

  group('CreateFitnessUsecase', () {
    test('CreateFitnessParams with required fields only', () {
      // Arrange & Act
      const params = CreateFitnessParams(
        title: 'Yoga Session',
      );

      // Assert
      expect(params.title, 'Yoga Session');
      expect(params.fitnessId, isNull);
      expect(params.description, isNull);
      expect(params.category, isNull);
    });

    test('CreateFitnessParams with all fields', () {
      // Arrange & Act
      const params = CreateFitnessParams(
        fitnessId: 'fit_1',
        title: 'Advanced Yoga',
        description: '60 minute advanced yoga',
        category: 'yoga',
        media: 'https://example.com/yoga.mp4',
        mediaType: 'video',
        createdBy: 'admin_1',
        createdByName: 'Yoga Master',
        duration: 60,
      );

      // Assert
      expect(params.fitnessId, 'fit_1');
      expect(params.title, 'Advanced Yoga');
      expect(params.description, '60 minute advanced yoga');
      expect(params.category, 'yoga');
      expect(params.media, 'https://example.com/yoga.mp4');
      expect(params.mediaType, 'video');
      expect(params.createdBy, 'admin_1');
      expect(params.createdByName, 'Yoga Master');
      expect(params.duration, 60);
    });

    test('CreateFitnessParams props include all fields for equality', () {
      // Arrange
      const params1 = CreateFitnessParams(
        fitnessId: 'fit_1',
        title: 'Yoga',
        description: 'desc',
        category: 'yoga',
        media: 'url',
        mediaType: 'video',
        createdBy: 'admin',
        createdByName: 'Name',
        duration: 30,
      );

      const params2 = CreateFitnessParams(
        fitnessId: 'fit_1',
        title: 'Yoga',
        description: 'desc',
        category: 'yoga',
        media: 'url',
        mediaType: 'video',
        createdBy: 'admin',
        createdByName: 'Name',
        duration: 30,
      );

      // Assert - Same props should be equal
      expect(params1, params2);
    });

    test('CreateFitnessParams props inequality', () {
      // Arrange
      const params1 = CreateFitnessParams(
        title: 'Yoga',
      );

      const params2 = CreateFitnessParams(
        title: 'Cardio',
      );

      // Assert - Different props should not be equal
      expect(params1, isNot(params2));
    });

    test('call() should create FitnessEntity and call repository', () async {
      // Arrange
      const params = CreateFitnessParams(
        fitnessId: 'fit_1',
        title: 'Strength Training',
        description: 'Full body strength',
        category: 'strength',
        media: 'https://example.com/strength.mp4',
        mediaType: 'video',
      );

      when(mockFitnessRepository.createFitness(any))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await createFitnessUsecase(params);

      // Assert
      expect(result, const Right(true));
      verify(mockFitnessRepository.createFitness(any)).called(1);
    });

    test('call() should pass correct FitnessEntity to repository', () async {
      // Arrange
      const params = CreateFitnessParams(
        fitnessId: 'fit_2',
        title: 'Cardio Blast',
        description: 'High intensity cardio',
        category: 'cardio',
        media: 'https://example.com/cardio.mp4',
        mediaType: 'video',
      );

      when(mockFitnessRepository.createFitness(any))
          .thenAnswer((_) async => const Right(true));

      // Act
      await createFitnessUsecase(params);

      // Assert - Capture the FitnessEntity passed
      final capturedArg = verify(mockFitnessRepository.createFitness(captureAny))
          .captured
          .single as FitnessEntity;

      expect(capturedArg.title, 'Cardio Blast');
      expect(capturedArg.description, 'High intensity cardio');
      expect(capturedArg.category, 'cardio');
      expect(capturedArg.media, 'https://example.com/cardio.mp4');
    });

    test('call() should return Right(true) on successful creation', () async {
      // Arrange
      const params = CreateFitnessParams(
        title: 'Yoga',
      );

      when(mockFitnessRepository.createFitness(any))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await createFitnessUsecase(params);

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse(() => false), true);
    });

    test('call() should return Left(Failure) on repository error', () async {
      // Arrange
      const params = CreateFitnessParams(
        title: 'Yoga',
      );

      final failure = LocaldatabaseFailure();
      when(mockFitnessRepository.createFitness(any))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await createFitnessUsecase(params);

      // Assert
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (_) => null), isA<Failure>());
    });

    test('call() should return Left(ApiFailure) on API error', () async {
      // Arrange
      const params = CreateFitnessParams(
        title: 'Fitness',
      );

      final failure = ApiFailure(statusCode: 500, message: 'Server error');
      when(mockFitnessRepository.createFitness(any))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await createFitnessUsecase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ApiFailure>());
          expect((failure as ApiFailure).statusCode, 500);
        },
        (_) => fail('Should return Left'),
      );
    });

    test('call() should return Left(NetworkFailure) on network error', () async {
      // Arrange
      const params = CreateFitnessParams(
        title: 'Fitness',
      );

      final failure = NetworkFailure();
      when(mockFitnessRepository.createFitness(any))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await createFitnessUsecase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
        },
        (_) => fail('Should return Left'),
      );
    });

    test('call() with minimal params creates entity with only title', () async {
      // Arrange
      const params = CreateFitnessParams(
        title: 'Simple Fitness',
      );

      when(mockFitnessRepository.createFitness(any))
          .thenAnswer((_) async => const Right(true));

      // Act
      await createFitnessUsecase(params);

      // Assert
      final capturedEntity =
          verify(mockFitnessRepository.createFitness(captureAny))
              .captured
              .single as FitnessEntity;

      expect(capturedEntity.title, 'Simple Fitness');
      expect(capturedEntity.fitnessId, isNull);
      expect(capturedEntity.description, isNull);
      expect(capturedEntity.category, isNull);
    });

    test('call() does not pass createdBy and createdByName to entity', () async {
      // Arrange
      const params = CreateFitnessParams(
        title: 'Fitness',
        createdBy: 'admin_123',
        createdByName: 'Admin Name',
        duration: 45,
      );

      when(mockFitnessRepository.createFitness(any))
          .thenAnswer((_) async => const Right(true));

      // Act
      await createFitnessUsecase(params);

      // Assert - Verify that createdBy and createdByName are NOT in the entity
      final capturedEntity =
          verify(mockFitnessRepository.createFitness(captureAny))
              .captured
              .single as FitnessEntity;

      expect(capturedEntity.createdBy, isNull);
      expect(capturedEntity.createdByName, isNull);
    });

    test('call() preserves fitnessId in entity creation', () async {
      // Arrange
      const params = CreateFitnessParams(
        fitnessId: 'custom_id_123',
        title: 'Fitness',
      );

      when(mockFitnessRepository.createFitness(any))
          .thenAnswer((_) async => const Right(true));

      // Act
      await createFitnessUsecase(params);

      // Assert
      final capturedEntity =
          verify(mockFitnessRepository.createFitness(captureAny))
              .captured
              .single as FitnessEntity;

      expect(capturedEntity.fitnessId, 'custom_id_123');
    });

    test('call() with category and duration preserves them in entity', () async {
      // Arrange
      const params = CreateFitnessParams(
        title: 'Workout',
        category: 'strength',
        duration: 90,
      );

      when(mockFitnessRepository.createFitness(any))
          .thenAnswer((_) async => const Right(true));

      // Act
      await createFitnessUsecase(params);

      // Assert
      final capturedEntity =
          verify(mockFitnessRepository.createFitness(captureAny))
              .captured
              .single as FitnessEntity;

      expect(capturedEntity.category, 'strength');
      expect(capturedEntity.duration, 90);
    });

    test('call() with different media types', () async {
      // Arrange - Video
      const videoParams = CreateFitnessParams(
        title: 'Video Workout',
        media: 'https://example.com/video.mp4',
        mediaType: 'video',
      );

      when(mockFitnessRepository.createFitness(any))
          .thenAnswer((_) async => const Right(true));

      // Act
      await createFitnessUsecase(videoParams);

      // Assert
      var capturedEntity =
          verify(mockFitnessRepository.createFitness(captureAny))
              .captured
              .single as FitnessEntity;

      expect(capturedEntity.mediaType, 'video');

      // Now test with image
      reset(mockFitnessRepository);
      when(mockFitnessRepository.createFitness(any))
          .thenAnswer((_) async => const Right(true));

      const imageParams = CreateFitnessParams(
        title: 'Image Workout',
        media: 'https://example.com/image.jpg',
        mediaType: 'image',
      );

      await createFitnessUsecase(imageParams);

      capturedEntity =
          verify(mockFitnessRepository.createFitness(captureAny))
              .captured
              .single as FitnessEntity;

      expect(capturedEntity.mediaType, 'image');
    });

    test('CreatefitnessUsecase is properly instantiated', () {
      // Assert
      expect(createFitnessUsecase, isA<CreatefitnessUsecase>());
    });

    test('call() multiple times should work independently', () async {
      // Arrange
      const params1 = CreateFitnessParams(title: 'Fitness 1');
      const params2 = CreateFitnessParams(title: 'Fitness 2');

      when(mockFitnessRepository.createFitness(any))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result1 = await createFitnessUsecase(params1);
      final result2 = await createFitnessUsecase(params2);

      // Assert
      expect(result1, const Right(true));
      expect(result2, const Right(true));
      verify(mockFitnessRepository.createFitness(any)).called(2);
    });
  });
}