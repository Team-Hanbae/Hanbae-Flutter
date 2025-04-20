// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jangdan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JangdanAdapter extends TypeAdapter<Jangdan> {
  @override
  final int typeId = 0;

  @override
  Jangdan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Jangdan(
      name: fields[0] as String,
      createdAt: fields[2] as DateTime,
      bpm: fields[3] as int,
      jangdanType: fields[1] as JangdanType,
      accents: (fields[4] as List)
          .map((dynamic e) => (e as List)
              .map((dynamic e) => (e as List).cast<Accent>())
              .toList())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, Jangdan obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.jangdanType)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.bpm)
      ..writeByte(4)
      ..write(obj.accents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JangdanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
