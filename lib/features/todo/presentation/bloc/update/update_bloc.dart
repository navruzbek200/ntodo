import 'package:bloc/bloc.dart';
import 'package:ntodo/features/todo/presentation/bloc/bloc_event.dart';
import 'package:ntodo/features/todo/presentation/bloc/update/update_state.dart';

import '../../../../../core/network/api_error.dart';
import '../../../domain/usecase/update_usecase.dart';

class UpdateBloc extends Bloc<HomeEvent, UpdateState> {
  final UpdateUsecase updateUsecase;

  UpdateBloc(this.updateUsecase) : super(UpdateInitial()) {
    on<UpdateEvent>(_onUpdate);
  }

  Future<void> _onUpdate(
      UpdateEvent event,
      Emitter<UpdateState> emit,
      ) async {
    emit(UpdateLoading());
    try {
      final result = await updateUsecase(
        title: event.title,
        id: event.id,
        completed: false,
      );
      emit(UpdateSuccess(updateEntity: result));
    } catch (e) {
      emit(UpdateError(
        message: apiErrorMessage(e, byStatus: {403: "Bu task sizga tegishli emas."}),
      ));
    }
  }
}
