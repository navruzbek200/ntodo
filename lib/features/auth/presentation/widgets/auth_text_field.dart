import 'package:flutter/material.dart';

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
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.isPassword;

    return FormField<String>(
      validator: widget.validator,
      builder: (state) {
        final hasError = state.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: widget.controller,
              obscureText: isPassword ? _obscure : false,
              // No length cap: sign-up allows any length, so capping here
              // would lock out users with longer passwords.
              autocorrect: !isPassword,
              enableSuggestions: !isPassword,
              onChanged: (v) => state.didChange(v),
              decoration: InputDecoration(
                counterText: "",
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  color: Color(0xFFB8B8B8),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                // faqat error bo'lsa qizil outline (xohlamasang olib tashlaymiz)
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: hasError ? Colors.redAccent : Colors.transparent,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: hasError ? Colors.redAccent : Theme.of(context).primaryColor,
                    width: 1,
                  ),
                ),
                suffixIcon: isPassword
                    ? IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFFB8B8B8),
                  ),
                )
                    : null,
              ),
            ),

            if (hasError) ...[
              const SizedBox(height: 6),
              Text(
                state.errorText ?? '',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
