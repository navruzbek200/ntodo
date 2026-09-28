
abstract class DeleteState {
  const DeleteState();
}

class DeleteInitial extends DeleteState {}

class DeleteLoading extends DeleteState {}

class DeleteSuccess extends DeleteState {
  final int count;
  final bool quiet;
  const DeleteSuccess({required this.count, this.quiet = false});
}

class DeleteError extends DeleteState {
  final String message;
  final int deletedCount;
  const DeleteError({required this.message, this.deletedCount = 0});
}
