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

class SelectSequence extends MetronomeEvent {
  final JangdanSequence sequence;
  const SelectSequence(this.sequence);

  @override
  List<Object?> get props => [sequence];
}

class JumpToSequenceItem extends MetronomeEvent {
  final int index;
  const JumpToSequenceItem(this.index);

  @override
  List<Object?> get props => [index];
}

class ReplaceCurrentSequence extends MetronomeEvent {
  final JangdanSequence sequence;
  const ReplaceCurrentSequence(this.sequence);

  @override
  List<Object?> get props => [sequence];
}

class Play extends MetronomeEvent {
  final AppBarMode appState;
  const Play({this.appState = AppBarMode.builtin});
}

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

class ToggleReserveBeat extends MetronomeEvent {
  final bool? reserveBeat;

  const ToggleReserveBeat({this.reserveBeat});

  @override
  List<Object?> get props => [reserveBeat];
}

class ChangeSound extends MetronomeEvent {
  final Sound sound;
  const ChangeSound(this.sound);

  @override
  List<Object?> get props => [sound];
}

class ToggleFlash extends MetronomeEvent {}

class ResetMetronome extends MetronomeEvent {
  const ResetMetronome();
}

class TapTempo extends MetronomeEvent {
  const TapTempo();
}

class StopTapping extends MetronomeEvent {
  const StopTapping();
}

class ToggleMinimum extends MetronomeEvent {
  const ToggleMinimum();
}

class PrecountTick extends MetronomeEvent {
  final int count;
  const PrecountTick(this.count);

  @override
  List<Object?> get props => [count];
}
