part of 'jangdan_bloc.dart';

abstract class JangdanState extends Equatable {
  const JangdanState();

  @override
  List<Object?> get props => [];
}

class JangdanInitial extends JangdanState {}

class JangdanLoaded extends JangdanState {
  final List<Jangdan> jangdans;
  const JangdanLoaded(this.jangdans);

  @override
  List<Object?> get props => [jangdans];
}

class JangdanError extends JangdanState {
  final String message;
  const JangdanError(this.message);

  @override
  List<Object?> get props => [message];
}