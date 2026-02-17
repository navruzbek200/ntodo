import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:ntodo/features/auth/domain/usecase/logout_usecase.dart';
import 'package:ntodo/features/auth/presentation/bloc/auth_event.dart';
import 'package:ntodo/features/auth/presentation/bloc/logout/logout_state.dart';

class LogoutBloc extends Bloc<AuthEvent, LogoutState> {
  final LogoutUsecase logoutUsecase;

  LogoutBloc(this.logoutUsecase) : super(const LogoutInitial()) {
    on<LogoutEvent>(_onLogoutSubmitted);
  }

  Future<void> _onLogoutSubmitted(
      LogoutEvent event,
      Emitter<LogoutState> emit,
      ) async {
    emit(const LogoutLoading());
    try {
      await logoutUsecase();
      emit(const LogoutSuccess());
    } on DioException catch (e) {
      emit(LogoutError(message: _mapDioErrorToMessage(e)));
    } catch (_) {
      emit(const LogoutError(message: "Noma’lum xato yuz berdi"));
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
    if (code == 400) return "So‘rov noto‘g‘ri.";
    if (code == 401) return "Token eskirgan yoki login qiling.";
    if (code == 500) return "Serverda nosozlik bor. Keyinroq urinib ko‘ring.";

    return "Noma’lum xato yuz berdi. Iltimos, qayta urinib ko‘ring.";
  }
}