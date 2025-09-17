part of 'metronome_bloc.dart';

class MetronomeState extends Equatable {
  final Jangdan selectedJangdan;
  final bool isPlaying;

  final bool isSobakOn;
  final bool isFlashOn;
  final int bpm;
  final int currentRowIndex;
  final int currentDaebakIndex;
  final int currentSobakIndex;
  final Sound currentSound;
  final bool isTapping;
  final bool minimum;

  /// 예비박 여부
  final bool reserveBeat;
  final int reserveBeatTime;

  const MetronomeState({
    required this.selectedJangdan,
    required this.isPlaying,
    required this.isSobakOn,
    required this.isFlashOn,
    required this.bpm,
    this.currentRowIndex = 0,
    this.currentDaebakIndex = 0,
    this.currentSobakIndex = 0,
    required this.currentSound,
    required this.isTapping,
    required this.minimum,
    required this.reserveBeat,
    this.reserveBeatTime = 0,
  });

  MetronomeState copyWith({
    Jangdan? selectedJangdan,
    bool? isPlaying,
    bool? isSobakOn,
    bool? isFlashOn,
    int? bpm,
    int? currentRowIndex,
    int? currentDaebakIndex,
    int? currentSobakIndex,
    Sound? currentSound,
    bool? isTapping,
    bool? minimum,
    bool? reserveBeat,
    int? reserveBeatTime,
  }) {
    return MetronomeState(
      selectedJangdan: selectedJangdan ?? this.selectedJangdan,
      isPlaying: isPlaying ?? this.isPlaying,
      isSobakOn: isSobakOn ?? this.isSobakOn,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      bpm: bpm ?? this.bpm,
      currentRowIndex: currentRowIndex ?? this.currentRowIndex,
      currentDaebakIndex: currentDaebakIndex ?? this.currentDaebakIndex,
      currentSobakIndex: currentSobakIndex ?? this.currentSobakIndex,
      currentSound: currentSound ?? this.currentSound,
      isTapping: isTapping ?? this.isTapping,
      minimum: minimum ?? this.minimum,
      reserveBeat: reserveBeat ?? this.reserveBeat,
      reserveBeatTime: reserveBeatTime ?? this.reserveBeatTime,
    );
  }

  @override
  List<Object?> get props => [
    selectedJangdan,
    isPlaying,
    isSobakOn,
    isFlashOn,
    bpm,
    currentRowIndex,
    currentDaebakIndex,
    currentSobakIndex,
    currentSound,
    isTapping,
    minimum,
    reserveBeat,
    reserveBeatTime,
  ];
}
