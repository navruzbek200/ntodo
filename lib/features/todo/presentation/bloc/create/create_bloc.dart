import 'package:bloc/bloc.dart';
import 'package:ntodo/features/todo/domain/usecase/create_usecase.dart';
import 'package:ntodo/features/todo/presentation/bloc/bloc_event.dart';
import 'package:ntodo/features/todo/presentation/bloc/create/create_state.dart';

import '../../../../../core/network/api_error.dart';

class CreateBloc extends Bloc<HomeEvent, CreateState> {
  final CreateUsecase createUsecase;

  CreateBloc(this.createUsecase) : super(CreateInitial()) {
    on<CreateEvent>(_onCreate);
  }

  Future<void> _onCreate(
      CreateEvent event,
      Emitter<CreateState> emit,
      ) async {
    emit(CreateLoading());
    try {
      final result = await createUsecase(title: event.title.trim());
      emit(CreateSuccess(createEntity: result));
    } catch (e) {
      emit(CreateError(message: apiErrorMessage(e)));
    }
  }
}
