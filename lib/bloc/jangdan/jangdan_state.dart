part of 'jangdan_bloc.dart';

abstract class JangdanState extends Equatable {
  const JangdanState();

  @override
  List<Object?> get props => [];
}

class JangdanInitial extends JangdanState {}

class JangdanLoaded extends JangdanState {
  final List<Jangdan> jangdans;
  final JangdanCategory seletedCategory;

  const JangdanLoaded({
    required this.jangdans,
    this.seletedCategory = JangdanCategory.minsokak,
  });

  JangdanLoaded copyWith({
    List<Jangdan>? jangdans,
    JangdanCategory? seletedCategory,
  }) {
    return JangdanLoaded(
      jangdans: jangdans ?? this.jangdans,
      seletedCategory: seletedCategory ?? this.seletedCategory,
    );
  }

  @override
  List<Object?> get props => [jangdans];
}

class JangdanError extends JangdanState {
  final String message;
  const JangdanError(this.message);

  @override
  List<Object?> get props => [message];
}
