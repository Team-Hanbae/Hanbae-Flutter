import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../model/jangdan.dart';

part 'metronome_event.dart';
part 'metronome_state.dart';

class MetronomeBloc extends Bloc<MetronomeEvent, MetronomeState> {
  MetronomeBloc()
    : super(
        MetronomeState(
          selectedJangdan: jinyang,
          isPlaying: false,
          bpm: jinyang.bpm,
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
  }
}
