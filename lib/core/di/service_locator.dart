import 'package:get_it/get_it.dart';
import 'package:ntodo/core/network/dio_clinet.dart';
import 'package:ntodo/features/auth/domain/usecase/logout_usecase.dart';
import 'package:ntodo/features/auth/domain/usecase/register_usecase.dart';
import 'package:ntodo/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:ntodo/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:ntodo/features/todo/data/data_source/remote_datasource.dart';
import 'package:ntodo/features/todo/data/data_source/remote_datasource_impl.dart';
import 'package:ntodo/features/todo/data/repository/get_repository_impl.dart';
import 'package:ntodo/features/todo/domain/repository/get_repository.dart';
import 'package:ntodo/features/todo/domain/usecase/create_usecase.dart';
import 'package:ntodo/features/todo/domain/usecase/delete_usecase.dart';
import 'package:ntodo/features/todo/domain/usecase/get_usecase.dart';
import 'package:ntodo/features/todo/domain/usecase/update_usecase.dart';
import 'package:ntodo/features/todo/presentation/bloc/create/create_bloc.dart';
import 'package:ntodo/features/todo/presentation/bloc/delete/delete_bloc.dart';
import 'package:ntodo/features/todo/presentation/bloc/get_all/get_all_bloc.dart';
import 'package:ntodo/features/todo/presentation/bloc/update/update_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasource/local/auth_local_datasource.dart';
import '../../features/auth/domain/usecase/login_usecase.dart';
import '../route/app_navigator.dart';
import '../storage/local_storage.dart';

import '../../features/auth/data/datasource/local/auth_local_remote_datasource.dart';
import '../../features/auth/data/datasource/remote/user_remote_datasource.dart';
import '../../features/auth/data/datasource/remote/user_remote_datasource_impl.dart';
import '../../features/auth/data/repository/auth_repository_impl.dart';
import '../../features/auth/domain/repository/auth_repository.dart';

import '../../features/auth/presentation/bloc/register/register_bloc.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  if (sl.isRegistered<AuthRepository>()) return;

  // prefs + storage
  final prefs = await SharedPreferences.getInstance();
  final storage = LocalStorage(prefs);

// ✅ Local DS
  sl.registerLazySingleton<AuthLocalRemoteDatasource>(
        () => AuthLocalDataSourceImpl(storage),
  );

// ✅ DioClinet
  sl.registerLazySingleton<DioClinet>(
        () => DioClinet(
          local: sl<AuthLocalRemoteDatasource>(),
          onUnauthorized: goToLoginClearingStack,
        ),
  );


// ✅ Remote DS
  sl.registerLazySingleton<UserRemoteDatasource>(
        () => UserRemoteDatasourceImpl(dioClient: sl<DioClinet>(), local: sl()),
  );

  sl.registerLazySingleton<GetRemoteDatasource>(
        () => GetRemoteDatasourceImpl(dioClient: sl<DioClinet>(),),
  );

// ✅ Repo
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(userRemoteDatasource: sl<UserRemoteDatasource>()),
  );

  sl.registerLazySingleton<GetRepository>(
        () => GetRepositoryImpl(getRemoteDatasource: sl<GetRemoteDatasource>()),
  );

// ✅ Usecase
  sl.registerLazySingleton<RegisterUsecase>(
        () => RegisterUsecase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<LoginUsecase>(
        () => LoginUsecase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<LogoutUsecase>(
        () => LogoutUsecase(sl<AuthRepository>()),
  );


  sl.registerLazySingleton<GetUsecase>(
        () => GetUsecase(sl<GetRepository>()),
  );

    sl.registerLazySingleton<CreateUsecase>(
        () => CreateUsecase(sl<GetRepository>()),
  );

  sl.registerLazySingleton<UpdateUsecase>(
        () => UpdateUsecase(sl<GetRepository>()),
  );

  sl.registerLazySingleton<DeleteUsecase>(
        () => DeleteUsecase(sl<GetRepository>()),
  );


// ✅ Bloc
  sl.registerFactory<RegisterBloc>(
        () => RegisterBloc(sl<RegisterUsecase>()),
  );

  sl.registerFactory<LoginBloc>(
        () => LoginBloc(sl<LoginUsecase>()),
  );


  sl.registerFactory<GetAllBloc>(
        () => GetAllBloc(sl<GetUsecase>(),  sl<UpdateUsecase>(),),
  );

  sl.registerFactory<CreateBloc>(
        () => CreateBloc(sl<CreateUsecase>()),
  );

  sl.registerFactory<UpdateBloc>(
        () => UpdateBloc(sl<UpdateUsecase>()),
  );

  sl.registerFactory<DeleteBloc>(
        () => DeleteBloc(sl<DeleteUsecase>()),
  );

  sl.registerFactory<LogoutBloc>(
        () => LogoutBloc(sl<LogoutUsecase>()),
  );





  }
