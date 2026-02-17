import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/colors.dart';
import '../bloc/bloc_event.dart';
import '../bloc/create/create_bloc.dart';
import '../bloc/create/create_state.dart';

/// ✅ Dialog natijasi:
/// true  -> yaratildi
/// null/false -> bekor qilindi
Future<bool?> showAddTaskDialog(
    BuildContext context, {
      String? initialTitle,
    }) {
  return showDialog<bool?>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _AddTaskDialog(initialTitle: initialTitle),
  );
}

class _AddTaskDialog extends StatefulWidget {
  final String? initialTitle;
  const _AddTaskDialog({required this.initialTitle});

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialTitle ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  void _submit() {
    final title = _ctrl.text.trim(); // bu ham String
    context.read<CreateBloc>().add(CreateEvent(title: title));
  }


  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return BlocConsumer<CreateBloc, CreateState>(
      listener: (context, state) {
        if (state is CreateSuccess) {
          Navigator.pop(context, true); // ✅ created
        } else if (state is CreateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final loading = state is CreateLoading;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: viewInsets.bottom),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 26),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 18, color: Color(0xFFB5B5B5)),
                          SizedBox(width: 8),
                          Text(
                            'Add your task',
                            style: TextStyle(
                                color: Color(0xFFB5B5B5), fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: _ctrl,
                        autofocus: true,
                        enabled: !loading,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Text(
                            'Save',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
