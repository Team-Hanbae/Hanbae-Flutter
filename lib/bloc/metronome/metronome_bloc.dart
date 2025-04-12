import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hanbae/model/accent.dart';
import 'dart:async'; // Add this import for Timer
import '../../model/jangdan.dart';
import '../../data/basic_jangdan_data.dart';
import '../../data/sound_manager.dart';

part 'metronome_event.dart';
part 'metronome_state.dart';

class MetronomeBloc extends Bloc<MetronomeEvent, MetronomeState> {
  Timer? _timer; // Add private Timer field
  final _soundManager = SoundManager();

  MetronomeBloc()
      : super(() {
          final initialJangdan = basicJangdanData["진양"]!;
          final lastRowIndex = initialJangdan.accents.length - 1;
          final lastDaebakIndex = initialJangdan.accents[lastRowIndex].length - 1;
          final lastSobakIndex = initialJangdan.accents[lastRowIndex][lastDaebakIndex].length - 1;
          return MetronomeState(
            selectedJangdan: initialJangdan,
            isPlaying: false,
            isSobakOn: false,
            bpm: initialJangdan.bpm,
            currentRowIndex: lastRowIndex,
            currentDaebakIndex: lastDaebakIndex,
            currentSobakIndex: lastSobakIndex,
          );
        }()) {
    on<SelectJangdan>((event, emit) {
      emit(
        state.copyWith(selectedJangdan: event.jangdan, bpm: event.jangdan.bpm),
      );
    });

    on<Play>((event, emit) {
      _timer?.cancel();
      _timer = Timer.periodic(
        Duration(milliseconds: (60000 / state.bpm).round()),
        (_) => add(Tick()),
      );
      emit(state.copyWith(isPlaying: true));
    });

    on<Tick>((event, emit) async {
      final jangdan = state.selectedJangdan;
      int row = state.currentRowIndex;
      int daebak = state.currentDaebakIndex;
      int sobak = state.currentSobakIndex;
      
      sobak++;
      if (sobak >= jangdan.accents[row][daebak].length) {
        daebak++;
        if (daebak >= jangdan.accents[row].length) {
          row++;
          if (row >= jangdan.accents.length) {
            row = 0;
          }
          daebak = 0;
        }
        sobak = 0;
      }

      final accent = jangdan.accents[row][daebak][sobak];
      if (accent != Accent.none) {
        _soundManager.play('sounds/beep_${accent.name}.mp3');
      }

      print('🔊 $row $daebak $sobak ${accent.name}');

      emit(state.copyWith(
        currentRowIndex: row,
        currentDaebakIndex: daebak,
        currentSobakIndex: sobak,
      ));
    });

    on<Stop>((event, emit) {
      _timer?.cancel();
      _timer = null;
      emit(state.copyWith(isPlaying: false));
    });

    on<ChangeBpm>((event, emit) {
      final newBpm = (state.bpm + event.delta).clamp(30, 240);
      emit(state.copyWith(bpm: newBpm));
    });

    on<ToggleAccent>((event, emit) {
      final oldJangdan = state.selectedJangdan;

      // Deep copy of accents
      final updatedAccents = oldJangdan.accents
          .map((row) => row.map((bar) => List<Accent>.from(bar)).toList())
          .toList();

      final current = updatedAccents[event.rowIndex][event.barIndex][event.accentIndex];
      final next = Accent.values[(current.index + 1) % Accent.values.length];

      updatedAccents[event.rowIndex][event.barIndex][event.accentIndex] = next;

      final updatedJangdan = oldJangdan.copyWith(accents: updatedAccents);
      emit(state.copyWith(selectedJangdan: updatedJangdan));
    });

    on<ToggleSobak>((event, emit) {
      emit(state.copyWith(isSobakOn: !state.isSobakOn));
    });
  }
}
