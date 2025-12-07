import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hanbae/main.dart';
import 'package:hanbae/model/accent.dart';
import 'package:hanbae/model/jangdan_type.dart';
import 'package:hanbae/presentation/metronome/metronome_screen.dart';
import 'package:hanbae/utils/local_storage.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../model/jangdan.dart';
import '../../data/basic_jangdan_data.dart';
import '../../data/sound_manager.dart';
import '../../model/sound.dart';
import '../../data/sound_preferences.dart';

part 'metronome_event.dart';
part 'metronome_state.dart';

class MetronomeBloc extends Bloc<MetronomeEvent, MetronomeState> {
  Timer? _tickTimer;
  Timer? _tapResetTimer;
  Timer? _precountTimer;
  final List<DateTime> _tapHistory = [];
  double _averageSobakPerDaebak = 1.0;
  final Box<Jangdan> _jangdanBox = Hive.box<Jangdan>('customJangdanBox');
  DateTime? _playStartTime;

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
          isFlashOn: false,
          bpm: initialJangdan.bpm,
          currentRowIndex: lastRowIndex,
          currentDaebakIndex: lastDaebakIndex,
          currentSobakIndex: lastSobakIndex,
          currentSound: Sound.janggu1,
          isTapping: false,
          minimum: false,
          reserveBeat: false,
        );
      }()) {
    SoundPreferences.load().then((loaded) {
      add(ChangeSound(loaded));
    });

    on<PrecountTick>((event, emit) {
      emit(state.copyWith(reserveBeatTime: event.count));
      if (event.count <= 0) {
        _startPreciseTicker();
        WakelockPlus.enable();
      }
    });

    on<SelectJangdan>((event, emit) {
      emit(
        state.copyWith(selectedJangdan: event.jangdan, bpm: event.jangdan.bpm),
      );
    });

    on<ResetMetronome>((event, emit) async {
      final jangdan = state.selectedJangdan;
      final original =
          basicJangdanData[jangdan.name] ??
          _jangdanBox.get(jangdan.name) ??
          jangdan;
      emit(state.copyWith(selectedJangdan: original, bpm: original.bpm));
    });

    on<Play>((event, emit) {
      final jangdan = state.selectedJangdan;
      final lastRowIndex = jangdan.accents.length - 1;
      final lastDaebakIndex = jangdan.accents[lastRowIndex].length - 1;
      final lastSobakIndex =
          jangdan.accents[lastRowIndex][lastDaebakIndex].length - 1;

      final totalDaebak = jangdan.accents.expand((row) => row).length;
      final totalSobak =
          jangdan.accents
              .expand((row) => row)
              .expand((daebak) => daebak)
              .length;
      final averageSobakPerDaebak = totalSobak / totalDaebak;

      _averageSobakPerDaebak = averageSobakPerDaebak;

      emit(
        state.copyWith(
          isPlaying: true,
          currentRowIndex: lastRowIndex,
          currentDaebakIndex: lastDaebakIndex,
          currentSobakIndex: lastSobakIndex,
        ),
      );

      _playStartTime = DateTime.now();

      final reserveBeat = state.reserveBeat;

      if (reserveBeat) {
        _startPrecountTicker();
      } else {
        _startPreciseTicker();
        WakelockPlus.enable();
      }

      if (event.appState != AppBarMode.create) {
        Storage().addRecentJangdan(jangdan.name);
      }
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
          SoundManager.play(state.currentSound, accent);
        }
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
      if (_playStartTime != null) {
        final duration =
            DateTime.now().difference(_playStartTime!).inMilliseconds;
        final seconds = duration / 1000;
        final roundedDuration = (seconds * 100).round() / 100;
        final jangdanType = state.selectedJangdan.jangdanType.label;
        final jangdanName = state.selectedJangdan.name;

        mixpanel.track(
          'metronome_play',
          properties: {
            'duration': roundedDuration,
            'sound_type': state.currentSound.label,
            'jangdan_type': jangdanType,
            'jangdan_name':
                jangdanType == jangdanName ? "template" : jangdanName,
          },
        );
        _playStartTime = null;
      }

      _stopPreciseTicker();
      WakelockPlus.disable();
      emit(state.copyWith(isPlaying: false, reserveBeatTime: 0));
    });

    on<ChangeBpm>((event, emit) {
      add(const StopTapping());
      final newBpm = (state.bpm + event.delta).clamp(1, 300);
      emit(
        state.copyWith(
          selectedJangdan: state.selectedJangdan.copyWith(bpm: newBpm),
          bpm: newBpm,
        ),
      );
    });

    on<ChangeSound>((event, emit) {
      SoundPreferences.save(event.sound);
      emit(state.copyWith(currentSound: event.sound));
    });

    on<TapTempo>((event, emit) {
      emit(state.copyWith(isTapping: true));
      final now = DateTime.now();

      if (_tapHistory.isNotEmpty &&
          now.difference(_tapHistory.last).inMilliseconds > 6000) {
        _tapHistory.clear();
      }

      _tapHistory.add(now);

      if (_tapHistory.length >= 2) {
        final intervals = <int>[];
        for (int i = 1; i < _tapHistory.length; i++) {
          intervals.add(
            _tapHistory[i].difference(_tapHistory[i - 1]).inMilliseconds,
          );
        }
        final averageMs = intervals.reduce((a, b) => a + b) / intervals.length;
        final bpm = (60000 / averageMs).round().clamp(10, 300);

        emit(state.copyWith(bpm: bpm, isTapping: true));
      }

      if (_tapHistory.length > 5) {
        _tapHistory.removeAt(0);
      }

      _tapResetTimer?.cancel();
      _tapResetTimer = Timer(const Duration(seconds: 6), () {
        add(const StopTapping());
      });
    });

    on<StopTapping>((event, emit) {
      emit(state.copyWith(isTapping: false));
    });

    on<ToggleAccent>((event, emit) {
      add(const StopTapping());
      final oldJangdan = state.selectedJangdan;

      final updatedAccents =
          oldJangdan.accents
              .map((row) => row.map((bar) => List<Accent>.from(bar)).toList())
              .toList();

      final current =
          updatedAccents[event.rowIndex][event.daebakIndex][event.sobakIndex];
      final next = Accent.values[(current.index + 1) % Accent.values.length];

      updatedAccents[event.rowIndex][event.daebakIndex][event.sobakIndex] =
          next;

      final updatedJangdan = oldJangdan.copyWith(accents: updatedAccents);
      emit(state.copyWith(selectedJangdan: updatedJangdan));
    });

    on<ToggleSobak>((event, emit) {
      emit(state.copyWith(isSobakOn: !state.isSobakOn));
    });

    on<ToggleReserveBeat>((event, emit) async {
      final newReserveBeatValue = event.reserveBeat ?? !state.reserveBeat;

      await Storage().setReserveBeat(newReserveBeatValue);

      emit(state.copyWith(reserveBeat: newReserveBeatValue));
    });

    on<ToggleFlash>((event, emit) {
      emit(state.copyWith(isFlashOn: !state.isFlashOn));
    });

    on<ToggleMinimum>((event, emit) {
      emit(state.copyWith(minimum: !state.minimum));
    });
  }

  void _startPrecountTicker() {
    int precount = 3;

    void tick() {
      if (!state.isPlaying) {
        _precountTimer?.cancel();
        _precountTimer = null;
        // ignore: invalid_use_of_visible_for_testing_member
        emit(state.copyWith(reserveBeatTime: 0));
        return;
      }
      final bpm = state.bpm;
      final interval = Duration(milliseconds: (60000 / bpm).round());

      add(PrecountTick(precount));
      if (precount > 0) {
        SoundManager.play(Sound.clave, Accent.medium);
      }
      precount--;

      if (precount >= 0) {
        _precountTimer = Timer(interval, tick);
      }
    }

    tick();
  }

  void _startPreciseTicker() {
    void tickLoop() {
      final bpm = state.bpm;
      final interval = Duration(
        milliseconds: (60000 / (bpm * _averageSobakPerDaebak)).round(),
      );

      _tickTimer = Timer(interval, () {
        add(Tick());
        tickLoop();
      });
    }

    add(Tick());
    tickLoop();
  }

  void _stopPreciseTicker() {
    _tickTimer?.cancel();
    _tickTimer = null;
    _precountTimer?.cancel();
    _precountTimer = null;
  }
}
