
abstract class DeleteState {
  const DeleteState();
}

class DeleteInitial extends DeleteState {}

class DeleteLoading extends DeleteState {}

class DeleteSuccess extends DeleteState {}

class DeleteError extends DeleteState {
  final String message;
  const DeleteError({required this.message});
}
