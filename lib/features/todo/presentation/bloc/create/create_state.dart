import 'package:ntodo/features/todo/domain/entities/create_entity.dart';

abstract class CreateState {
  const CreateState();
}

class CreateInitial extends CreateState {}

class CreateLoading extends CreateState {}

class CreateSuccess extends CreateState {
  final CreateEntity createEntity;

  const CreateSuccess({required this.createEntity});
}

class CreateError extends CreateState {
  final String message;
  const CreateError({required this.message});
}
