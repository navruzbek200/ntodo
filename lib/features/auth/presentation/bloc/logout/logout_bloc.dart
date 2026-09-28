import 'package:bloc/bloc.dart';
import 'package:ntodo/features/auth/domain/usecase/logout_usecase.dart';
import 'package:ntodo/features/auth/presentation/bloc/auth_event.dart';
import 'package:ntodo/features/auth/presentation/bloc/logout/logout_state.dart';

import '../../../../../core/network/api_error.dart';

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
    } catch (e) {
      emit(LogoutError(message: apiErrorMessage(e)));
    }
  }
}
