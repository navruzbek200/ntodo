import 'package:bloc/bloc.dart';
import 'package:ntodo/features/auth/domain/usecase/register_usecase.dart';
import 'package:ntodo/features/auth/presentation/bloc/auth_event.dart';
import 'package:ntodo/features/auth/presentation/bloc/register/register_state.dart';

import '../../../../../core/network/api_error.dart';

class RegisterBloc extends Bloc<AuthEvent, RegisterState> {
  final RegisterUsecase registerUsecase;

  RegisterBloc(this.registerUsecase) : super(RegisterInitial()) {
    on<RegisterEvent>(_onRegister);
  }

  Future<void> _onRegister(
      RegisterEvent event,
      Emitter<RegisterState> emit,
      ) async {
    emit(RegisterLoading());
    try {
      final result = await registerUsecase(
        username: event.username,
        password: event.password,
      );
      emit(RegisterSuccess(registerEntity: result));
    } catch (e) {
      emit(RegisterError(
        message: apiErrorMessage(
          e,
          byStatus: {400: "Bu username band yoki ma’lumot noto‘g‘ri."},
        ),
      ));
    }
  }
}
