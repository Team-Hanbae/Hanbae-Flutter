import 'package:equatable/equatable.dart';
import 'accent.dart';
import 'jangdan_type.dart'; // Assuming this is where JangdanType is defined

class Jangdan extends Equatable {
  final String name;
  final JangdanType jangdanType;
  final String createdAt;
  final int bpm;
  final List<List<List<Accent>>> accents;

  const Jangdan({
    required this.name,
    required this.createdAt,
    required this.bpm,
    required this.jangdanType,
    required this.accents,
  });

  Jangdan copyWith({
    String? name,
    JangdanType? jangdanType,
    String? createdAt,
    int? bpm,
    List<List<List<Accent>>>? accents,
  }) {
    return Jangdan(
      name: name ?? this.name,
      jangdanType: jangdanType ?? this.jangdanType,
      createdAt: createdAt ?? this.createdAt,
      bpm: bpm ?? this.bpm,
      accents: accents ?? this.accents,
    );
  }

  @override
  List<Object> get props => [name, jangdanType, createdAt, bpm, accents];
}
