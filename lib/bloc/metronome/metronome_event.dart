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

class TogglePlay extends MetronomeEvent {}

class ChangeBpm extends MetronomeEvent {
  final int delta;
  const ChangeBpm(this.delta);

  @override
  List<Object?> get props => [delta];
}
