import 'package:hanbae/data/basic_jangdan_data.dart';
import 'package:hanbae/model/jangdan_type.dart';
import 'package:hanbae/model/jangdan.dart';

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

  List<Jangdan?>? get list {
    switch (this) {
      case JangdanCategory.minsokak:
        return [
          basicJangdanData[JangdanType.jinyang.label],
          basicJangdanData[JangdanType.jungmori.label],
          basicJangdanData[JangdanType.jungjungmori.label],
          basicJangdanData[JangdanType.jajinmori.label],
          basicJangdanData[JangdanType.gutgeori.label],
          basicJangdanData[JangdanType.eonmori.label],
          basicJangdanData[JangdanType.eotjungmori.label],
          basicJangdanData[JangdanType.hwimori.label],
          basicJangdanData[JangdanType.semachi.label],
          basicJangdanData[JangdanType.dongsalpuri.label],
          basicJangdanData[JangdanType.ginyeombul.label],
          basicJangdanData[JangdanType.banyeombul.label],
          basicJangdanData[JangdanType.jwajilgut.label],
        ];
      case JangdanCategory.jeongak:
        return [
          basicJangdanData[JangdanType.sangnyeongsan.label],
          basicJangdanData[JangdanType.seryeongsan.label],
          basicJangdanData[JangdanType.dodeuri.label],
          basicJangdanData[JangdanType.taryeong.label],
          basicJangdanData[JangdanType.chwita.label],
          basicJangdanData[JangdanType.jeolhwa.label],
        ];
      case JangdanCategory.samulnori:
        return [
          basicJangdanData[JangdanType.gutgeori.label],
          basicJangdanData[JangdanType.dongsalpuri.label],
          basicJangdanData[JangdanType.jajinmori.label],
          basicJangdanData[JangdanType.hwimori.label],
          basicJangdanData[JangdanType.jwajilgut.label],
        ];
      case JangdanCategory.custom:
        return null;
      case JangdanCategory.popular:
        return [
          basicJangdanData[JangdanType.jungmori.label],
          basicJangdanData[JangdanType.jinyang.label],
          basicJangdanData[JangdanType.jajinmori.label],
          basicJangdanData[JangdanType.jungjungmori.label],
          basicJangdanData[JangdanType.gutgeori.label],
          basicJangdanData[JangdanType.eonmori.label],
        ];
    }
  }
}
