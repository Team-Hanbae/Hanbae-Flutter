part of 'jangdan_bloc.dart';

abstract class JangdanState extends Equatable {
  const JangdanState();

  @override
  List<Object?> get props => [];
}

class JangdanInitial extends JangdanState {}

class JangdanLoaded extends JangdanState {
  final List<Jangdan> jangdans;
  final List<JangdanSequence> sequences;
  final List<SavedJangdanItem> savedItems;
  final JangdanCategory selectedCategory;
  final List<Jangdan> recentJangdans;
  final List<SavedJangdanItem> recentItems;

  const JangdanLoaded({
    required this.jangdans,
    this.sequences = const [],
    List<SavedJangdanItem>? savedItems,
    this.selectedCategory = JangdanCategory.minsokak,
    this.recentJangdans = const [],
    this.recentItems = const [],
  }) : savedItems = savedItems ?? const [];

  JangdanLoaded copyWith({
    List<Jangdan>? jangdans,
    List<JangdanSequence>? sequences,
    List<SavedJangdanItem>? savedItems,
    JangdanCategory? selectedCategory,
    List<Jangdan>? recentJangdans,
    List<SavedJangdanItem>? recentItems,
  }) {
    return JangdanLoaded(
      jangdans: jangdans ?? this.jangdans,
      sequences: sequences ?? this.sequences,
      savedItems: savedItems ?? this.savedItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      recentJangdans: recentJangdans ?? this.recentJangdans,
      recentItems: recentItems ?? this.recentItems,
    );
  }

  @override
  List<Object?> get props => [
    jangdans,
    sequences,
    savedItems,
    selectedCategory,
    recentJangdans,
    recentItems,
  ];
}

class JangdanError extends JangdanState {
  final String message;
  const JangdanError(this.message);

  @override
  List<Object?> get props => [message];
}
