part of 'metronome_bloc.dart';

class MetronomeState extends Equatable {
  final Jangdan selectedJangdan;
  final bool isPlaying;
  final bool isSobakOn;
  final int bpm;

  const MetronomeState({
    required this.selectedJangdan,
    required this.isPlaying,
    required this.isSobakOn,
    required this.bpm,
  });

  MetronomeState copyWith({
    Jangdan? selectedJangdan,
    bool? isPlaying,
    bool? isSobakOn,
    int? bpm,
  }) {
    return MetronomeState(
      selectedJangdan: selectedJangdan ?? this.selectedJangdan,
      isPlaying: isPlaying ?? this.isPlaying,
      isSobakOn: isSobakOn ?? this.isSobakOn,
      bpm: bpm ?? this.bpm,
    );
  }

  @override
  List<Object?> get props => [selectedJangdan, isPlaying, isSobakOn, bpm];
}
