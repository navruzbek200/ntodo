import 'package:flutter/material.dart';


/// Text field for auth forms; look comes from the app's input theme.
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.validator,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.isPassword;

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: isPassword && _obscure,
      // No length cap: sign-up allows any length, so capping here
      // would lock out users with longer passwords.
      autocorrect: !isPassword,
      enableSuggestions: !isPassword,
      keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.text,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(
          isPassword ? Icons.lock_outline_rounded : Icons.person_outline_rounded,
        ),
        suffixIcon: isPassword
            ? IconButton(
                tooltip: _obscure ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
              )
            : null,
      ),
    );
  }
}
