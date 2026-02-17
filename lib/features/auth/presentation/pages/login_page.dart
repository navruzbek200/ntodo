import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ntodo/core/constants/colors.dart';
import 'package:ntodo/core/di/service_locator.dart';
import 'package:ntodo/core/route/route_names.dart';
import 'package:ntodo/features/auth/presentation/bloc/auth_event.dart';

import 'package:ntodo/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:ntodo/features/auth/presentation/bloc/login/login_state.dart';

import '../../data/datasource/local/auth_local_remote_datasource.dart';
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
      child: Builder(
        builder: (context) {
          final primary = AppColors.buttonColor;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Form(
                  key: _formKey,
                  child: BlocConsumer<LoginBloc, LoginState>(
                    listener: (context, state) async {
                      if (state is LoginSuccess) {
                        await sl<AuthLocalRemoteDatasource>().saveCredentials(
                          username: _usernameCtrl.text.trim(),
                          password: _passwordCtrl.text,
                        );

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          RouteNames.home,
                              (_) => false,
                          arguments: _usernameCtrl.text.trim(),
                        );
                      } else if (state is LoginError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(state.message),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is LoginLoading;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 110),

                          Text(
                            "Hello Again!",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 14,
                              color: primary.withOpacity(0.8),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // ✅ username
                          AuthTextField(
                            controller: _usernameCtrl,
                            hint: "Enter your username",
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "Username required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // ✅ password
                          AuthTextField(
                            controller: _passwordCtrl,
                            hint: "Password",
                            isPassword: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "Password required";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 30),

                          if (isLoading)
                            const SizedBox(
                              height: 60,
                              child: Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            )
                          else
                            PrimaryButton(
                              text: "LOG IN",
                              onPressed: () => _submit(context),
                            ),

                          const SizedBox(height: 18),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Not a member? ",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacementNamed(
                                  context,
                                  RouteNames.signUp,
                                ),
                                child: const Text(
                                  "Register now",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF5B4DB7),
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
