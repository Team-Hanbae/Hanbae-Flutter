import 'package:equatable/equatable.dart';
import 'jangdan.dart';
import 'jangdan_sequence.dart';

enum SavedJangdanItemKind { custom, sequence }

class SavedJangdanItem extends Equatable {
  final SavedJangdanItemKind kind;
  final Jangdan? jangdan;
  final JangdanSequence? sequence;

  const SavedJangdanItem.custom(this.jangdan)
    : kind = SavedJangdanItemKind.custom,
      sequence = null;

  const SavedJangdanItem.sequence(this.sequence)
    : kind = SavedJangdanItemKind.sequence,
      jangdan = null;

  String get name => jangdan?.name ?? sequence!.name;
  DateTime get createdAt => jangdan?.createdAt ?? sequence!.createdAt;

  @override
  List<Object?> get props => [kind, jangdan, sequence];
}
