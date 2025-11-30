part of 'jangdan_bloc.dart';

abstract class JangdanState extends Equatable {
  const JangdanState();

  @override
  List<Object?> get props => [];
}

class JangdanInitial extends JangdanState {}

class JangdanLoaded extends JangdanState {
  final List<Jangdan> jangdans;
  final JangdanCategory selectedCategory;

  const JangdanLoaded({
    required this.jangdans,
    this.selectedCategory = JangdanCategory.minsokak,
  });

  JangdanLoaded copyWith({
    List<Jangdan>? jangdans,
    JangdanCategory? selectedCategory,
  }) {
    return JangdanLoaded(
      jangdans: jangdans ?? this.jangdans,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [jangdans, selectedCategory];
}

class JangdanError extends JangdanState {
  final String message;
  const JangdanError(this.message);

  @override
  List<Object?> get props => [message];
}
