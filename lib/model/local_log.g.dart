// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalLogAdapter extends TypeAdapter<LocalLog> {
  @override
  final int typeId = 3;

  @override
  LocalLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalLog(
      createdAt: fields[0] as DateTime,
      jangdanType: fields[1] as JangdanType,
      playedTime: fields[2] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, LocalLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.createdAt)
      ..writeByte(1)
      ..write(obj.jangdanType)
      ..writeByte(2)
      ..write(obj.playedTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
