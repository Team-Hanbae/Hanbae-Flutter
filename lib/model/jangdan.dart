import 'package:equatable/equatable.dart';
import 'accent.dart';

class Jangdan extends Equatable {
  final String name;
  final String jangdanType;
  final String createdAt;
  final int bpm;
  final List<List<List<Accent>>> accents;

  const Jangdan({
    required this.name, 
    required this.createdAt, 
    required this.bpm, 
    required this.jangdanType, 
    required this.accents
  });

  @override
  List<Object> get props => [name, bpm, jangdanType];
}

const Jangdan jinyang = Jangdan(
  name: "진양",
  createdAt: "2024.03.08",
  bpm: 30,
  jangdanType: "진양",
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
  ]
);