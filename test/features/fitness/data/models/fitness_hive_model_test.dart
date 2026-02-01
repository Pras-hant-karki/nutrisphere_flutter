import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/features/fitness/data/models/fitness_hive_model.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';

void main() {
  group('FitnessHiveModel', () {
    test('FitnessHiveModel constructor creates instance with required fields', () {
      // Arrange
      const title = 'Morning Yoga';
      const description = '30 min beginner yoga';
      const category = 'yoga';

      // Act
      final model = FitnessHiveModel(
        fitnessId: 'fit_1',
        title: title,
        description: description,
        category: category,
      );

      // Assert
      expect(model.fitnessId, 'fit_1');
      expect(model.title, title);
      expect(model.description, description);
      expect(model.category, category);
    });

    test('FitnessHiveModel generates UUID when fitnessId is not provided', () {
      // Arrange
      const title = 'Cardio Workout';

      // Act
      final model1 = FitnessHiveModel(
        title: title,
      );
      final model2 = FitnessHiveModel(
        title: title,
      );

      // Assert
      expect(model1.fitnessId, isNotNull);
      expect(model2.fitnessId, isNotNull);
      expect(model1.fitnessId, isNotEmpty);
      expect(model1.fitnessId, isNot(model2.fitnessId)); // Different UUIDs
    });

    test('FitnessHiveModel allows optional fields to be null', () {
      // Arrange
      const title = 'Basic Fitness';

      // Act
      final model = FitnessHiveModel(
        title: title,
      );

      // Assert
      expect(model.title, title);
      expect(model.description, isNull);
      expect(model.category, isNull);
      expect(model.media, isNull);
      expect(model.mediaType, isNull);
      expect(model.createdBy, isNull);
      expect(model.createdByName, isNull);
      expect(model.duration, isNull);
    });

    test('FitnessHiveModel.toEntity() converts model to entity correctly', () {
      // Arrange
      final model = FitnessHiveModel(
        fitnessId: 'fit_2',
        title: 'Strength Training',
        description: 'Full body strength workout',
        category: 'strength',
        media: 'https://example.com/strength.mp4',
        mediaType: 'video',
        createdBy: 'admin_1',
        createdByName: 'Admin User',
        duration: 60,
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity, isA<FitnessEntity>());
      expect(entity.fitnessId, 'fit_2');
      expect(entity.title, 'Strength Training');
      expect(entity.description, 'Full body strength workout');
      expect(entity.category, 'strength');
      expect(entity.media, 'https://example.com/strength.mp4');
      expect(entity.mediaType, 'video');
      expect(entity.createdBy, 'admin_1');
      expect(entity.createdByName, 'Admin User');
      expect(entity.duration, 60);
    });

    test('FitnessHiveModel.fromEntity() creates model from entity correctly', () {
      // Arrange
      final entity = FitnessEntity(
        fitnessId: 'fit_3',
        title: 'Yoga Flow',
        description: 'Relaxing yoga',
        category: 'yoga',
        media: 'https://example.com/yoga.mp4',
        mediaType: 'video',
        createdBy: 'admin_2',
        createdByName: 'Yoga Expert',
        duration: 45,
      );

      // Act
      final model = FitnessHiveModel.fromEntity(entity);

      // Assert
      expect(model, isA<FitnessHiveModel>());
      expect(model.fitnessId, 'fit_3');
      expect(model.title, 'Yoga Flow');
      expect(model.description, 'Relaxing yoga');
      expect(model.category, 'yoga');
      expect(model.media, 'https://example.com/yoga.mp4');
      expect(model.mediaType, 'video');
      expect(model.createdBy, 'admin_2');
      expect(model.createdByName, 'Yoga Expert');
      expect(model.duration, 45);
    });

    test('FitnessHiveModel.toEntity().toEntity() is reversible', () {
      // Arrange
      final originalEntity = FitnessEntity(
        fitnessId: 'fit_4',
        title: 'Cardio Blast',
        description: 'High intensity cardio',
        category: 'cardio',
        media: 'https://example.com/cardio.mp4',
        mediaType: 'video',
        createdBy: 'admin_3',
        createdByName: 'Cardio Coach',
        duration: 30,
      );

      // Act
      final model = FitnessHiveModel.fromEntity(originalEntity);
      final convertedEntity = model.toEntity();

      // Assert - All fields should match
      expect(convertedEntity.fitnessId, originalEntity.fitnessId);
      expect(convertedEntity.title, originalEntity.title);
      expect(convertedEntity.description, originalEntity.description);
      expect(convertedEntity.category, originalEntity.category);
      expect(convertedEntity.media, originalEntity.media);
      expect(convertedEntity.mediaType, originalEntity.mediaType);
      expect(convertedEntity.createdBy, originalEntity.createdBy);
      expect(convertedEntity.createdByName, originalEntity.createdByName);
      expect(convertedEntity.duration, originalEntity.duration);
    });

    test('FitnessHiveModel.toEntityList() converts multiple models to entities', () {
      // Arrange
      final models = [
        FitnessHiveModel(
          fitnessId: 'fit_5',
          title: 'Yoga 1',
          category: 'yoga',
        ),
        FitnessHiveModel(
          fitnessId: 'fit_6',
          title: 'Cardio 1',
          category: 'cardio',
        ),
        FitnessHiveModel(
          fitnessId: 'fit_7',
          title: 'Strength 1',
          category: 'strength',
        ),
      ];

      // Act
      final entities = FitnessHiveModel.toEntityList(models);

      // Assert
      expect(entities.length, 3);
      expect(entities[0].title, 'Yoga 1');
      expect(entities[1].title, 'Cardio 1');
      expect(entities[2].title, 'Strength 1');
      expect(entities.every((e) => e is FitnessEntity), true);
    });

    test('FitnessHiveModel.toEntityList() with empty list returns empty list', () {
      // Arrange
      final models = <FitnessHiveModel>[];

      // Act
      final entities = FitnessHiveModel.toEntityList(models);

      // Assert
      expect(entities.length, 0);
      expect(entities, isEmpty);
    });

    test('FitnessHiveModel with different categories', () {
      // Arrange
      const categories = ['yoga', 'cardio', 'strength', 'stretching', 'pilates'];
      final models = categories
          .map((cat) => FitnessHiveModel(
                title: 'Test $cat',
                category: cat,
              ))
          .toList();

      // Act
      final entities = FitnessHiveModel.toEntityList(models);

      // Assert
      expect(entities.length, 5);
      for (int i = 0; i < categories.length; i++) {
        expect(entities[i].category, categories[i]);
      }
    });

    test('FitnessHiveModel with image media type', () {
      // Arrange
      final model = FitnessHiveModel(
        title: 'Fitness Image',
        media: 'https://example.com/image.jpg',
        mediaType: 'image',
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.mediaType, 'image');
      expect(entity.media, 'https://example.com/image.jpg');
    });

    test('FitnessHiveModel with video media type', () {
      // Arrange
      final model = FitnessHiveModel(
        title: 'Fitness Video',
        media: 'https://example.com/video.mp4',
        mediaType: 'video',
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.mediaType, 'video');
      expect(entity.media, 'https://example.com/video.mp4');
    });

    test('FitnessHiveModel with various durations', () {
      // Arrange
      final durations = [15, 30, 45, 60, 90, 120];
      final models = durations
          .map((dur) => FitnessHiveModel(
                title: 'Workout $dur min',
                duration: dur,
              ))
          .toList();

      // Act
      final entities = FitnessHiveModel.toEntityList(models);

      // Assert
      expect(entities.length, 6);
      for (int i = 0; i < durations.length; i++) {
        expect(entities[i].duration, durations[i]);
      }
    });

    test('FitnessHiveModel preserves all fields when converted to entity and back', () {
      // Arrange
      const fitnessId = 'fit_8';
      const title = 'Complex Fitness';
      const description = 'A complex fitness workout';
      const category = 'strength';
      const media = 'https://example.com/complex.mp4';
      const mediaType = 'video';
      const createdBy = 'admin_4';
      const createdByName = 'Advanced Trainer';
      const duration = 75;

      final originalModel = FitnessHiveModel(
        fitnessId: fitnessId,
        title: title,
        description: description,
        category: category,
        media: media,
        mediaType: mediaType,
        createdBy: createdBy,
        createdByName: createdByName,
        duration: duration,
      );

      // Act
      final entity = originalModel.toEntity();
      final modelFromEntity = FitnessHiveModel.fromEntity(entity);

      // Assert
      expect(modelFromEntity.fitnessId, fitnessId);
      expect(modelFromEntity.title, title);
      expect(modelFromEntity.description, description);
      expect(modelFromEntity.category, category);
      expect(modelFromEntity.media, media);
      expect(modelFromEntity.mediaType, mediaType);
      expect(modelFromEntity.createdBy, createdBy);
      expect(modelFromEntity.createdByName, createdByName);
      expect(modelFromEntity.duration, duration);
    });

    test('FitnessHiveModel with special characters in title and description', () {
      // Arrange
      const title = 'Yoga & Pilates: Advanced Level';
      const description = 'Test with @#\$%^&*() - Special chars!';

      final model = FitnessHiveModel(
        title: title,
        description: description,
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.title, title);
      expect(entity.description, description);
    });

    test('FitnessHiveModel with createdByName containing special characters', () {
      // Arrange
      const createdByName = "O'Brien-Smith's";

      final model = FitnessHiveModel(
        title: 'Fitness',
        createdByName: createdByName,
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.createdByName, createdByName);
    });
  });
}