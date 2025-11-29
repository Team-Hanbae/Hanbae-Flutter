import 'package:hanbae/model/jangdan_type.dart';

enum JangdanCategory { minsokak, jeongak, samulnori, custom, popular }

extension JangdanCategoryExtension on JangdanCategory {
  String get label {
    switch (this) {
      case JangdanCategory.minsokak:
        return '민속악';
      case JangdanCategory.jeongak:
        return '정악';
      case JangdanCategory.samulnori:
        return '사물놀이';
      case JangdanCategory.custom:
        return '내가 저장한 장단';
      case JangdanCategory.popular:
        return '인기있는';
    }
  }

  List<JangdanType>? get list {
    switch (this) {
      case JangdanCategory.minsokak:
        return [
          JangdanType.jinyang,
          JangdanType.jungmori,
          JangdanType.jungjungmori,
          JangdanType.jajinmori,
          JangdanType.gutgeori,
          JangdanType.eonmori,
          JangdanType.eotjungmori,
          JangdanType.hwimori,
          JangdanType.semachi,
          JangdanType.dongsalpuri,
          JangdanType.jwajilgut,
        ];
      case JangdanCategory.jeongak:
        return [
          JangdanType.sangnyeongsan,
          JangdanType.seryeongsan,
          JangdanType.taryeong,
          JangdanType.chwita,
          JangdanType.jeolhwa,
          JangdanType.ginyeombul,
          JangdanType.banyeombul,
        ];
      case JangdanCategory.samulnori:
        return [
          JangdanType.gutgeori,
          JangdanType.dongsalpuri,
          JangdanType.jajinmori,
          JangdanType.hwimori,
          JangdanType.jwajilgut,
        ];
      case JangdanCategory.custom:
        return null;
      case JangdanCategory.popular:
        return [
          JangdanType.jungmori,
          JangdanType.jinyang,
          JangdanType.jajinmori,
          JangdanType.jungjungmori,
          JangdanType.gutgeori,
          JangdanType.eonmori,
        ];
    }
  }
}
