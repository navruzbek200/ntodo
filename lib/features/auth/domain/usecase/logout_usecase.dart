import 'package:ntodo/features/auth/domain/repository/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository authRepository;
  LogoutUsecase(this.authRepository);

  Future<void> call() async {
    return await authRepository.logout();
  }
}
