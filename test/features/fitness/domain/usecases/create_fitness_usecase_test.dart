import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/usecases/create_fitness_usecase.dart';

void main() {
  group('CreateFitnessParams Tests', () {
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

    test('CreateFitnessParams with minimal params', () {
      // Arrange
      const params = CreateFitnessParams(
        title: 'Simple Fitness',
      );

      // Act
      final fitnessEntity = FitnessEntity(
        fitnessId: params.fitnessId,
        title: params.title,
        description: params.description,
        category: params.category,
        media: params.media,
        mediaType: params.mediaType,
      );

      // Assert
      expect(fitnessEntity.title, 'Simple Fitness');
      expect(fitnessEntity.fitnessId, isNull);
      expect(fitnessEntity.description, isNull);
      expect(fitnessEntity.category, isNull);
    });

    test('CreateFitnessParams creates FitnessEntity with all fields', () {
      // Arrange
      const params = CreateFitnessParams(
        fitnessId: 'fit_2',
        title: 'Strength Training',
        description: 'Full body strength',
        category: 'strength',
        media: 'https://example.com/strength.mp4',
        mediaType: 'video',
      );

      // Act
      final fitnessEntity = FitnessEntity(
        fitnessId: params.fitnessId,
        title: params.title,
        description: params.description,
        category: params.category,
        media: params.media,
        mediaType: params.mediaType,
      );

      // Assert
      expect(fitnessEntity.fitnessId, 'fit_2');
      expect(fitnessEntity.title, 'Strength Training');
      expect(fitnessEntity.description, 'Full body strength');
      expect(fitnessEntity.category, 'strength');
      expect(fitnessEntity.media, 'https://example.com/strength.mp4');
      expect(fitnessEntity.mediaType, 'video');
    });

    test('CreateFitnessParams preserves fitnessId', () {
      // Arrange
      const params = CreateFitnessParams(
        fitnessId: 'custom_id_123',
        title: 'Fitness',
      );

      // Act
      final fitnessEntity = FitnessEntity(
        fitnessId: params.fitnessId,
        title: params.title,
      );

      // Assert
      expect(fitnessEntity.fitnessId, 'custom_id_123');
    });

    test('CreateFitnessParams with category and duration', () {
      // Arrange
      const params = CreateFitnessParams(
        title: 'Workout',
        category: 'strength',
        duration: 90,
      );

      // Act & Assert
      expect(params.category, 'strength');
      expect(params.duration, 90);
    });

    test('CreateFitnessParams supports video media type', () {
      // Arrange
      const videoParams = CreateFitnessParams(
        title: 'Video Workout',
        media: 'https://example.com/video.mp4',
        mediaType: 'video',
      );

      // Act & Assert
      expect(videoParams.mediaType, 'video');
      expect(videoParams.media, 'https://example.com/video.mp4');
    });

    test('CreateFitnessParams supports image media type', () {
      // Arrange
      const imageParams = CreateFitnessParams(
        title: 'Image Workout',
        media: 'https://example.com/image.jpg',
        mediaType: 'image',
      );

      // Act & Assert
      expect(imageParams.mediaType, 'image');
      expect(imageParams.media, 'https://example.com/image.jpg');
    });

    test('CreateFitnessParams with special characters in title', () {
      // Arrange
      const params = CreateFitnessParams(
        title: 'Yoga & Pilates: Advanced Level',
      );

      // Act
      final fitnessEntity = FitnessEntity(
        fitnessId: params.fitnessId,
        title: params.title,
      );

      // Assert
      expect(fitnessEntity.title, 'Yoga & Pilates: Advanced Level');
    });

    test('CreateFitnessParams with special characters in description', () {
      // Arrange
      const params = CreateFitnessParams(
        title: 'Fitness',
        description: 'Test with @#\$%^&*() - Special chars!',
      );

      // Act
      final fitnessEntity = FitnessEntity(
        fitnessId: params.fitnessId,
        title: params.title,
        description: params.description,
      );

      // Assert
      expect(fitnessEntity.description, 'Test with @#\$%^&*() - Special chars!');
    });

    test('CreateFitnessParams with empty title', () {
      // Arrange & Act
      const params = CreateFitnessParams(
        title: '',
      );

      // Assert
      expect(params.title, '');
      expect(params.fitnessId, isNull);
    });

    test('CreateFitnessParams with very long description', () {
      // Arrange
      final longDescription = 'This is a very long description ' * 10;
      final params = CreateFitnessParams(
        title: 'Fitness',
        description: longDescription,
      );

      // Act
      final fitnessEntity = FitnessEntity(
        fitnessId: params.fitnessId,
        title: params.title,
        description: params.description,
      );

      // Assert
      expect(fitnessEntity.description, longDescription);
      expect(fitnessEntity.description?.length, greaterThan(100));
    });

    test('FitnessEntity list from multiple CreateFitnessParams', () {
      // Arrange
      final paramsList = [
        const CreateFitnessParams(title: 'Fitness 1', category: 'yoga'),
        const CreateFitnessParams(title: 'Fitness 2', category: 'cardio'),
        const CreateFitnessParams(title: 'Fitness 3', category: 'strength'),
      ];

      // Act
      final entities = paramsList
          .map((p) => FitnessEntity(
                fitnessId: p.fitnessId,
                title: p.title,
                category: p.category,
                description: p.description,
              ))
          .toList();

      // Assert
      expect(entities.length, 3);
      expect(entities[0].title, 'Fitness 1');
      expect(entities[1].category, 'cardio');
      expect(entities[2].title, 'Fitness 3');
    });

    test('CreateFitnessParams with createdBy fields', () {
      // Arrange
      const params = CreateFitnessParams(
        title: 'Fitness',
        createdBy: 'admin_123',
        createdByName: 'Admin Name',
      );

      // Act & Assert
      expect(params.createdBy, 'admin_123');
      expect(params.createdByName, 'Admin Name');
    });

    test('CreateFitnessParams with different durations', () {
      // Arrange
      final durations = [15, 30, 45, 60, 90, 120];
      final paramsList = durations
          .map((dur) => CreateFitnessParams(
                title: 'Workout $dur min',
                duration: dur,
              ))
          .toList();

      // Act & Assert
      expect(paramsList.length, 6);
      for (int i = 0; i < durations.length; i++) {
        expect(paramsList[i].duration, durations[i]);
      }
    });

    test('CreateFitnessParams nullable fields are null by default', () {
      // Arrange & Act
      const params = CreateFitnessParams(
        title: 'Basic',
      );

      // Assert
      expect(params.description, isNull);
      expect(params.category, isNull);
      expect(params.media, isNull);
      expect(params.mediaType, isNull);
      expect(params.createdBy, isNull);
      expect(params.createdByName, isNull);
      expect(params.duration, isNull);
      expect(params.createdAt, isNull);
      expect(params.updatedAt, isNull);
    });
  });
}
