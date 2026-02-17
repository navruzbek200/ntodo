import 'package:ntodo/features/todo/domain/entities/create_entity.dart';
import 'package:ntodo/features/todo/domain/repository/get_repository.dart';

class CreateUsecase {
  final GetRepository getRepository;
  CreateUsecase(this.getRepository);

  Future<CreateEntity> call({
    required String title
  }) async {
    return await getRepository.create(title: title);
  }
}
