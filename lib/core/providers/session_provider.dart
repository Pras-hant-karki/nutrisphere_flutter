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

    Future.microtask(refreshFromServer);
    return cached;
  }

  Future<void> refreshFromServer() async {
    try {
      final api = ref.read(apiClientProvider);
      final cachedBeforeSync = List<Session>.from(state);
      var usedAdminEndpoint = true;

      // Admin app flow first; if unauthorized, fallback to user active sessions endpoint.
      Response response;
      try {
        response = await api.get(ApiEndpoints.adminSessions);
      } on DioException catch (e) {
        if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
          usedAdminEndpoint = false;
          response = await api.get(ApiEndpoints.sessions);
        } else {
          rethrow;
        }
      }

      var serverSessions = _parseSessionsFromResponse(response.data);

      // One-time migration path: if admin has local cached sessions but backend is empty,
      // push local sessions to backend so web + mobile immediately share the same source.
      if (usedAdminEndpoint && serverSessions.isEmpty && cachedBeforeSync.isNotEmpty) {
        for (final session in cachedBeforeSync) {
          await api.post(ApiEndpoints.adminSessions, data: session.toJson());
        }
        final refreshed = await api.get(ApiEndpoints.adminSessions);
        serverSessions = _parseSessionsFromResponse(refreshed.data);
      }

      state = serverSessions;
      await _saveToHive();
      print('[SessionNotifier] Synced ${state.length} sessions from backend');
    } catch (e) {
      print('[SessionNotifier] Backend sync failed: $e');
    }
  }

  Future<void> addSession(Session session) async {
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.post(ApiEndpoints.adminSessions, data: session.toJson());
      final data = response.data as Map<String, dynamic>;
      final created = Session.fromJson(data['data'] as Map<String, dynamic>);
      state = [...state, created];
      await _saveToHive();
    } catch (e) {
      print('[SessionNotifier] Error adding session: $e');
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
      final response = await api.put(
        ApiEndpoints.adminSessionById(existing.id!),
        data: session.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      final updated = Session.fromJson(data['data'] as Map<String, dynamic>);
      final newState = List<Session>.from(state);
      newState[index] = updated;
      state = newState;
      await _saveToHive();
    } catch (e) {
      print('[SessionNotifier] Error updating session: $e');
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
      final newState = List<Session>.from(state)..removeAt(index);
      state = newState;
      await _saveToHive();
    } catch (e) {
      print('[SessionNotifier] Error deleting session: $e');
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
      final response = await api.patch(ApiEndpoints.toggleAdminSession(existing.id!));
      final data = response.data as Map<String, dynamic>;
      final updated = Session.fromJson(data['data'] as Map<String, dynamic>);
      final newState = List<Session>.from(state);
      newState[index] = updated;
      state = newState;
      await _saveToHive();
    } catch (e) {
      print('[SessionNotifier] Error toggling session: $e');
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
