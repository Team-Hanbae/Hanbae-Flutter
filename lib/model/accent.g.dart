// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accent.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccentAdapter extends TypeAdapter<Accent> {
  @override
  final int typeId = 1;

  @override
  Accent read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Accent.weak;
      case 1:
        return Accent.medium;
      case 2:
        return Accent.strong;
      case 3:
        return Accent.none;
      default:
        return Accent.weak;
    }
  }

  @override
  void write(BinaryWriter writer, Accent obj) {
    switch (obj) {
      case Accent.weak:
        writer.writeByte(0);
        break;
      case Accent.medium:
        writer.writeByte(1);
        break;
      case Accent.strong:
        writer.writeByte(2);
        break;
      case Accent.none:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
