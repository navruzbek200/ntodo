abstract class AuthEvent {
  const AuthEvent();
}

class RegisterEvent extends AuthEvent {
  final String password;
  final String username;

  RegisterEvent({required this.username, required this.password});
}

class LoginEvent extends AuthEvent {
  final String password;
  final String username;

  LoginEvent({required this.username, required this.password});
}

class LogoutEvent extends AuthEvent {

}
