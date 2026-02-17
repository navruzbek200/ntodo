import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodo/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:ntodo/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:ntodo/features/todo/presentation/bloc/create/create_bloc.dart';
import 'package:ntodo/features/todo/presentation/bloc/delete/delete_bloc.dart';
import 'package:ntodo/features/todo/presentation/bloc/get_all/get_all_bloc.dart';
import 'package:ntodo/features/todo/presentation/bloc/update/update_bloc.dart';

import 'core/di/service_locator.dart';
import 'features/auth/presentation/bloc/login/login_bloc.dart';

class MyBlocProvider extends StatelessWidget {
  final Widget child;
  const MyBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RegisterBloc>(create: (context) => sl<RegisterBloc>()),
        BlocProvider<LoginBloc>(create: (context) => sl<LoginBloc>()),
        BlocProvider<GetAllBloc>(create: (context) => sl<GetAllBloc>()),
        BlocProvider<CreateBloc>(create: (context) => sl<CreateBloc>()),
        BlocProvider<UpdateBloc>(create: (context) => sl<UpdateBloc>()),
        BlocProvider<DeleteBloc>(create: (context) => sl<DeleteBloc>()),
        BlocProvider<LogoutBloc>(create: (context) => sl<LogoutBloc>()),
      ],
      child: child,
    );
  }
}
