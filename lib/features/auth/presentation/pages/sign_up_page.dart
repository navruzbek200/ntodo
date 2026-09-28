import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ntodo/core/constants/links.dart';
import 'package:ntodo/core/di/service_locator.dart';
import 'package:ntodo/core/route/route_names.dart';
import 'package:ntodo/core/theme/app_theme.dart';
import 'package:ntodo/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:ntodo/features/auth/presentation/bloc/register/register_state.dart';

import '../bloc/auth_event.dart';
import '../widgets/auth_shell.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late final _privacyTap = TapGestureRecognizer()
    ..onTap = () => AppLinks.open(AppLinks.privacyPolicy);

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    context.read<RegisterBloc>().add(
      RegisterEvent(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return BlocProvider(
      create: (_) => sl<RegisterBloc>(),
      child: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created – please log in')),
            );
            Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (_) => false);
          } else if (state is RegisterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: AppPalette.danger, content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return AuthShell(
            title: 'Create account',
            subtitle: 'Start organizing your day with Ntodo',
            form: Form(
              key: _formKey,
              child: Column(
                children: [
                  AuthTextField(
                    controller: _usernameCtrl,
                    hint: 'Username',
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Username required';
                      if (s.length < 5) return 'At least 5 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: _passwordCtrl,
                    hint: 'Password',
                    isPassword: true,
                    validator: (v) {
                      final s = v ?? '';
                      if (s.isEmpty) return 'Password required';
                      if (s.length < 4) return 'At least 4 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 13, color: t.muted, height: 1.5),
                      children: [
                        const TextSpan(text: 'By signing up you agree to our '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(color: t.checkOn, fontWeight: FontWeight.w600),
                          recognizer: _privacyTap,
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    text: 'SIGN UP',
                    loading: state is RegisterLoading,
                    onPressed: () => _submit(context),
                  ),
                ],
              ),
            ),
            footer: AuthSwitchLink(
              question: 'Already have an account?',
              action: 'Log in',
              onTap: () => Navigator.pushReplacementNamed(context, RouteNames.login),
            ),
          );
        },
      ),
    );
  }
}
