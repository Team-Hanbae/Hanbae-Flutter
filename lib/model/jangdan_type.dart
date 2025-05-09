import 'package:hive/hive.dart';

part 'jangdan_type.g.dart';

@HiveType(typeId: 2)
enum JangdanType {
  @HiveField(0)
  jinyang,
  @HiveField(1)
  jungmori,
  @HiveField(2)
  jungjungmori,
  @HiveField(3)
  jajinmori,
  @HiveField(4)
  gutgeori,
  @HiveField(5)
  hwimori,
  @HiveField(6)
  dongsalpuri,
  @HiveField(7)
  eonmori,
  @HiveField(8)
  eotjungmori,
  @HiveField(9)
  semachi,
  @HiveField(10)
  ginyeombul,
  @HiveField(11)
  banyeombul,
}

extension JangdanTypeExtension on JangdanType {
  String get label {
    switch (this) {
      case JangdanType.jinyang: return "진양";
      case JangdanType.jungmori: return "중모리";
      case JangdanType.jungjungmori: return "중중모리";
      case JangdanType.jajinmori: return "자진모리";
      case JangdanType.gutgeori: return "굿거리";
      case JangdanType.hwimori: return "휘모리";
      case JangdanType.dongsalpuri: return "동살풀이";
      case JangdanType.eonmori: return "엇모리";
      case JangdanType.eotjungmori: return "엇중모리";
      case JangdanType.semachi: return "세마치";
      case JangdanType.ginyeombul: return "긴염불";
      case JangdanType.banyeombul: return "반염불";
    }
  }

  String get logoAssetPath {
    switch (this) {
      case JangdanType.jinyang: return "images/logos/Jinyang.svg";
      case JangdanType.jungmori: return "images/logos/Jungmori.svg";
      case JangdanType.jungjungmori: return "images/logos/Jungjungmori.svg";
      case JangdanType.jajinmori: return "images/logos/Jajinmori.svg";
      case JangdanType.gutgeori: return "images/logos/Gutgeori.svg";
      case JangdanType.hwimori: return "images/logos/Hwimori.svg";
      case JangdanType.dongsalpuri: return "images/logos/Dongsalpuri.svg";
      case JangdanType.eonmori: return "images/logos/Eonmori.svg";
      case JangdanType.eotjungmori: return "images/logos/Eotjungmori.svg";
      case JangdanType.semachi: return "images/logos/Semachi.svg";
      case JangdanType.ginyeombul: return "images/logos/Ginyeombul.svg";
      case JangdanType.banyeombul: return "images/logos/Banyeombul.svg";
    }
  }

  int? get sobakSegmentCount {
    switch (this) {
      case JangdanType.jinyang: return 3;
      case JangdanType.jungmori: return 2;
      case JangdanType.eotjungmori: return 2;
      default: return null;
    }
  }

  String get bakInformation {
    switch (this) {
      case JangdanType.jinyang: return "24박 3소박";
      case JangdanType.jungmori: return "12박 2소박";
      case JangdanType.jungjungmori: return "4박 3소박";
      case JangdanType.jajinmori: return "4박 3소박";
      case JangdanType.gutgeori: return "4박 3소박";
      case JangdanType.hwimori: return "4박 2소박";
      case JangdanType.dongsalpuri: return "4박 2소박";
      case JangdanType.eonmori: return "4박 3+2소박";
      case JangdanType.eotjungmori: return "6박 2소박";
      case JangdanType.semachi: return "3박 3소박";
      case JangdanType.ginyeombul: return "6박 3소박";
      case JangdanType.banyeombul: return "6박 3소박";
    }
  }
}
