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
  final List<Jangdan> recentJangdans;

  const JangdanLoaded({
    required this.jangdans,
    this.selectedCategory = JangdanCategory.minsokak,
    this.recentJangdans = const [],
  });

  JangdanLoaded copyWith({
    List<Jangdan>? jangdans,
    JangdanCategory? selectedCategory,
    List<Jangdan>? recentJangdans,
  }) {
    return JangdanLoaded(
      jangdans: jangdans ?? this.jangdans,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      recentJangdans: recentJangdans ?? this.recentJangdans,
    );
  }

  @override
  List<Object?> get props => [jangdans, selectedCategory, recentJangdans];
}

class JangdanError extends JangdanState {
  final String message;
  const JangdanError(this.message);

  @override
  List<Object?> get props => [message];
}
