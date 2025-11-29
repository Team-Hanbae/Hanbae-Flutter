import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hanbae/model/jangdan_category.dart';
import '../../data/jangdan_repository.dart';
import '../../model/jangdan.dart';

part 'jangdan_event.dart';
part 'jangdan_state.dart';

class JangdanBloc extends Bloc<JangdanEvent, JangdanState> {
  final JangdanRepository repository;

  JangdanBloc(this.repository) : super(JangdanInitial()) {
    on<LoadJangdan>(_onLoad);
    on<AddJangdan>(_onAdd);
    on<DeleteJangdan>(_onDelete);
    on<UpdateJangdan>(_onUpdate);
    on<ChangeJangdanCategory>(_onChangeJangdanCategory);
  }

  void _onLoad(LoadJangdan event, Emitter<JangdanState> emit) {
    final jangdans =
        repository.getAll()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    emit(JangdanLoaded(jangdans: jangdans));
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
      emit(current.copyWith(seletedCategory: event.category));
    }
  }
}
