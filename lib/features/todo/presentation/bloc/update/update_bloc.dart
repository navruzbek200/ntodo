import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:ntodo/features/todo/presentation/bloc/bloc_event.dart';
import 'package:ntodo/features/todo/presentation/bloc/update/update_state.dart';

import '../../../domain/usecase/update_usecase.dart';

class UpdateBloc extends Bloc<HomeEvent, UpdateState> {
  final UpdateUsecase updateUsecase;

  UpdateBloc(this.updateUsecase) : super(UpdateInitial()) {
    on <UpdateEvent>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
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
    } on DioException catch (e) {
      emit(UpdateError(message: _mapDioErrorToMessage(e)));
    } catch (_) {
      emit(UpdateError(message: "Noma’lum xato yuz berdi"));
    }
  }

  }

  String _mapDioErrorToMessage(DioException error) {
    if (error.type == DioExceptionType.unknown) {
      return "Internet ulanmagan. Iltimos, tarmoqni tekshiring.";
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return "So‘rov vaqtida javob kelmadi. Keyinroq urinib ko‘ring.";
    }

    final code = error.response?.statusCode;
    if (code == 400) return "Kiritilgan ma’lumotlar noto‘g‘ri.";
    if (code == 401) return "Username yoki parol xato.";
    if (code == 500) return "Serverda nosozlik bor. Keyinroq urinib ko‘ring.";

    return "Noma’lum xato yuz berdi. Iltimos, qayta urinib ko‘ring.";
  }

