import 'package:bloc/bloc.dart';
import 'package:ntodo/features/auth/presentation/bloc/auth_event.dart';
import '../../../../../core/network/api_error.dart';
import '../../../domain/usecase/login_usecase.dart';
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
      emit(LoginSuccess(loginEntity: result));
    } catch (e) {
      emit(LoginError(
        message: apiErrorMessage(e, byStatus: {401: "Username yoki parol xato."}),
      ));
    }
  }
}
