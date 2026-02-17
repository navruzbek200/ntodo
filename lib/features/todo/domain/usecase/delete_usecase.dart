import 'package:ntodo/features/todo/domain/repository/get_repository.dart';

class DeleteUsecase {
  final GetRepository getRepository;
  DeleteUsecase(this.getRepository);

  Future<void> call({
    required String id
  }) async {
    return await getRepository.delete(id: id);
  }
}
