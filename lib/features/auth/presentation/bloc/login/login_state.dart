import '../../../domain/entities/login_entity.dart';

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginEntity loginEntity;

  const LoginSuccess({required this.loginEntity});
}

class LoginError extends LoginState {
  final String message;
  const LoginError({required this.message});
}
