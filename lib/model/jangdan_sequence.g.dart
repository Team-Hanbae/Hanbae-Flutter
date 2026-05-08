// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jangdan_sequence.dart';

class JangdanSequenceAdapter extends TypeAdapter<JangdanSequence> {
  @override
  final int typeId = 4;

  @override
  JangdanSequence read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JangdanSequence(
      name: fields[0] as String,
      createdAt: fields[1] as DateTime,
      items: (fields[2] as List).cast<JangdanSequenceItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, JangdanSequence obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JangdanSequenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class JangdanSequenceItemAdapter extends TypeAdapter<JangdanSequenceItem> {
  @override
  final int typeId = 5;

  @override
  JangdanSequenceItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JangdanSequenceItem(
      order: fields[0] as int,
      repeatCount: fields[1] as int,
      jangdan: fields[2] as Jangdan,
    );
  }

  @override
  void write(BinaryWriter writer, JangdanSequenceItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.order)
      ..writeByte(1)
      ..write(obj.repeatCount)
      ..writeByte(2)
      ..write(obj.jangdan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JangdanSequenceItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
