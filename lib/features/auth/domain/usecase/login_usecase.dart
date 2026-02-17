import 'package:ntodo/features/auth/domain/entities/login_entity.dart';
import 'package:ntodo/features/auth/domain/repository/auth_repository.dart';

class LoginUsecase {
  final AuthRepository authRepository;
  LoginUsecase(this.authRepository);

  Future<LoginEntity> call({
    required String password,
    required String username,
  }) async {
    return await authRepository.login(password: password, username: username);
  }
}
