import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nutrisphere_flutter/core/services/hive/hive_service.dart';
import 'package:nutrisphere_flutter/core/constants/hive_table_constants.dart';
import 'package:nutrisphere_flutter/features/auth/data/models/auth_hive_model.dart';
import 'package:nutrisphere_flutter/features/fitness/data/models/fitness_hive_model.dart';
import 'dart:io';

void main() {
  late HiveService hiveService;
  late String testPath;

  // setUp: Run before each test
  setUp(() async {
    // Create a temporary directory for testing
    testPath = Directory.systemTemp.createTempSync().path;
    hiveService = HiveService();
    
    // Initialize Hive with test path (not production path)
    Hive.init(testPath);
    
    // Register adapters
    if (!Hive.isAdapterRegistered(HiveTableConstants.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstants.fitnessTypeId)) {
      Hive.registerAdapter(FitnessHiveModelAdapter());
    }
    
    // Open boxes
    await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);
    await Hive.openBox<FitnessHiveModel>(HiveTableConstants.fitnessTable);
  });

  // tearDown: Run after each test
  tearDown(() async {
    await Hive.close();
    // Delete temporary test directory
    Directory(testPath).deleteSync(recursive: true);
  });

  group('HiveService - Auth Operations', () {
    test('registerUser should save user and return the user object', () async {
      // Arrange
      final user = AuthHiveModel(
        authId: 'auth_1',
        fullName: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
      );

      // Act
      final result = await hiveService.registerUser(user);

      // Assert
      expect(result.email, 'john@example.com');
      expect(result.fullName, 'John Doe');
      expect(result.password, 'password123');
    });

    test('login should return user when email and password are correct', () async {
      // Arrange
      final user = AuthHiveModel(
        authId: 'auth_2',
        fullName: 'Jane Smith',
        email: 'jane@example.com',
        password: 'correctpassword',
      );
      await hiveService.registerUser(user);

      // Act
      final result = hiveService.login('jane@example.com', 'correctpassword');

      // Assert
      expect(result, isNotNull);
      expect(result?.email, 'jane@example.com');
      expect(result?.fullName, 'Jane Smith');
    });

    test('login should return null when email does not exist', () async {
      // Act
      final result = hiveService.login('nonexistent@example.com', 'anypassword');

      // Assert
      expect(result, isNull);
    });

    test('login should return null when password is incorrect', () async {
      // Arrange
      final user = AuthHiveModel(
        authId: 'auth_3',
        fullName: 'Bob Johnson',
        email: 'bob@example.com',
        password: 'correctpassword',
      );
      await hiveService.registerUser(user);

      // Act
      final result = hiveService.login('bob@example.com', 'wrongpassword');

      // Assert
      expect(result, isNull);
    });

    test('getUser should return user by email', () async {
      // Arrange
      final user = AuthHiveModel(
        authId: 'auth_4',
        fullName: 'Alice Cooper',
        email: 'alice@example.com',
        password: 'alicepass',
      );
      await hiveService.registerUser(user);

      // Act
      final result = hiveService.getUser('alice@example.com');

      // Assert
      expect(result, isNotNull);
      expect(result?.email, 'alice@example.com');
      expect(result?.fullName, 'Alice Cooper');
    });

    test('getUser should return null when email does not exist', () async {
      // Act
      final result = hiveService.getUser('notfound@example.com');

      // Assert
      expect(result, isNull);
    });

    test('updateUser should update existing user', () async {
      // Arrange
      final user = AuthHiveModel(
        authId: 'auth_5',
        fullName: 'Charlie Brown',
        email: 'charlie@example.com',
        password: 'charlieinitial',
      );
      await hiveService.registerUser(user);

      final updatedUser = AuthHiveModel(
        authId: 'auth_5',
        fullName: 'Charlie Brown Updated',
        email: 'charlie@example.com',
        password: 'charlieupdate',
      );

      // Act
      final result = await hiveService.updateUser(updatedUser);

      // Assert
      expect(result, true);
      final fetched = hiveService.getUser('charlie@example.com');
      expect(fetched?.fullName, 'Charlie Brown Updated');
      expect(fetched?.password, 'charlieupdate');
    });

    test('updateUser should return false when user does not exist', () async {
      // Arrange
      final user = AuthHiveModel(
        authId: 'auth_999',
        fullName: 'Nonexistent',
        email: 'nonexistent@example.com',
        password: 'pass',
      );

      // Act
      final result = await hiveService.updateUser(user);

      // Assert
      expect(result, false);
    });

    test('deleteUser should remove user by email', () async {
      // Arrange
      final user = AuthHiveModel(
        authId: 'auth_6',
        fullName: 'David Lee',
        email: 'david@example.com',
        password: 'davidpass',
      );
      await hiveService.registerUser(user);

      // Act
      await hiveService.deleteUser('david@example.com');

      // Assert
      final fetched = hiveService.getUser('david@example.com');
      expect(fetched, isNull);
    });

    test('isEmailExists should return true when email exists', () async {
      // Arrange
      final user = AuthHiveModel(
        authId: 'auth_7',
        fullName: 'Eve Wilson',
        email: 'eve@example.com',
        password: 'evepass',
      );
      await hiveService.registerUser(user);

      // Act
      final result = hiveService.isEmailExists('eve@example.com');

      // Assert
      expect(result, true);
    });

    test('isEmailExists should return false when email does not exist', () async {
      // Act
      final result = hiveService.isEmailExists('nothere@example.com');

      // Assert
      expect(result, false);
    });
  });

  group('HiveService - Fitness Operations', () {
    test('createFitness should save fitness and return the fitness object', () async {
      // Arrange
      final fitness = FitnessHiveModel(
        fitnessId: 'fit_1',
        title: 'Morning Yoga',
        description: '30 minute yoga session',
        category: 'yoga',
        media: 'https://example.com/yoga.mp4',
        mediaType: 'video',
        createdBy: 'admin_1',
        createdByName: 'Admin User',
        duration: 30,
      );

      // Act
      final result = await hiveService.createFitness(fitness);

      // Assert
      expect(result.title, 'Morning Yoga');
      expect(result.category, 'yoga');
      expect(result.duration, 30);
    });

    test('getAllFitness should return all fitness items', () async {
      // Arrange
      final fitness1 = FitnessHiveModel(
        fitnessId: 'fit_2',
        title: 'Cardio Workout',
        category: 'cardio',
        createdBy: 'admin_1',
        duration: 45,
      );
      final fitness2 = FitnessHiveModel(
        fitnessId: 'fit_3',
        title: 'Strength Training',
        category: 'strength',
        createdBy: 'admin_2',
        duration: 60,
      );
      await hiveService.createFitness(fitness1);
      await hiveService.createFitness(fitness2);

      // Act
      final result = hiveService.getAllFitness();

      // Assert
      expect(result.length, 2);
      expect(result.any((f) => f.title == 'Cardio Workout'), true);
      expect(result.any((f) => f.title == 'Strength Training'), true);
    });

    test('getFitnessById should return fitness by ID', () async {
      // Arrange
      final fitness = FitnessHiveModel(
        fitnessId: 'fit_4',
        title: 'Stretching Session',
        category: 'stretching',
        createdBy: 'admin_1',
        duration: 20,
      );
      await hiveService.createFitness(fitness);

      // Act
      final result = hiveService.getFitnessById('fit_4');

      // Assert
      expect(result, isNotNull);
      expect(result?.title, 'Stretching Session');
    });

    test('getFitnessById should return null when ID does not exist', () async {
      // Act
      final result = hiveService.getFitnessById('nonexistent_id');

      // Assert
      expect(result, isNull);
    });

    test('getFitnessByUser should return fitness items created by specific user', () async {
      // Arrange
      final fitness1 = FitnessHiveModel(
        fitnessId: 'fit_5',
        title: 'Yoga by Admin A',
        category: 'yoga',
        createdBy: 'admin_A',
        duration: 30,
      );
      final fitness2 = FitnessHiveModel(
        fitnessId: 'fit_6',
        title: 'Cardio by Admin B',
        category: 'cardio',
        createdBy: 'admin_B',
        duration: 45,
      );
      final fitness3 = FitnessHiveModel(
        fitnessId: 'fit_7',
        title: 'Another Yoga by Admin A',
        category: 'yoga',
        createdBy: 'admin_A',
        duration: 25,
      );
      await hiveService.createFitness(fitness1);
      await hiveService.createFitness(fitness2);
      await hiveService.createFitness(fitness3);

      // Act
      final result = hiveService.getFitnessByUser('admin_A');

      // Assert
      expect(result.length, 2);
      expect(result.every((f) => f.createdBy == 'admin_A'), true);
    });

    test('getFitnessByCategory should return fitness items by category', () async {
      // Arrange
      final fitness1 = FitnessHiveModel(
        fitnessId: 'fit_8',
        title: 'Yoga 1',
        category: 'yoga',
        createdBy: 'admin_1',
        duration: 30,
      );
      final fitness2 = FitnessHiveModel(
        fitnessId: 'fit_9',
        title: 'Cardio 1',
        category: 'cardio',
        createdBy: 'admin_1',
        duration: 45,
      );
      final fitness3 = FitnessHiveModel(
        fitnessId: 'fit_10',
        title: 'Yoga 2',
        category: 'yoga',
        createdBy: 'admin_1',
        duration: 35,
      );
      await hiveService.createFitness(fitness1);
      await hiveService.createFitness(fitness2);
      await hiveService.createFitness(fitness3);

      // Act
      final result = hiveService.getFitnessByCategory('yoga');

      // Assert
      expect(result.length, 2);
      expect(result.every((f) => f.category == 'yoga'), true);
    });

    test('updateFitness should update existing fitness item', () async {
      // Arrange
      final fitness = FitnessHiveModel(
        fitnessId: 'fit_11',
        title: 'Initial Title',
        category: 'yoga',
        createdBy: 'admin_1',
        duration: 30,
      );
      await hiveService.createFitness(fitness);

      final updatedFitness = FitnessHiveModel(
        fitnessId: 'fit_11',
        title: 'Updated Title',
        category: 'yoga',
        createdBy: 'admin_1',
        duration: 45,
      );

      // Act
      final result = await hiveService.updateFitness(updatedFitness);

      // Assert
      expect(result, true);
      final fetched = hiveService.getFitnessById('fit_11');
      expect(fetched?.title, 'Updated Title');
      expect(fetched?.duration, 45);
    });

    test('updateFitness should return false when fitness does not exist', () async {
      // Arrange
      final fitness = FitnessHiveModel(
        fitnessId: 'fit_999',
        title: 'Nonexistent',
        category: 'yoga',
        createdBy: 'admin_1',
        duration: 30,
      );

      // Act
      final result = await hiveService.updateFitness(fitness);

      // Assert
      expect(result, false);
    });

    test('deleteFitness should remove fitness by ID', () async {
      // Arrange
      final fitness = FitnessHiveModel(
        fitnessId: 'fit_12',
        title: 'To Be Deleted',
        category: 'yoga',
        createdBy: 'admin_1',
        duration: 30,
      );
      await hiveService.createFitness(fitness);

      // Act
      await hiveService.deleteFitness('fit_12');

      // Assert
      final fetched = hiveService.getFitnessById('fit_12');
      expect(fetched, isNull);
    });
  });
}