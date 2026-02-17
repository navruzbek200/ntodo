import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:ntodo/features/auth/data/datasource/local/auth_local_remote_datasource.dart';
import 'package:ntodo/features/auth/presentation/bloc/auth_event.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../domain/usecase/Login_usecase.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<AuthEvent, LoginState> {
  final LoginUsecase loginUsecase;

  LoginBloc(this.loginUsecase) : super(LoginInitial()) {
    on<LoginEvent>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginEvent event,
      Emitter<LoginState> emit,
      ) async {
    emit(LoginLoading());
    try {
      final result = await loginUsecase(
        username: event.username,
        password: event.password,
      );
      await sl<AuthLocalRemoteDatasource>().saveAccessToken(result.token);
      emit(LoginSuccess(loginEntity: result));
    } on DioException catch (e) {
      emit(LoginError(message: _mapDioErrorToMessage(e)));
    } catch (_) {
      emit(LoginError(message: "Noma’lum xato yuz berdi"));
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
}
