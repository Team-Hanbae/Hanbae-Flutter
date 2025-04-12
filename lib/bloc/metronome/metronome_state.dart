part of 'metronome_bloc.dart';

class MetronomeState extends Equatable {
  final Jangdan selectedJangdan;
  final bool isPlaying;
  final bool isSobakOn;
  final int bpm;
  final int currentRowIndex;
  final int currentDaebakIndex;
  final int currentSobakIndex;

  const MetronomeState({
    required this.selectedJangdan,
    required this.isPlaying,
    required this.isSobakOn,
    required this.bpm,
    this.currentRowIndex = 0,
    this.currentDaebakIndex = 0,
    this.currentSobakIndex = 0,
  });

  MetronomeState copyWith({
    Jangdan? selectedJangdan,
    bool? isPlaying,
    bool? isSobakOn,
    int? bpm,
    int? currentRowIndex,
    int? currentDaebakIndex,
    int? currentSobakIndex,
  }) {
    return MetronomeState(
      selectedJangdan: selectedJangdan ?? this.selectedJangdan,
      isPlaying: isPlaying ?? this.isPlaying,
      isSobakOn: isSobakOn ?? this.isSobakOn,
      bpm: bpm ?? this.bpm,
      currentRowIndex: currentRowIndex ?? this.currentRowIndex,
      currentDaebakIndex: currentDaebakIndex ?? this.currentDaebakIndex,
      currentSobakIndex: currentSobakIndex ?? this.currentSobakIndex,
    );
  }

  @override
  List<Object?> get props => [
        selectedJangdan,
        isPlaying,
        isSobakOn,
        bpm,
        currentRowIndex,
        currentDaebakIndex,
        currentSobakIndex,
      ];
}
