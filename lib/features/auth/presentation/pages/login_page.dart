import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ntodo/core/di/service_locator.dart';
import 'package:ntodo/core/route/route_names.dart';
import 'package:ntodo/core/theme/app_theme.dart';
import 'package:ntodo/features/auth/presentation/bloc/auth_event.dart';

import 'package:ntodo/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:ntodo/features/auth/presentation/bloc/login/login_state.dart';

import '../widgets/auth_shell.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    context.read<LoginBloc>().add(
      LoginEvent(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginBloc>(),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.home,
              (_) => false,
              arguments: _usernameCtrl.text.trim(),
            );
          } else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: AppPalette.danger, content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return AuthShell(
            title: 'Welcome back',
            subtitle: 'Sign in to see your tasks',
            form: Form(
              key: _formKey,
              child: Column(
                children: [
                  AuthTextField(
                    controller: _usernameCtrl,
                    hint: 'Username',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Username required' : null,
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: _passwordCtrl,
                    hint: 'Password',
                    isPassword: true,
                    validator: (v) => (v == null || v.isEmpty) ? 'Password required' : null,
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    text: 'LOG IN',
                    loading: state is LoginLoading,
                    onPressed: () => _submit(context),
                  ),
                ],
              ),
            ),
            footer: AuthSwitchLink(
              question: 'Not a member?',
              action: 'Register now',
              onTap: () => Navigator.pushReplacementNamed(context, RouteNames.signUp),
            ),
          );
        },
      ),
    );
  }
}
