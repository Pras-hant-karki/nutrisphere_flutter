import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/models/session_hive_model.dart';
import 'package:nutrisphere_flutter/core/services/hive/hive_service.dart';

class Session {
  String day;
  String sessionName;
  String timeRange;
  String location;
  String workoutTitle;
  List<String> exercises;
  bool isActive;

  Session({
    required this.day,
    required this.sessionName,
    required this.timeRange,
    required this.location,
    required this.workoutTitle,
    required this.exercises,
    this.isActive = true,
  });

  Session copyWith({
    String? day,
    String? sessionName,
    String? timeRange,
    String? location,
    String? workoutTitle,
    List<String>? exercises,
    bool? isActive,
  }) {
    return Session(
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
      day: json['day'],
      sessionName: json['sessionName'],
      timeRange: json['timeRange'],
      location: json['location'],
      workoutTitle: json['workoutTitle'],
      exercises: List<String>.from(json['exercises']),
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
  @override
  List<Session> build() {
    // Load sessions from Hive on initialization
    try {
      final hiveService = ref.read(hiveServiceProvider);
      final hiveSessions = hiveService.getAllSessions();
      print('[SessionNotifier] Loaded ${hiveSessions.length} sessions from Hive');
      return hiveSessions.map((s) => s.toSession()).toList();
    } catch (e) {
      print('[SessionNotifier] Error loading sessions from Hive: $e');
      return [];
    }
  }

  Future<void> addSession(Session session) async {
    state = [...state, session];
    await _saveToHive();
  }

  Future<void> updateSession(int index, Session session) async {
    final newState = List<Session>.from(state);
    newState[index] = session;
    state = newState;
    await _saveToHive();
  }

  Future<void> deleteSession(int index) async {
    final newState = List<Session>.from(state);
    newState.removeAt(index);
    state = newState;
    await _saveToHive();
  }

  Future<void> toggleSession(int index) async {
    final newState = List<Session>.from(state);
    newState[index] = newState[index].copyWith(isActive: !newState[index].isActive);
    state = newState;
    await _saveToHive();
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

final sessionProvider =
    NotifierProvider<SessionNotifier, List<Session>>(() {
  return SessionNotifier();
});