import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:ntodo/features/todo/domain/usecase/create_usecase.dart';
import 'package:ntodo/features/todo/presentation/bloc/bloc_event.dart';
import 'package:ntodo/features/todo/presentation/bloc/create/create_state.dart';

class CreateBloc extends Bloc<HomeEvent, CreateState> {
  final CreateUsecase createUsecase;

  CreateBloc(this.createUsecase) : super(CreateInitial()) {
    on <CreateEvent>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
      CreateEvent event,
      Emitter<CreateState> emit,
      ) async {
    event.title.trim();
    emit(CreateLoading());
    try {
      final result = await createUsecase(
        title: event.title,
      );
      emit(CreateSuccess(createEntity: result));
    } on DioException catch (e) {
      emit(CreateError(message: _mapDioErrorToMessage(e)));
    } catch (_) {
      emit(CreateError(message: "Noma’lum xato yuz berdi"));
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
