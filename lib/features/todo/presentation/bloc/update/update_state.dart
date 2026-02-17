import 'package:ntodo/features/todo/domain/entities/update_entity.dart';

abstract class UpdateState {
  const UpdateState();
}

class UpdateInitial extends UpdateState {}

class UpdateLoading extends UpdateState {}

class UpdateSuccess extends UpdateState {
  final UpdateEntity updateEntity;

  const UpdateSuccess({required this.updateEntity});
}

class UpdateError extends UpdateState {
  final String message;
  const UpdateError({required this.message});
}
