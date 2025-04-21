import '../model/accent.dart';
import '../model/jangdan.dart';
import '../model/jangdan_type.dart';

List<Jangdan> basicJangdanList = [
  Jangdan(
    name: "진양",
    createdAt: DateTime.now(),
    bpm: 30,
    jangdanType: JangdanType.jinyang,
    accents: [
      [
        [Accent.strong, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.medium, Accent.none, Accent.none],
        [Accent.medium, Accent.none, Accent.none],
      ],
      [
        [Accent.weak, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.medium, Accent.none, Accent.none],
        [Accent.medium, Accent.none, Accent.none],
      ],
      [
        [Accent.weak, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.medium, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
      ],
      [
        [Accent.weak, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.medium, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
      ],
    ],
  ),
  Jangdan(
    name: "중모리",
    createdAt: DateTime.now(),
    jangdanType: JangdanType.jungmori,
    bpm: 90,
    accents: [
      [
        [Accent.strong, Accent.none],
        [Accent.weak, Accent.none],
        [Accent.medium, Accent.none],
        [Accent.weak, Accent.none],
        [Accent.medium, Accent.none],
        [Accent.medium, Accent.none],
      ],
      [
        [Accent.weak, Accent.none],
        [Accent.weak, Accent.none],
        [Accent.medium, Accent.none],
        [Accent.weak, Accent.none],
        [Accent.weak, Accent.none],
        [Accent.weak, Accent.none],
      ],
    ],
  ),
  Jangdan(
    name: "중중모리",
    createdAt: DateTime.now(),
    jangdanType: JangdanType.jungjungmori,
    bpm: 50,
    accents: [
      [
        [Accent.strong, Accent.weak, Accent.medium],
        [Accent.weak, Accent.medium, Accent.medium],
        [Accent.weak, Accent.weak, Accent.medium],
        [Accent.weak, Accent.medium, Accent.medium],
      ],
    ],
  ),
  Jangdan(
    name: "자진모리",
    createdAt: DateTime.now(),
    jangdanType: JangdanType.jajinmori,
    bpm: 100,
    accents: [
      [
        [Accent.strong, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.medium],
        [Accent.weak, Accent.medium, Accent.none],
      ],
    ],
  ),
  Jangdan(
    name: "굿거리",
    createdAt: DateTime.now(),
    jangdanType: JangdanType.gutgeori,
    bpm: 50,
    accents: [
      [
        [Accent.strong, Accent.none, Accent.medium],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.medium],
        [Accent.weak, Accent.none, Accent.none],
      ],
    ],
  ),
  Jangdan(
    name: "동살풀이",
    createdAt: DateTime.now(),
    jangdanType: JangdanType.dongsalpuri,
    bpm: 125,
    accents: [
      [
        [Accent.strong, Accent.none],
        [Accent.weak, Accent.none],
        [Accent.weak, Accent.medium],
        [Accent.weak, Accent.none],
      ],
    ],
  ),
  Jangdan(
    name: "휘모리",
    createdAt: DateTime.now(),
    jangdanType: JangdanType.hwimori,
    bpm: 100,
    accents: [
      [
        [Accent.strong, Accent.none],
        [Accent.weak, Accent.none],
        [Accent.weak, Accent.medium],
        [Accent.weak, Accent.none],
      ],
    ],
  ),
  Jangdan(
    name: "엇모리",
    createdAt: DateTime.now(),
    jangdanType: JangdanType.eonmori,
    bpm: 95,
    accents: [
      [
        [Accent.strong, Accent.none, Accent.weak],
        [Accent.medium, Accent.none],
        [Accent.weak, Accent.none, Accent.medium],
        [Accent.weak, Accent.none],
      ],
    ],
  ),
  Jangdan(
    name: "세마치",
    createdAt: DateTime.now(),
    jangdanType: JangdanType.semachi,
    bpm: 90,
    accents: [
      [
        [Accent.strong, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.medium],
        [Accent.weak, Accent.medium, Accent.none],
      ],
    ],
  ),
  Jangdan(
    name: "엇중모리",
    createdAt: DateTime.now(),
    jangdanType: JangdanType.eotjungmori,
    bpm: 78,
    accents: [
      [
        [Accent.strong, Accent.none],
        [Accent.weak, Accent.none],
        [Accent.medium, Accent.none],
        [Accent.weak, Accent.none],
        [Accent.medium, Accent.none],
        [Accent.weak, Accent.none],
      ],
    ],
  ),
  Jangdan(
    name: "긴염불",
    createdAt: DateTime.now(),
    jangdanType: JangdanType.ginyeombul,
    bpm: 25,
    accents: [
      [
        [Accent.strong, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.medium, Accent.none, Accent.weak],
      ],
      [
        [Accent.weak, Accent.none, Accent.none],
        [Accent.strong, Accent.weak, Accent.weak],
        [Accent.medium, Accent.none, Accent.weak],
      ],
    ],
  ),
  Jangdan(
    name: "반염불",
    createdAt: DateTime.now(),
    jangdanType: JangdanType.banyeombul,
    bpm: 65,
    accents: [
      [
        [Accent.strong, Accent.none, Accent.none],
        [Accent.weak, Accent.none, Accent.none],
        [Accent.medium, Accent.none, Accent.medium],
      ],
      [
        [Accent.weak, Accent.none, Accent.none],
        [Accent.weak, Accent.weak, Accent.weak],
        [Accent.none, Accent.none, Accent.none],
      ],
    ],
  ),
];

final Map<String, Jangdan> basicJangdanData = {
  for (final item in basicJangdanList) item.name: item
};