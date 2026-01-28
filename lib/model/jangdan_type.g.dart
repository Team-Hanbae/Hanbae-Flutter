// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jangdan_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JangdanTypeAdapter extends TypeAdapter<JangdanType> {
  @override
  final int typeId = 2;

  @override
  JangdanType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return JangdanType.jinyang;
      case 1:
        return JangdanType.jungmori;
      case 2:
        return JangdanType.jungjungmori;
      case 3:
        return JangdanType.jajinmori;
      case 4:
        return JangdanType.gutgeori;
      case 5:
        return JangdanType.hwimori;
      case 6:
        return JangdanType.dongsalpuri;
      case 7:
        return JangdanType.eonmori;
      case 8:
        return JangdanType.eotjungmori;
      case 9:
        return JangdanType.semachi;
      case 10:
        return JangdanType.ginyeombul;
      case 11:
        return JangdanType.banyeombul;
      case 12:
        return JangdanType.jwajilgut;
      case 13:
        return JangdanType.sangnyeongsan;
      case 14:
        return JangdanType.seryeongsan;
      case 15:
        return JangdanType.taryeong;
      case 16:
        return JangdanType.chwita;
      case 17:
        return JangdanType.jeolhwa;
      case 18:
        return JangdanType.dodeuri;
      case 19:
        return JangdanType.noraetgarak;
      default:
        return JangdanType.jinyang;
    }
  }

  @override
  void write(BinaryWriter writer, JangdanType obj) {
    switch (obj) {
      case JangdanType.jinyang:
        writer.writeByte(0);
        break;
      case JangdanType.jungmori:
        writer.writeByte(1);
        break;
      case JangdanType.jungjungmori:
        writer.writeByte(2);
        break;
      case JangdanType.jajinmori:
        writer.writeByte(3);
        break;
      case JangdanType.gutgeori:
        writer.writeByte(4);
        break;
      case JangdanType.hwimori:
        writer.writeByte(5);
        break;
      case JangdanType.dongsalpuri:
        writer.writeByte(6);
        break;
      case JangdanType.eonmori:
        writer.writeByte(7);
        break;
      case JangdanType.eotjungmori:
        writer.writeByte(8);
        break;
      case JangdanType.semachi:
        writer.writeByte(9);
        break;
      case JangdanType.ginyeombul:
        writer.writeByte(10);
        break;
      case JangdanType.banyeombul:
        writer.writeByte(11);
        break;
      case JangdanType.jwajilgut:
        writer.writeByte(12);
        break;
      case JangdanType.sangnyeongsan:
        writer.writeByte(13);
        break;
      case JangdanType.seryeongsan:
        writer.writeByte(14);
        break;
      case JangdanType.taryeong:
        writer.writeByte(15);
        break;
      case JangdanType.chwita:
        writer.writeByte(16);
        break;
      case JangdanType.jeolhwa:
        writer.writeByte(17);
        break;
      case JangdanType.dodeuri:
        writer.writeByte(18);
        break;
      case JangdanType.noraetgarak:
        writer.writeByte(19);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JangdanTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
