import 'package:bloc/bloc.dart';
import 'package:ntodo/features/todo/domain/usecase/get_usecase.dart';
import 'package:ntodo/features/todo/domain/usecase/update_usecase.dart';
import 'package:ntodo/features/todo/presentation/bloc/bloc_event.dart';
import 'package:ntodo/features/todo/presentation/bloc/get_all/get_all_state.dart';
import '../../../../../core/network/api_error.dart';
import '../../../../../core/untils/logger.dart';

// A 401 is handled globally in DioClinet (session cleared, back to login),
// so this bloc only needs to surface the message.
class GetAllBloc extends Bloc<HomeEvent, GetAllState> {
  final GetUsecase getUsecase;
  final UpdateUsecase updateUsecase;

  GetAllBloc(this.getUsecase, this.updateUsecase) : super(GetAllInitial()) {
    on<GetAllEvent>(_onGetAll);
    on<ToggleTodoEvent>(_onToggle);
  }

  Future<void> _onGetAll(GetAllEvent event, Emitter<GetAllState> emit) async {
    // Keep the current list on screen during pull-to-refresh / reloads.
    if (event.clearCurrent || state is! GetAllSuccess) emit(GetAllLoading());
    try {
      final result = await getUsecase();
      emit(GetAllSuccess(getEntity: result));
    } catch (e) {
      emit(GetAllError(message: apiErrorMessage(e)));
    }
  }

  /// Optimistic toggle: flip locally first, roll back if the server refuses.
  Future<void> _onToggle(ToggleTodoEvent event, Emitter<GetAllState> emit) async {
    final current = state;
    if (current is! GetAllSuccess) return;

    final updatedList = current.getEntity
        .map((t) => t.id == event.id ? t.copyWith(completed: event.value) : t)
        .toList();
    emit(GetAllSuccess(getEntity: updatedList));

    try {
      await updateUsecase(
        id: event.id,
        title: event.title,
        completed: event.value,
      );
    } catch (e) {
      LoggerService.warning('Toggle #${event.id} failed, rolling back');
      emit(GetAllSuccess(
        getEntity: current.getEntity,
        errorMessage: apiErrorMessage(e),
      ));
    }
  }
}
