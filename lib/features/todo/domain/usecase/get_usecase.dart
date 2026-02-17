import 'package:ntodo/features/todo/domain/entities/get_entity.dart';

import '../repository/get_repository.dart';

class GetUsecase {
  final GetRepository getRepository;
  GetUsecase(this.getRepository);

  Future<List<GetEntity>> call() async {
    return await getRepository.getAll();
  }
}
