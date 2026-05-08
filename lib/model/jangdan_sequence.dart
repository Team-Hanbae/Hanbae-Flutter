import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'jangdan.dart';

part 'jangdan_sequence.g.dart';

@HiveType(typeId: 4)
class JangdanSequence extends Equatable {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final DateTime createdAt;
  @HiveField(2)
  final List<JangdanSequenceItem> items;

  const JangdanSequence({
    required this.name,
    required this.createdAt,
    required this.items,
  });

  JangdanSequence copyWith({
    String? name,
    DateTime? createdAt,
    List<JangdanSequenceItem>? items,
  }) {
    return JangdanSequence(
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [name, createdAt, items];
}

@HiveType(typeId: 5)
class JangdanSequenceItem extends Equatable {
  @HiveField(0)
  final int order;
  @HiveField(1)
  final int repeatCount;
  @HiveField(2)
  final Jangdan jangdan;

  const JangdanSequenceItem({
    required this.order,
    required this.repeatCount,
    required this.jangdan,
  });

  JangdanSequenceItem copyWith({
    int? order,
    int? repeatCount,
    Jangdan? jangdan,
  }) {
    return JangdanSequenceItem(
      order: order ?? this.order,
      repeatCount: repeatCount ?? this.repeatCount,
      jangdan: jangdan ?? this.jangdan,
    );
  }

  @override
  List<Object?> get props => [order, repeatCount, jangdan];
}
