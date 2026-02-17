import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:ntodo/features/todo/domain/usecase/delete_usecase.dart';
import 'package:ntodo/features/todo/presentation/bloc/bloc_event.dart';
import 'package:ntodo/features/todo/presentation/bloc/delete/delete_state.dart';


class DeleteBloc extends Bloc<HomeEvent, DeleteState> {
  final DeleteUsecase deleteUsecase;


  DeleteBloc(this.deleteUsecase,)
      : super(DeleteInitial()) {
    on<DeleteEvent>(_onDelete);
  }

  // GET ALL
  Future<void> _onDelete(DeleteEvent event,
      Emitter<DeleteState> emit,) async {
    emit(DeleteLoading());
    try {
      await deleteUsecase(id: event.id);
      emit(DeleteSuccess());
    } on DioException catch (e) {
      emit(DeleteError(message: _mapDioErrorToMessage(e)));
    } catch (_) {
      emit(DeleteError(message: "Noma’lum xato yuz berdi"));
    }
  }
}

  String _mapDioErrorToMessage(DioException error) {
    if (error.type == DioExceptionType.unknown) {
      return "Internet ulanmagan.";
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return "So‘rov vaqtida javob kelmadi.";
    }

    final code = error.response?.statusCode;
    if (code == 400) return "Ma’lumot noto‘g‘ri.";
    if (code == 401) return "Authorization xato.";
    if (code == 500) return "Server xatosi.";

    return "Noma’lum xato.";
  }
