import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:ntodo/features/auth/domain/usecase/register_usecase.dart';
import 'package:ntodo/features/auth/presentation/bloc/auth_event.dart';
import 'package:ntodo/features/auth/presentation/bloc/register/register_state.dart';

class RegisterBloc extends Bloc<AuthEvent, RegisterState>{
  final RegisterUsecase registerUsecase;

  RegisterBloc(this.registerUsecase):super (RegisterInitial()){
  on<RegisterEvent>(onLogInUser);
  }
  Future<void> onLogInUser(event, emit) async {
    emit(RegisterLoading());
    try {
      final result = await registerUsecase(
        username: event.username,
        password: event.password,


      );
      emit(RegisterSuccess(registerEntity: result));
    } on DioException catch (e) {
      String errorMessage = _mapDioErrorToMessage(e);
      emit(RegisterError( message: errorMessage));
    } catch (e) {
      emit(RegisterError(message: "Noma’lum xato yuz berdi"));
    }
  }

  String _mapDioErrorToMessage(DioException error) {
    if (error.type == DioExceptionType.unknown
        ) {
      return "Internet ulanmagan. Iltimos, tarmoqni tekshiring.";
    } else if (error.response?.statusCode == 400) {
      return "Kiritilgan akkaunt ro'yhatdan o'tgan";
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return "So‘rov vaqtida javob kelmadi. Keyinroq urinib ko‘ring.";
    } else if (error.response?.statusCode == 500) {
      return "Serverda nosozlik bor. Iltimos, keyinroq urinib ko‘ring.";
    }

    return "Noma’lum xato yuz berdi. Iltimos, qayta urinib ko‘ring.";
  }}


