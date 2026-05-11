import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hanbae/data/analytics_service.dart';
import 'package:hanbae/data/local_logger.dart';
import 'package:hanbae/model/accent.dart';
import 'package:hanbae/model/jangdan_type.dart';
import 'package:hanbae/model/local_log.dart';
import 'package:hanbae/model/jangdan_sequence.dart';
import 'package:hanbae/model/recent_play_item.dart';
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
        state.copyWith(
          selectedJangdan: event.jangdan,
          bpm: event.jangdan.bpm,
          clearSequence: true,
          skipNextSequenceAdvance: false,
        ),
      );
    });

    on<SelectSequence>((event, emit) {
      final sequence = event.sequence;
      if (sequence.items.isEmpty) return;
      emit(
        state.copyWith(
          selectedJangdan: sequence.items.first.jangdan,
          bpm: sequence.items.first.jangdan.bpm,
          currentSequence: sequence,
          currentSequenceIndex: 0,
          currentSequenceRepeat: 1,
          skipNextSequenceAdvance: true,
        ),
      );
    });

    on<JumpToSequenceItem>((event, emit) {
      final sequence = state.currentSequence;
      if (sequence == null ||
          event.index < 0 ||
          event.index >= sequence.items.length) {
        return;
      }
      final item = sequence.items[event.index];
      emit(
        state.copyWith(
          selectedJangdan: item.jangdan,
          bpm: item.jangdan.bpm,
          currentSequenceIndex: event.index,
          currentSequenceRepeat: 1,
          currentRowIndex: item.jangdan.accents.length - 1,
          currentDaebakIndex: item.jangdan.accents.last.length - 1,
          currentSobakIndex: item.jangdan.accents.last.last.length - 1,
          skipNextSequenceAdvance: true,
        ),
      );
    });

    on<ReplaceCurrentSequence>((event, emit) {
      if (event.sequence.items.isEmpty) return;
      emit(
        state.copyWith(
          currentSequence: event.sequence,
          currentSequenceIndex: 0,
          currentSequenceRepeat: 1,
          selectedJangdan: event.sequence.items.first.jangdan,
          bpm: event.sequence.items.first.jangdan.bpm,
          skipNextSequenceAdvance: true,
        ),
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
          skipNextSequenceAdvance: state.currentSequence != null,
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

      if (event.appState == AppBarMode.sequence &&
          state.currentSequence != null) {
        Storage().addRecentJangdan(
          state.currentSequence!.name,
          kind: RecentPlayKind.sequence,
        );
      } else if (event.appState == AppBarMode.builtin) {
        Storage().addRecentJangdan(jangdan.name, kind: RecentPlayKind.builtin);
      } else if (event.appState == AppBarMode.custom) {
        Storage().addRecentJangdan(jangdan.name, kind: RecentPlayKind.custom);
      }

      LocalLogger().add(
        LocalLog(
          createdAt: DateTime.now(),
          jangdanType: state.selectedJangdan.jangdanType,
        ),
      );
    });

    on<Tick>((event, emit) async {
      var tickState = state;
      var jangdan = tickState.selectedJangdan;
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

      final completedCycle = row == 0 && daebak == 0 && sobak == 0;
      if (completedCycle && tickState.currentSequence != null) {
        if (tickState.skipNextSequenceAdvance) {
          tickState = tickState.copyWith(skipNextSequenceAdvance: false);
        } else {
          tickState = _advanceSequence(tickState);
          jangdan = tickState.selectedJangdan;
          row = 0;
          daebak = 0;
          sobak = 0;
        }
      }

      final accent = jangdan.accents[row][daebak][sobak];
      if (tickState.isSobakOn || sobak == 0) {
        if (accent != Accent.none) {
          SoundManager.play(tickState.currentSound, accent);
        }
      }

      final nextState = tickState.copyWith(
        currentRowIndex: row,
        currentDaebakIndex: daebak,
        currentSobakIndex: sobak,
      );

      emit(nextState);
    });

    on<Stop>((event, emit) {
      if (_playStartTime != null) {
        final duration =
            DateTime.now().difference(_playStartTime!).inMilliseconds;
        final seconds = duration / 1000;
        final roundedDuration = (seconds * 100).round() / 100;
        final jangdanType = state.selectedJangdan.jangdanType.label;
        final jangdanName = state.selectedJangdan.name;

        LocalLogger().add(
          LocalLog(
            createdAt: DateTime.now(),
            jangdanType: state.selectedJangdan.jangdanType,
            playedTime: seconds,
          ),
        );

        analytics.metronomePlay(
          duration: roundedDuration,
          soundType: state.currentSound.label,
          jangdanType: jangdanType,
          jangdanName: jangdanType == jangdanName ? "template" : jangdanName,
        );
        _playStartTime = null;
      }

      _stopPreciseTicker();
      WakelockPlus.disable();
      if (state.currentSequence != null) {
        final first = state.currentSequence!.items.first.jangdan;
        emit(
          state.copyWith(
            isPlaying: false,
            reserveBeatTime: 0,
            currentSequenceIndex: 0,
            currentSequenceRepeat: 1,
            selectedJangdan: first,
            bpm: first.bpm,
            skipNextSequenceAdvance: true,
          ),
        );
      } else {
        emit(state.copyWith(isPlaying: false, reserveBeatTime: 0));
      }
    });

    on<ChangeBpm>((event, emit) {
      add(const StopTapping());
      final newBpm = (state.bpm + event.delta).clamp(1, 300);
      final updated = state.selectedJangdan.copyWith(bpm: newBpm);
      emit(
        _syncCurrentSequenceItem(
          state.copyWith(selectedJangdan: updated, bpm: newBpm),
          updated,
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
        final updatedJangdan = state.selectedJangdan.copyWith(bpm: bpm);

        emit(
          _syncCurrentSequenceItem(
            state.copyWith(
              selectedJangdan: updatedJangdan,
              bpm: bpm,
              isTapping: true,
            ),
            updatedJangdan,
          ),
        );
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
      emit(
        _syncCurrentSequenceItem(
          state.copyWith(selectedJangdan: updatedJangdan),
          updatedJangdan,
        ),
      );
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

  MetronomeState _advanceSequence(MetronomeState current) {
    final sequence = current.currentSequence;
    if (sequence == null || sequence.items.isEmpty) return current;
    final item = sequence.items[current.currentSequenceIndex];

    if (current.currentSequenceRepeat < item.repeatCount) {
      return current.copyWith(
        currentSequenceRepeat: current.currentSequenceRepeat + 1,
        skipNextSequenceAdvance: false,
      );
    }

    final nextIndex =
        (current.currentSequenceIndex + 1) % sequence.items.length;
    final nextJangdan = sequence.items[nextIndex].jangdan;
    return current.copyWith(
      currentSequenceIndex: nextIndex,
      currentSequenceRepeat: 1,
      selectedJangdan: nextJangdan,
      bpm: nextJangdan.bpm,
      skipNextSequenceAdvance: false,
    );
  }

  MetronomeState _syncCurrentSequenceItem(
    MetronomeState current,
    Jangdan updatedJangdan,
  ) {
    final sequence = current.currentSequence;
    if (sequence == null) return current;
    final updatedItems = [...sequence.items];
    final index = current.currentSequenceIndex;
    updatedItems[index] = updatedItems[index].copyWith(jangdan: updatedJangdan);
    return current.copyWith(
      currentSequence: sequence.copyWith(items: updatedItems),
    );
  }
}
