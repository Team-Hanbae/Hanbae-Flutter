import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hanbae/model/jangdan_category.dart';
import 'package:hanbae/model/jangdan_sequence.dart';
import 'package:hanbae/model/recent_play_item.dart';
import 'package:hanbae/model/saved_jangdan_item.dart';
import '../../data/jangdan_repository.dart';
import '../../data/jangdan_sequence_repository.dart';
import '../../model/jangdan.dart';
import 'package:hanbae/utils/local_storage.dart';
import 'package:hanbae/data/basic_jangdan_data.dart';

part 'jangdan_event.dart';
part 'jangdan_state.dart';

class JangdanBloc extends Bloc<JangdanEvent, JangdanState> {
  final JangdanRepository repository;
  final JangdanSequenceRepository sequenceRepository;
  final Storage storage;

  JangdanBloc(this.repository, this.sequenceRepository, this.storage)
    : super(JangdanInitial()) {
    on<LoadJangdan>(_onLoad);
    on<AddJangdan>(_onAdd);
    on<DeleteJangdan>(_onDelete);
    on<UpdateJangdan>(_onUpdate);
    on<AddJangdanSequence>(_onAddSequence);
    on<UpdateJangdanSequence>(_onUpdateSequence);
    on<DeleteJangdanSequence>(_onDeleteSequence);
    on<ChangeJangdanCategory>(_onChangeJangdanCategory);
  }

  Future<void> _onLoad(LoadJangdan event, Emitter<JangdanState> emit) async {
    final jangdans =
        repository.getAll()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final sequences =
        sequenceRepository.getAll()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final savedItems = <SavedJangdanItem>[
      ...jangdans.map(SavedJangdanItem.custom),
      ...sequences.map(SavedJangdanItem.sequence),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final recentItems = await storage.getRecentPlayItems();

    final recentJangdans = <Jangdan>[];
    final recentSavedItems = <SavedJangdanItem>[];

    for (final item in recentItems) {
      switch (item.kind) {
        case RecentPlayKind.sequence:
          final sequence = _findSequenceByName(sequences, item.name);
          if (sequence != null) {
            recentSavedItems.add(SavedJangdanItem.sequence(sequence));
          }
          break;
        case RecentPlayKind.custom:
          final custom = _findByName(jangdans, item.name);
          if (custom != null) {
            recentJangdans.add(custom);
            recentSavedItems.add(SavedJangdanItem.custom(custom));
          }
          break;
        case RecentPlayKind.builtin:
          final builtIn = basicJangdanData[item.name];
          if (builtIn != null) {
            recentJangdans.add(builtIn);
            recentSavedItems.add(SavedJangdanItem.custom(builtIn));
          }
          break;
      }
    }

    emit(
      (state is JangdanLoaded)
          ? (state as JangdanLoaded).copyWith(
            jangdans: jangdans,
            sequences: sequences,
            savedItems: savedItems,
            recentJangdans: recentJangdans,
            recentItems: recentSavedItems,
          )
          : JangdanLoaded(
            jangdans: jangdans,
            sequences: sequences,
            savedItems: savedItems,
            recentJangdans: recentJangdans,
            recentItems: recentSavedItems,
          ),
    );
  }

  Future<void> _onAdd(AddJangdan event, Emitter<JangdanState> emit) async {
    try {
      if (sequenceRepository.contains(event.jangdan.name.trim())) {
        throw Exception('같은 이름의 장단이 이미 존재합니다: ${event.jangdan.name}');
      }
      await repository.add(event.jangdan.copyWith(createdAt: DateTime.now()));
      add(LoadJangdan());
    } catch (e) {
      emit(JangdanError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteJangdan event,
    Emitter<JangdanState> emit,
  ) async {
    await repository.delete(event.key);
    await Storage().removeRecentJangdan(event.key, kind: RecentPlayKind.custom);
    add(LoadJangdan());
  }

  Future<void> _onUpdate(
    UpdateJangdan event,
    Emitter<JangdanState> emit,
  ) async {
    if (event.key != event.jangdan.name &&
        sequenceRepository.contains(event.jangdan.name.trim())) {
      emit(JangdanError('같은 이름의 장단이 이미 존재합니다: ${event.jangdan.name}'));
      return;
    }
    await repository.update(
      event.key,
      event.jangdan.copyWith(createdAt: DateTime.now()),
    );
    add(LoadJangdan());
  }

  Future<void> _onAddSequence(
    AddJangdanSequence event,
    Emitter<JangdanState> emit,
  ) async {
    try {
      if (repository.contains(event.sequence.name.trim())) {
        throw Exception('같은 이름의 장단이 이미 존재합니다: ${event.sequence.name}');
      }
      await sequenceRepository.add(event.sequence);
      add(LoadJangdan());
    } catch (e) {
      emit(JangdanError(e.toString()));
    }
  }

  Future<void> _onUpdateSequence(
    UpdateJangdanSequence event,
    Emitter<JangdanState> emit,
  ) async {
    try {
      if (event.key != event.sequence.name &&
          repository.contains(event.sequence.name.trim())) {
        throw Exception('같은 이름의 장단이 이미 존재합니다: ${event.sequence.name}');
      }
      await sequenceRepository.update(event.key, event.sequence);
      add(LoadJangdan());
    } catch (e) {
      emit(JangdanError(e.toString()));
    }
  }

  Future<void> _onDeleteSequence(
    DeleteJangdanSequence event,
    Emitter<JangdanState> emit,
  ) async {
    await sequenceRepository.delete(event.key);
    await Storage().removeRecentJangdan(
      event.key,
      kind: RecentPlayKind.sequence,
    );
    add(LoadJangdan());
  }

  void _onChangeJangdanCategory(
    ChangeJangdanCategory event,
    Emitter<JangdanState> emit,
  ) {
    final current = state;
    if (current is JangdanLoaded) {
      emit(current.copyWith(selectedCategory: event.category));
    }
  }

  Jangdan? _findByName(Iterable<Jangdan> list, String name) {
    for (final j in list) {
      if (j.name == name) return j;
    }
    return null;
  }

  JangdanSequence? _findSequenceByName(
    Iterable<JangdanSequence> list,
    String name,
  ) {
    for (final sequence in list) {
      if (sequence.name == name) return sequence;
    }
    return null;
  }
}
