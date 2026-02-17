import 'package:ntodo/features/auth/domain/entities/register_entity.dart';

abstract class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final RegisterEntity registerEntity;

  const RegisterSuccess({required this.registerEntity});
}

class RegisterError extends RegisterState {
  final String message;
  const RegisterError({required this.message});
}


