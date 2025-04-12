import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hanbae/model/accent.dart';
import '../../model/jangdan.dart';
import '../../data/basic_jangdan_data.dart';

part 'metronome_event.dart';
part 'metronome_state.dart';

class MetronomeBloc extends Bloc<MetronomeEvent, MetronomeState> {
  MetronomeBloc()
    : super(
        MetronomeState(
          selectedJangdan: basicJangdanData["진양"]!,
          isPlaying: false,
          isSobakOn: false,
          bpm: basicJangdanData["진양"]!.bpm,
        ),
      ) {
    on<SelectJangdan>((event, emit) {
      emit(
        state.copyWith(selectedJangdan: event.jangdan, bpm: event.jangdan.bpm),
      );
    });

    on<TogglePlay>((event, emit) {
      emit(state.copyWith(isPlaying: !state.isPlaying));
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
