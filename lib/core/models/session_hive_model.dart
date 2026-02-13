import 'package:hive/hive.dart';
import 'package:nutrisphere_flutter/core/constants/hive_table_constants.dart';
import 'package:nutrisphere_flutter/core/providers/session_provider.dart';

part 'session_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.sessionTypeId)
class SessionHiveModel extends HiveObject {
  @HiveField(0)
  final String day;

  @HiveField(1)
  final String sessionName;

  @HiveField(2)
  final String timeRange;

  @HiveField(3)
  final String location;

  @HiveField(4)
  final String workoutTitle;

  @HiveField(5)
  final List<String> exercises;

  @HiveField(6)
  final bool isActive;

  SessionHiveModel({
    required this.day,
    required this.sessionName,
    required this.timeRange,
    required this.location,
    required this.workoutTitle,
    required this.exercises,
    this.isActive = true,
  });

  // ===================== MAPPERS =====================

  /// Session → Hive
  factory SessionHiveModel.fromSession(Session session) {
    return SessionHiveModel(
      day: session.day,
      sessionName: session.sessionName,
      timeRange: session.timeRange,
      location: session.location,
      workoutTitle: session.workoutTitle,
      exercises: session.exercises,
      isActive: session.isActive,
    );
  }

  /// Hive → Session
  Session toSession() {
    return Session(
      day: day,
      sessionName: sessionName,
      timeRange: timeRange,
      location: location,
      workoutTitle: workoutTitle,
      exercises: exercises,
      isActive: isActive,
    );
  }
}