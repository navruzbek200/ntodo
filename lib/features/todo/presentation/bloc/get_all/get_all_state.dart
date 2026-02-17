import 'package:ntodo/features/todo/domain/entities/get_entity.dart';

abstract class GetAllState {
  const GetAllState();
}

class GetAllInitial extends GetAllState {}

class GetAllLoading extends GetAllState {}

class GetAllSuccess extends GetAllState {
  final List<GetEntity> getEntity;

  const GetAllSuccess({required this.getEntity});
}

class GetAllError extends GetAllState {
  final String message;
  const GetAllError({required this.message});
}
