import 'package:bloc/bloc.dart';
import 'package:ntodo/features/todo/domain/usecase/delete_usecase.dart';
import 'package:ntodo/features/todo/presentation/bloc/bloc_event.dart';
import 'package:ntodo/features/todo/presentation/bloc/delete/delete_state.dart';

import '../../../../../core/network/api_error.dart';
import '../../../../../core/untils/logger.dart';

class DeleteBloc extends Bloc<HomeEvent, DeleteState> {
  final DeleteUsecase deleteUsecase;

  DeleteBloc(this.deleteUsecase) : super(DeleteInitial()) {
    on<DeleteEvent>(_onDelete);
  }

  /// Deletes every selected id, then reports once: success if all went
  /// through, otherwise the first error (the rest are still attempted).
  Future<void> _onDelete(DeleteEvent event, Emitter<DeleteState> emit) async {
    emit(DeleteLoading());
    Object? firstError;
    var deleted = 0;

    for (final id in event.ids) {
      try {
        await deleteUsecase(id: id);
        deleted++;
      } catch (e) {
        firstError ??= e;
      }
    }

    if (firstError == null) {
      emit(DeleteSuccess(count: deleted));
      return;
    }

    LoggerService.warning('Deleted $deleted of ${event.ids.length} todos');
    emit(DeleteError(
      message: apiErrorMessage(
        firstError,
        byStatus: {403: "Task topilmadi yoki sizga tegishli emas."},
      ),
      deletedCount: deleted,
    ));
  }
}
