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

class ChangeJangdanCategory extends JangdanEvent {
  final JangdanCategory category;
  const ChangeJangdanCategory(this.category);
}