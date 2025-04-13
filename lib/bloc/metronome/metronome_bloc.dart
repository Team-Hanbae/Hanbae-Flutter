import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hanbae/model/accent.dart';
import 'dart:async'; // Add this import for Timer
import 'dart:core'; // Add this import for Stopwatch
import '../../model/jangdan.dart';
import '../../data/basic_jangdan_data.dart';
import '../../data/sound_manager.dart';
import '../../model/sound.dart'; // Add this import for Sound
import '../../data/sound_preferences.dart'; // Add import for SoundPreferences

part 'metronome_event.dart';
part 'metronome_state.dart';

class MetronomeBloc extends Bloc<MetronomeEvent, MetronomeState> {
  final Stopwatch _stopwatch = Stopwatch(); // Add Stopwatch field
  Timer? _tickTimer; // Add private Timer field
  final _soundManager = SoundManager();
  final List<DateTime> _tapHistory = []; // Add private list to hold tap timestamps

  MetronomeBloc()
    : super(() {
        final initialJangdan = basicJangdanData["진양"]!;
        final lastRowIndex = initialJangdan.accents.length - 1;
        final lastDaebakIndex = initialJangdan.accents[lastRowIndex].length - 1;
        final lastSobakIndex =
            initialJangdan.accents[lastRowIndex][lastDaebakIndex].length - 1;
        return MetronomeState(
          selectedJangdan: initialJangdan,
          isPlaying: false,
          isSobakOn: false,
          bpm: initialJangdan.bpm,
          currentRowIndex: lastRowIndex,
          currentDaebakIndex: lastDaebakIndex,
          currentSobakIndex: lastSobakIndex,
          currentSound: Sound.clave, // Initialize currentSound field
        );
      }()) {
    SoundPreferences.load().then((loaded) { // Load stored sound
      add(ChangeSound(loaded));
    });

    on<SelectJangdan>((event, emit) {
      emit(
        state.copyWith(selectedJangdan: event.jangdan, bpm: event.jangdan.bpm),
      );
    });

    on<ResetMetronome>((event, emit) {
      final jangdan = state.selectedJangdan;
      final original = basicJangdanData[jangdan.name] ?? jangdan;
      emit(state.copyWith(
        selectedJangdan: original,
        bpm: original.bpm,
      ));
    });

    on<Play>((event, emit) {
      final jangdan = state.selectedJangdan;
      final lastRowIndex = jangdan.accents.length - 1;
      final lastDaebakIndex = jangdan.accents[lastRowIndex].length - 1;
      final lastSobakIndex =
          jangdan.accents[lastRowIndex][lastDaebakIndex].length - 1;

      emit(
        state.copyWith(
          isPlaying: true,
          currentRowIndex: lastRowIndex,
          currentDaebakIndex: lastDaebakIndex,
          currentSobakIndex: lastSobakIndex,
        ),
      );

      _startPreciseTicker();
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
      if (state.isSobakOn || sobak == 0) {
        if (accent != Accent.none) {
          _soundManager.play('sounds/${state.currentSound.name}_${accent.name}.mp3'); // Update sound playback
        }
        print('🔊 $row $daebak $sobak ${accent.name}');
      }


      emit(
        state.copyWith(
          currentRowIndex: row,
          currentDaebakIndex: daebak,
          currentSobakIndex: sobak,
        ),
      );
    });

    on<Stop>((event, emit) {
      _stopPreciseTicker(); // Call to stop precise ticker
      emit(state.copyWith(isPlaying: false));
    });

    on<ChangeBpm>((event, emit) {
      final newBpm = (state.bpm + event.delta).clamp(10, 300);
      emit(state.copyWith(bpm: newBpm));
    });

    on<ChangeSound>((event, emit) { // Add new event handler
      SoundPreferences.save(event.sound); // Save selected sound to preferences
      emit(state.copyWith(currentSound: event.sound));
    });

    on<TapTempo>((event, emit) { // Handle TapTempo event
      final now = DateTime.now();

      if (_tapHistory.isNotEmpty &&
          now.difference(_tapHistory.last).inMilliseconds > 6000) {
        _tapHistory.clear(); // Reset if taps are too far apart
      }

      _tapHistory.add(now);

      if (_tapHistory.length >= 2) {
        final intervals = <int>[];
        for (int i = 1; i < _tapHistory.length; i++) {
          intervals.add(_tapHistory[i].difference(_tapHistory[i - 1]).inMilliseconds);
        }
        final averageMs = intervals.reduce((a, b) => a + b) / intervals.length;
        final bpm = (60000 / averageMs).round().clamp(10, 300);

        emit(state.copyWith(bpm: bpm));
      }

      if (_tapHistory.length > 5) {
        _tapHistory.removeAt(0); // Keep last 5 taps
      }
    });

    on<ToggleAccent>((event, emit) {
      final oldJangdan = state.selectedJangdan;

      // Deep copy of accents
      final updatedAccents =
          oldJangdan.accents
              .map((row) => row.map((bar) => List<Accent>.from(bar)).toList())
              .toList();

      final current =
          updatedAccents[event.rowIndex][event.daebakIndex][event.sobakIndex];
      final next = Accent.values[(current.index + 1) % Accent.values.length];

      updatedAccents[event.rowIndex][event.daebakIndex][event.sobakIndex] = next;

      final updatedJangdan = oldJangdan.copyWith(accents: updatedAccents);
      emit(state.copyWith(selectedJangdan: updatedJangdan));
    });

    on<ToggleSobak>((event, emit) {
      emit(state.copyWith(isSobakOn: !state.isSobakOn));
    });
  }

  void _startPreciseTicker() {
    _stopwatch.start();

    // Immediately trigger first tick
    add(Tick());

    void scheduleTick() {
      final interval = Duration(milliseconds: (60000 / state.bpm).round());
      final elapsed = _stopwatch.elapsed;
      final correction =
          interval -
          Duration(
            milliseconds: elapsed.inMilliseconds % interval.inMilliseconds,
          );

      _tickTimer = Timer(correction, () {
        add(Tick());
        scheduleTick(); // schedule next tick
      });
    }

    scheduleTick();
  }

  void _stopPreciseTicker() {
    _tickTimer?.cancel();
    _tickTimer = null;
    _stopwatch.stop();
    _stopwatch.reset();
  }
}
