import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ntodo/core/di/service_locator.dart';
import 'package:ntodo/core/route/route_names.dart';
import 'package:ntodo/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:ntodo/features/auth/presentation/bloc/register/register_state.dart';

import '../../data/datasource/local/auth_local_remote_datasource.dart';
import '../bloc/auth_event.dart'; // RegisterEvent shu faylda bo'lsa

// sening buttoning
import '../widgets/primary_button.dart';
import '../../../../core/constants/colors.dart'; // AppColors.buttonColor shu yerda bo'lsa

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
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

  InputDecoration _inputDecoration({
    required String hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 15,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.buttonColor, width: 1.2),
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RegisterBloc>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 70),

                    // Title
                    const Text(
                      'Hello!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6C63FF),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'welcome to Ntodo app\nsign up to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6C63FF),
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Form + Bloc
                    Form(
                      key: _formKey,
                      child: BlocConsumer<RegisterBloc, RegisterState>(
                        listener: (context, state) async{
                          if (state is RegisterSuccess) {
                            await sl<AuthLocalRemoteDatasource>().saveCredentials(
                              username: _usernameCtrl.text.trim(),
                              password: _passwordCtrl.text,
                          );

                          Navigator.pushNamedAndRemoveUntil(
                          context,
                          RouteNames.login,
                          (route) => false,
                          );
                          } else if (state is RegisterError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(state.message),
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          final isLoading = state is RegisterLoading;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Username
                              TextFormField(
                                controller: _usernameCtrl,
                                textInputAction: TextInputAction.next,
                                decoration:
                                _inputDecoration(hint: 'Your username'),
                                validator: (v) {
                                  final t = (v ?? '').trim();
                                  if (t.isEmpty) return 'Username kiriting';
                                  if (t.length < 5) return 'Kamida 5 ta belgi';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Password
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                decoration: _inputDecoration(
                                  hint: 'New password',
                                  suffix: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  final t = (v ?? '');
                                  if (t.isEmpty) return 'Password kiriting';
                                  if (t.length < 4) return 'Kamida 4 ta belgi';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              // Terms text
                              RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                      'by signing up you agree to our ',
                                    ),
                                    TextSpan(
                                      text: 'terms & conditions',
                                      style: const TextStyle(
                                        color: Color(0xFF6C63FF),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // TODO: open terms page
                                        },
                                    ),
                                    const TextSpan(text: ' of use and '),
                                    TextSpan(
                                      text: 'privacy policy.',
                                      style: const TextStyle(
                                        color: Color(0xFF6C63FF),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // TODO: open privacy page
                                        },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 26),

                              // Button / Loading
                              if (isLoading)
                                const SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                PrimaryButton(
                                  text: 'SIGN UP',
                                  onPressed: () => _submit(context),
                                ),

                              const SizedBox(height: 18),

                              // Bottom login text
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    children: [
                                      const TextSpan(
                                          text: 'Already have an account? '),
                                      TextSpan(
                                        text: 'LOG IN',
                                        style: const TextStyle(
                                          color: AppColors.buttonColor,
                                          fontWeight: FontWeight.w800,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.pushNamed(
                                              context,
                                              RouteNames.login,
                                            );
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
