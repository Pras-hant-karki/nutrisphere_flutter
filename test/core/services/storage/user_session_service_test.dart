import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrisphere_flutter/core/services/storage/user_session_service.dart';

void main() {
  late UserSessionService userSessionService;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    userSessionService = UserSessionService(prefs: sharedPreferences);
  });

  tearDown(() async {
    // Clear all preferences after each test
    await sharedPreferences.clear();
  });

  group('UserSessionService - Session Management', () {
    test('saveSession should save all session data correctly', () async {
      // Arrange
      const userId = 'user_123';
      const email = 'test@example.com';
      const fullName = 'John Doe';

      // Act
      await userSessionService.saveSession(
        userId: userId,
        email: email,
        fullName: fullName,
      );

      // Assert
      expect(sharedPreferences.getBool('is_logged_in'), true);
      expect(sharedPreferences.getString('user_id'), userId);
      expect(sharedPreferences.getString('email'), email);
      expect(sharedPreferences.getString('full_name'), fullName);
    });

    test('saveUserSession should save session using authId parameter', () async {
      // Arrange
      const authId = 'auth_456';
      const email = 'jane@example.com';
      const fullName = 'Jane Smith';

      // Act
      await userSessionService.saveUserSession(
        authId: authId,
        email: email,
        fullName: fullName,
      );

      // Assert
      expect(sharedPreferences.getBool('is_logged_in'), true);
      expect(sharedPreferences.getString('user_id'), authId);
      expect(sharedPreferences.getString('email'), email);
      expect(sharedPreferences.getString('full_name'), fullName);
    });

    test('getSession should return UserSession object when user is logged in', () async {
      // Arrange
      const userId = 'user_789';
      const email = 'bob@example.com';
      const fullName = 'Bob Johnson';

      await userSessionService.saveSession(
        userId: userId,
        email: email,
        fullName: fullName,
      );

      // Act
      final session = await userSessionService.getSession();

      // Assert
      expect(session, isNotNull);
      expect(session?.userId, userId);
      expect(session?.email, email);
      expect(session?.fullName, fullName);
    });

    test('getSession should return null when user is not logged in', () async {
      // Act
      final session = await userSessionService.getSession();

      // Assert
      expect(session, isNull);
    });

    test('getSession should return null when logged in flag is true but data is missing', 
        () async {
      // Arrange - Set only the logged in flag without setting other data
      await sharedPreferences.setBool('is_logged_in', true);

      // Act
      final session = await userSessionService.getSession();

      // Assert
      expect(session, isNull);
    });

    test('getSession should return null when partial data is missing', () async {
      // Arrange - Set logged in flag and only userId
      await sharedPreferences.setBool('is_logged_in', true);
      await sharedPreferences.setString('user_id', 'user_123');
      // Note: email and fullName are NOT set

      // Act
      final session = await userSessionService.getSession();

      // Assert
      expect(session, isNull);
    });

    test('logout should remove all session data', () async {
      // Arrange
      const userId = 'user_101';
      const email = 'alice@example.com';
      const fullName = 'Alice Cooper';

      await userSessionService.saveSession(
        userId: userId,
        email: email,
        fullName: fullName,
      );

      // Verify data is saved
      var session = await userSessionService.getSession();
      expect(session, isNotNull);

      // Act
      await userSessionService.logout();

      // Assert
      expect(sharedPreferences.containsKey('is_logged_in'), false);
      expect(sharedPreferences.containsKey('user_id'), false);
      expect(sharedPreferences.containsKey('email'), false);
      expect(sharedPreferences.containsKey('full_name'), false);

      // Verify getSession returns null after logout
      session = await userSessionService.getSession();
      expect(session, isNull);
    });

    test('isLoggedIn should return true when user is logged in', () async {
      // Arrange
      const userId = 'user_202';
      const email = 'charlie@example.com';
      const fullName = 'Charlie Brown';

      await userSessionService.saveSession(
        userId: userId,
        email: email,
        fullName: fullName,
      );

      // Act
      final loggedIn = userSessionService.isLoggedIn();

      // Assert
      expect(loggedIn, true);
    });

    test('isLoggedIn should return false when user is not logged in', () async {
      // Act
      final loggedIn = userSessionService.isLoggedIn();

      // Assert
      expect(loggedIn, false);
    });

    test('isLoggedIn should return false after logout', () async {
      // Arrange
      const userId = 'user_303';
      const email = 'diana@example.com';
      const fullName = 'Diana Prince';

      await userSessionService.saveSession(
        userId: userId,
        email: email,
        fullName: fullName,
      );

      // Verify user is logged in
      expect(userSessionService.isLoggedIn(), true);

      // Act
      await userSessionService.logout();

      // Assert
      expect(userSessionService.isLoggedIn(), false);
    });

    test('UserSession should have correct properties', () {
      // Arrange
      const userId = 'user_404';
      const email = 'edward@example.com';
      const fullName = 'Edward Norton';

      // Act
      final session = UserSession(
        userId: userId,
        email: email,
        fullName: fullName,
      );

      // Assert
      expect(session.userId, userId);
      expect(session.email, email);
      expect(session.fullName, fullName);
    });

    test('saveSession multiple times should update existing session', () async {
      // Arrange & Act - First save
      await userSessionService.saveSession(
        userId: 'user_1',
        email: 'first@example.com',
        fullName: 'First User',
      );

      var session = await userSessionService.getSession();
      expect(session?.userId, 'user_1');
      expect(session?.email, 'first@example.com');

      // Act - Second save with different data
      await userSessionService.saveSession(
        userId: 'user_2',
        email: 'second@example.com',
        fullName: 'Second User',
      );

      // Assert
      session = await userSessionService.getSession();
      expect(session?.userId, 'user_2');
      expect(session?.email, 'second@example.com');
      expect(session?.fullName, 'Second User');
    });

    test('saveSession with special characters in email should work correctly', () async {
      // Arrange
      const userId = 'user_505';
      const email = 'user+tag@sub.domain.example.com';
      const fullName = 'Frank Miller';

      // Act
      await userSessionService.saveSession(
        userId: userId,
        email: email,
        fullName: fullName,
      );

      // Assert
      final session = await userSessionService.getSession();
      expect(session?.email, email);
    });

    test('saveSession with special characters in fullName should work correctly', 
        () async {
      // Arrange
      const userId = 'user_606';
      const email = 'grace@example.com';
      const fullName = 'Grâce O\'Neill-Smith';

      // Act
      await userSessionService.saveSession(
        userId: userId,
        email: email,
        fullName: fullName,
      );

      // Assert
      final session = await userSessionService.getSession();
      expect(session?.fullName, fullName);
    });

    test('getSession preserves exact data without modification', () async {
      // Arrange
      const userId = 'user_707';
      const email = '  spaces@example.com  '; // With spaces
      const fullName = '  User Name  '; // With spaces

      // Act
      await userSessionService.saveSession(
        userId: userId,
        email: email,
        fullName: fullName,
      );

      // Assert
      final session = await userSessionService.getSession();
      expect(session?.email, email);
      expect(session?.fullName, fullName);
    });

    test('multiple logout calls should not cause errors', () async {
      // Arrange
      await userSessionService.saveSession(
        userId: 'user_808',
        email: 'henry@example.com',
        fullName: 'Henry Ford',
      );

      // Act & Assert - Should not throw any errors
      await userSessionService.logout();
      await userSessionService.logout();
      await userSessionService.logout();

      expect(userSessionService.isLoggedIn(), false);
    });
  });
}