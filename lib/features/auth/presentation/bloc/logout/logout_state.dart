abstract class LogoutState {
  const LogoutState();
}

class LogoutInitial extends LogoutState {
  const LogoutInitial();
}

class LogoutLoading extends LogoutState {
  const LogoutLoading();
}

class LogoutSuccess extends LogoutState {
  const LogoutSuccess();
}

class LogoutError extends LogoutState {
  final String message;
  const LogoutError({required this.message});
}