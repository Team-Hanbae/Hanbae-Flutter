part of 'jangdan_bloc.dart';

abstract class JangdanEvent extends Equatable {
  const JangdanEvent();

  @override
  List<Object?> get props => [];
}

class LoadJangdan extends JangdanEvent {}

class AddJangdan extends JangdanEvent {
  final Jangdan jangdan;
  const AddJangdan(this.jangdan);

  @override
  List<Object?> get props => [jangdan];
}

class DeleteJangdan extends JangdanEvent {
  final String key;
  const DeleteJangdan(this.key);

  @override
  List<Object?> get props => [key];
}

class UpdateJangdan extends JangdanEvent {
  final String key;
  final Jangdan jangdan;
  const UpdateJangdan(this.key, this.jangdan);

  @override
  List<Object?> get props => [key, jangdan];
}

class AddJangdanSequence extends JangdanEvent {
  final JangdanSequence sequence;
  const AddJangdanSequence(this.sequence);

  @override
  List<Object?> get props => [sequence];
}

class UpdateJangdanSequence extends JangdanEvent {
  final String key;
  final JangdanSequence sequence;
  const UpdateJangdanSequence(this.key, this.sequence);

  @override
  List<Object?> get props => [key, sequence];
}

class DeleteJangdanSequence extends JangdanEvent {
  final String key;
  const DeleteJangdanSequence(this.key);

  @override
  List<Object?> get props => [key];
}

class ChangeJangdanCategory extends JangdanEvent {
  final JangdanCategory category;
  const ChangeJangdanCategory(this.category);
}
