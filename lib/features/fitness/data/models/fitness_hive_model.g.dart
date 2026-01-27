// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitness_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FitnessHiveModelAdapter extends TypeAdapter<FitnessHiveModel> {
  @override
  final int typeId = 3;

  @override
  FitnessHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FitnessHiveModel(
      fitnessId: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String?,
      category: fields[3] as String,
      media: fields[4] as String?,
      mediaType: fields[5] as String?,
      createdBy: fields[6] as String?,
      createdByName: fields[7] as String?,
      difficulty: fields[8] as String?,
      duration: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, FitnessHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.fitnessId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.media)
      ..writeByte(5)
      ..write(obj.mediaType)
      ..writeByte(6)
      ..write(obj.createdBy)
      ..writeByte(7)
      ..write(obj.createdByName)
      ..writeByte(8)
      ..write(obj.difficulty)
      ..writeByte(9)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FitnessHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
