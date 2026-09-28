
abstract class DeleteState {
  const DeleteState();
}

class DeleteInitial extends DeleteState {}

class DeleteLoading extends DeleteState {}

class DeleteSuccess extends DeleteState {
  final int count;
  const DeleteSuccess({required this.count});
}

class DeleteError extends DeleteState {
  final String message;
  final int deletedCount;
  const DeleteError({required this.message, this.deletedCount = 0});
}
