import 'package:ntodo/features/todo/domain/entities/get_entity.dart';

abstract class GetAllState {
  const GetAllState();
}

class GetAllInitial extends GetAllState {}

class GetAllLoading extends GetAllState {}

class GetAllSuccess extends GetAllState {
  final List<GetEntity> getEntity;

  /// One-shot message when an action on the list (e.g. toggle) failed.
  final String? errorMessage;

  const GetAllSuccess({required this.getEntity, this.errorMessage});
}

class GetAllError extends GetAllState {
  final String message;
  const GetAllError({required this.message});
}
