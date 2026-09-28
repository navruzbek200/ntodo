// End-to-end check of the app's data layer against the real backend,
// running on a real Android device/emulator (so network security config and
// permissions are exercised too):
//   flutter test integration_test/backend_e2e_test.dart -d <device-id>

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ntodo/core/network/api_error.dart';
import 'package:ntodo/core/network/dio_clinet.dart';
import 'package:ntodo/core/storage/local_storage.dart';
import 'package:ntodo/features/auth/data/datasource/local/auth_local_datasource.dart';
import 'package:ntodo/features/auth/data/datasource/remote/user_remote_datasource_impl.dart';
import 'package:ntodo/features/todo/data/data_source/remote_datasource_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AuthLocalDataSourceImpl local;
  late UserRemoteDatasourceImpl auth;
  late GetRemoteDatasourceImpl todos;
  var unauthorizedCalls = 0;

  final username = 'e2e_${DateTime.now().millisecondsSinceEpoch}';
  const password = 'E2ePass123';

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'password': 'legacy-plaintext'});
    final prefs = await SharedPreferences.getInstance();
    local = AuthLocalDataSourceImpl(LocalStorage(prefs));
    final dio = DioClinet(local: local, onUnauthorized: () => unauthorizedCalls++);
    auth = UserRemoteDatasourceImpl(dioClient: dio, local: local);
    todos = GetRemoteDatasourceImpl(dioClient: dio);
  });

  Future<int> statusOf(Future<Object?> call) async {
    try {
      await call;
      return 0;
    } on DioException catch (e) {
      return e.response?.statusCode ?? -1;
    }
  }

  test('legacy plaintext password is wiped on start', () async {
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('password'), isNull);
  });

  test('register → duplicate register fails with 400', () async {
    final res = await auth.register(username: username, password: password);
    expect(res.message, isNotEmpty);

    expect(await statusOf(auth.register(username: username, password: password)), 400);
  });

  test('login with wrong password → 401, no token, no forced sign-out', () async {
    expect(await statusOf(auth.login(username: username, password: 'wrong')), 401);
    expect(local.isLoggedIn(), isFalse);
    expect(unauthorizedCalls, 0);
  });

  test('login stores token + username', () async {
    final res = await auth.login(username: username, password: password);
    expect(res.token, isNotEmpty);
    expect(local.getAccessToken(), res.token);
    expect(local.getUsername(), username);
  });

  test('full CRUD cycle', () async {
    expect(await todos.getAll(), isEmpty, reason: 'backend sends null → []');

    final created = await todos.create(title: 'e2e task');
    expect(created.title, 'e2e task');

    var list = await todos.getAll();
    expect(list, hasLength(1));
    final id = list.single.id;
    expect(list.single.completed, isFalse);

    final toggled = await todos.toggleCompleted(id: id, title: 'e2e task', completed: true);
    expect(toggled.completed, isTrue);

    final edited = await todos.update(id: id, title: 'e2e edited');
    expect(edited.title, 'e2e edited');
    list = await todos.getAll();
    expect(list.single.title, 'e2e edited');
    expect(list.single.completed, isFalse);

    await todos.delete(id: '$id');
    expect(await todos.getAll(), isEmpty);

    // Deleting again: backend says 403 "not found or no access".
    expect(await statusOf(todos.delete(id: '$id')), 403);
  });

  test('empty title is rejected with a readable message', () async {
    try {
      await todos.create(title: '');
      fail('expected 400');
    } on DioException catch (e) {
      expect(e.response?.statusCode, 400);
      expect(apiErrorMessage(e), contains('noto‘g‘ri'));
    }
  });

  test('logout clears session; stale token → global sign-out hook', () async {
    final staleToken = local.getAccessToken()!;
    await auth.logout();
    expect(local.isLoggedIn(), isFalse);
    expect(local.getUsername(), isNull);

    // Simulate a device still holding the revoked token.
    await local.saveAccessToken(staleToken);
    expect(await statusOf(todos.getAll()), 401);
    expect(unauthorizedCalls, 1);
    expect(local.isLoggedIn(), isFalse, reason: 'interceptor must clear it');
  });

  test('logout still clears local session when the server rejects it', () async {
    await local.saveAccessToken('garbage-token');
    await auth.logout(); // server answers 401 – must not throw
    expect(local.isLoggedIn(), isFalse);
  });
}
