import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hanbae/model/jangdan_category.dart';
import '../../data/jangdan_repository.dart';
import '../../model/jangdan.dart';
import 'package:hanbae/utils/local_storage.dart';
import 'package:hanbae/data/basic_jangdan_data.dart';

part 'jangdan_event.dart';
part 'jangdan_state.dart';

class JangdanBloc extends Bloc<JangdanEvent, JangdanState> {
  final JangdanRepository repository;
  final Storage storage;

  JangdanBloc(this.repository, this.storage) : super(JangdanInitial()) {
    on<LoadJangdan>(_onLoad);
    on<AddJangdan>(_onAdd);
    on<DeleteJangdan>(_onDelete);
    on<UpdateJangdan>(_onUpdate);
    on<ChangeJangdanCategory>(_onChangeJangdanCategory);
  }

  Future<void> _onLoad(LoadJangdan event, Emitter<JangdanState> emit) async {
    final jangdans =
        repository.getAll()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final recentNames = await storage.getRecentJangdanNames();

    final recentJangdans = <Jangdan>[];

    for (final name in recentNames) {
      final custom = _findByName(jangdans, name);
      if (custom != null) {
        recentJangdans.add(custom);
        continue;
      }

      final builtIn = basicJangdanData[name];
      if (builtIn != null) {
        recentJangdans.add(builtIn);
      }
    }

    emit(JangdanLoaded(jangdans: jangdans, recentJangdans: recentJangdans));
  }

  Future<void> _onAdd(AddJangdan event, Emitter<JangdanState> emit) async {
    try {
      await repository.add(event.jangdan..copyWith(createdAt: DateTime.now()));
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
    add(LoadJangdan());
  }

  Future<void> _onUpdate(
    UpdateJangdan event,
    Emitter<JangdanState> emit,
  ) async {
    await repository.update(
      event.key,
      event.jangdan..copyWith(createdAt: DateTime.now()),
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
}
