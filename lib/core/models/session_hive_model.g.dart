// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionHiveModelAdapter extends TypeAdapter<SessionHiveModel> {
  @override
  final int typeId = 4;

  @override
  SessionHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionHiveModel(
      day: fields[0] as String,
      sessionName: fields[1] as String,
      timeRange: fields[2] as String,
      location: fields[3] as String,
      workoutTitle: fields[4] as String,
      exercises: (fields[5] as List).cast<String>(),
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SessionHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.sessionName)
      ..writeByte(2)
      ..write(obj.timeRange)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.workoutTitle)
      ..writeByte(5)
      ..write(obj.exercises)
      ..writeByte(6)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
