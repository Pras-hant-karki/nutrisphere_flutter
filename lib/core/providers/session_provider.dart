import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/api/api_client.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/core/models/session_hive_model.dart';
import 'package:nutrisphere_flutter/core/services/hive/hive_service.dart';

class Session {
  String? id;
  String day;
  String sessionName;
  String timeRange;
  String location;
  String workoutTitle;
  List<String> exercises;
  bool isActive;

  Session({
    this.id,
    required this.day,
    required this.sessionName,
    required this.timeRange,
    required this.location,
    required this.workoutTitle,
    required this.exercises,
    this.isActive = true,
  });

  Session copyWith({
    String? id,
    String? day,
    String? sessionName,
    String? timeRange,
    String? location,
    String? workoutTitle,
    List<String>? exercises,
    bool? isActive,
  }) {
    return Session(
      id: id ?? this.id,
      day: day ?? this.day,
      sessionName: sessionName ?? this.sessionName,
      timeRange: timeRange ?? this.timeRange,
      location: location ?? this.location,
      workoutTitle: workoutTitle ?? this.workoutTitle,
      exercises: exercises ?? this.exercises,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'sessionName': sessionName,
      'timeRange': timeRange,
      'location': location,
      'workoutTitle': workoutTitle,
      'exercises': exercises,
      'isActive': isActive,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: (json['_id'] ?? json['id'])?.toString(),
      day: (json['day'] ?? '').toString(),
      sessionName: (json['sessionName'] ?? '').toString(),
      timeRange: (json['timeRange'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      workoutTitle: (json['workoutTitle'] ?? '').toString(),
      exercises: List<String>.from(json['exercises'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }
}

/// The fixed order for days of the week
const List<String> daysOfWeek = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

class SessionNotifier extends Notifier<List<Session>> {
  Timer? _syncTimer;
  bool _useAdminEndpoints = false;

  List<Session> _parseSessionsFromResponse(dynamic data) {
    final list =
        (data is Map<String, dynamic> ? data['data'] : null) as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(Session.fromJson)
        .toList();
  }

  @override
  List<Session> build() {
    // Start with cached sessions for instant UI, then sync with backend.
    List<Session> cached = [];
    try {
      final hiveService = ref.read(hiveServiceProvider);
      final hiveSessions = hiveService.getAllSessions();
      cached = hiveSessions.map((s) => s.toSession()).toList();
      print('[SessionNotifier] Loaded ${cached.length} cached sessions from Hive');
    } catch (e) {
      print('[SessionNotifier] Error loading sessions from Hive: $e');
    }

    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      refreshFromServer();
    });

    ref.onDispose(() {
      _syncTimer?.cancel();
      _syncTimer = null;
    });

    Future.microtask(refreshUserSessions);
    return cached;
  }

  Future<void> refreshUserSessions() async {
    _useAdminEndpoints = false;
    await refreshFromServer();
  }

  Future<void> refreshAdminSessions() async {
    _useAdminEndpoints = true;
    await refreshFromServer();
  }

  Future<void> refreshFromServer() async {
    try {
      final api = ref.read(apiClientProvider);
      final endpoint = _useAdminEndpoints
          ? ApiEndpoints.adminSessions
          : ApiEndpoints.sessions;

      final response = await api.get(endpoint);
      final serverSessions = _parseSessionsFromResponse(response.data);

      state = serverSessions;
      await _saveToHive();
      print('[SessionNotifier] Synced ${state.length} sessions from backend');
    } on DioException catch (e) {
      print('[SessionNotifier] Backend sync failed: ${e.response?.statusCode} ${e.message}');
    } catch (e) {
      print('[SessionNotifier] Backend sync failed: $e');
    }
  }

  Future<void> addSession(Session session) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.post(ApiEndpoints.adminSessions, data: session.toJson());
      await refreshAdminSessions();
    } catch (e) {
      print('[SessionNotifier] Error adding session: $e');
      rethrow;
    }
  }

  Future<void> updateSession(int index, Session session) async {
    if (index < 0 || index >= state.length) return;

    final existing = state[index];
    if (existing.id == null) {
      await refreshFromServer();
      return;
    }

    try {
      final api = ref.read(apiClientProvider);
      await api.put(
        ApiEndpoints.adminSessionById(existing.id!),
        data: session.toJson(),
      );
      await refreshAdminSessions();
    } catch (e) {
      print('[SessionNotifier] Error updating session: $e');
      rethrow;
    }
  }

  Future<void> deleteSession(int index) async {
    if (index < 0 || index >= state.length) return;
    final existing = state[index];
    if (existing.id == null) {
      await refreshFromServer();
      return;
    }

    try {
      final api = ref.read(apiClientProvider);
      await api.delete(ApiEndpoints.adminSessionById(existing.id!));
      await refreshAdminSessions();
    } catch (e) {
      print('[SessionNotifier] Error deleting session: $e');
      rethrow;
    }
  }

  Future<void> toggleSession(int index) async {
    if (index < 0 || index >= state.length) return;
    final existing = state[index];
    if (existing.id == null) {
      await refreshFromServer();
      return;
    }

    try {
      final api = ref.read(apiClientProvider);
      await api.patch(ApiEndpoints.toggleAdminSession(existing.id!));
      await refreshAdminSessions();
    } catch (e) {
      print('[SessionNotifier] Error toggling session: $e');
      rethrow;
    }
  }

  Future<void> _saveToHive() async {
    try {
      final hiveService = ref.read(hiveServiceProvider);
      final hiveSessions = state.map((s) => SessionHiveModel.fromSession(s)).toList();
      await hiveService.saveAllSessions(hiveSessions);
      print('[SessionNotifier] Saved ${hiveSessions.length} sessions to Hive');
    } catch (e) {
      print('[SessionNotifier] Error saving sessions to Hive: $e');
    }
  }

  /// Get all sessions grouped by day (for admin — shows all including inactive)
  Map<String, List<Session>> get sessionsByDay {
    final Map<String, List<Session>> grouped = {};
    for (final session in state) {
      grouped.putIfAbsent(session.day, () => []);
      grouped[session.day]!.add(session);
    }
    return grouped;
  }

  /// Get only active sessions grouped by day (for users)
  Map<String, List<Session>> get activeSessionsByDay {
    final Map<String, List<Session>> grouped = {};
    for (final session in state) {
      if (session.isActive) {
        grouped.putIfAbsent(session.day, () => []);
        grouped[session.day]!.add(session);
      }
    }
    return grouped;
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, List<Session>>(() {
  return SessionNotifier();
});
