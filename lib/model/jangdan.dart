import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'accent.dart';
import 'jangdan_type.dart'; // Assuming this is where JangdanType is defined

part 'jangdan.g.dart';

@HiveType(typeId: 0)
class Jangdan extends Equatable {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final JangdanType jangdanType;
  @HiveField(2)
  final DateTime createdAt;
  @HiveField(3)
  final int bpm;
  @HiveField(4)
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
    DateTime? createdAt,
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
