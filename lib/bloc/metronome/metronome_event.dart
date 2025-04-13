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
  final int daebakIndex;
  final int sobakIndex;

  const ToggleAccent({
    required this.rowIndex,
    required this.daebakIndex,
    required this.sobakIndex,
  });

  @override
  List<Object?> get props => [rowIndex, daebakIndex, sobakIndex];
}

class ToggleSobak extends MetronomeEvent {}

class ChangeSound extends MetronomeEvent {
  final Sound sound;
  const ChangeSound(this.sound);

  @override
  List<Object?> get props => [sound];
}

class ResetMetronome extends MetronomeEvent {
  const ResetMetronome();
}

class TapTempo extends MetronomeEvent {
  const TapTempo();
}

class StopTapping extends MetronomeEvent {
  const StopTapping();
}
