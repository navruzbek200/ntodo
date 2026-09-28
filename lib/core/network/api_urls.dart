abstract class ApiUrls {
  // Override per build: flutter run --dart-define=API_BASE_URL=https://api.example.com
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://13.61.184.79:8080',
  );
  static const register = '/register';
  static const login = '/login';
  static const getAll = '/todos';
  static const create = '/todos/create';
  static const update = '/todos/update';
  static const delete = '/todos/delete';
  static const logout = '/logout';

  /// Endpoints that must never carry a token or trigger a forced sign-out.
  static const authFree = {register, login};
}
