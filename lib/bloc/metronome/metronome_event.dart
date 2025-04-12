part of 'metronome_bloc.dart';

abstract class MetronomeEvent extends Equatable {
  const MetronomeEvent();

  @override
  List<Object?> get props => [];
}

class SelectJangdan extends MetronomeEvent {
  final Jangdan jangdan;
  const SelectJangdan(this.jangdan);

  @override
  List<Object?> get props => [jangdan];
}

class Play extends MetronomeEvent {}

class Tick extends MetronomeEvent {}

class Stop extends MetronomeEvent {}

class ChangeBpm extends MetronomeEvent {
  final int delta;
  const ChangeBpm(this.delta);

  @override
  List<Object?> get props => [delta];
}

class ToggleAccent extends MetronomeEvent {
  final int rowIndex;
  final int barIndex;
  final int accentIndex;

  const ToggleAccent({
    required this.rowIndex,
    required this.barIndex,
    required this.accentIndex,
  });

  @override
  List<Object?> get props => [rowIndex, barIndex, accentIndex];
}

class ToggleSobak extends MetronomeEvent {}
