import 'package:ntodo/features/auth/domain/entities/register_entity.dart';
import 'package:ntodo/features/auth/domain/repository/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository authRepository;
  RegisterUsecase(this.authRepository);

  Future<RegisterEntity> call({
    required String password,
    required String username,
  }) async {
    return await authRepository.register(
      password: password,
      username: username,
    );
  }
}
