import 'package:ntodo/features/todo/domain/entities/update_entity.dart';
import 'package:ntodo/features/todo/domain/repository/get_repository.dart';

class UpdateUsecase {
  final GetRepository getRepository;
  UpdateUsecase(this.getRepository);

  Future<UpdateEntity> call({
    required int id,
    required String title,
    required bool completed,
  }) {
    return getRepository.toggleCompleted(
      id: id,
      title: title,
      completed: completed,
    );
  }
}
