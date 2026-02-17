import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodo/features/todo/presentation/bloc/bloc_event.dart';
import '../../../../core/constants/colors.dart';
import 'package:ntodo/features/todo/presentation/bloc/update/update_bloc.dart';
import 'package:ntodo/features/todo/presentation/bloc/update/update_state.dart';

Future<String?> showEditTaskDialog(
    BuildContext context, {
      required int id,
      required String initialTitle,
    }) {
  return showDialog<String?>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: context.read<UpdateBloc>(),
        child: _EditTaskDialog(id: id, initialTitle: initialTitle),
      );
    },
  );
}

class _EditTaskDialog extends StatefulWidget {
  final int id;
  final String initialTitle;

  const _EditTaskDialog({
    required this.id,
    required this.initialTitle,
  });

  @override
  State<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final v = _ctrl.text.trim();
    if (v.isEmpty) return;

    // ✅ bloc orqali update (completed backendda false bo'ladi)
    context.read<UpdateBloc>().add(
      UpdateEvent( // <-- event nomini o'zingniki bilan almashtir
        id: widget.id,
        title: v,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return BlocListener<UpdateBloc, UpdateState>(
      listener: (context, state) {
        if (state is UpdateSuccess) {
          // ✅ dialog yopiladi va yangi title qaytariladi
          Navigator.pop(context, _ctrl.text.trim());
        }

        if (state is UpdateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BackdropFilter(
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
                          'Edit your task',
                          style: TextStyle(
                              color: Color(0xFFB5B5B5), fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _ctrl,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      decoration:
                      const InputDecoration(border: InputBorder.none),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: BlocBuilder<UpdateBloc, UpdateState>(
                        builder: (context, state) {
                          final loading = state is UpdateLoading;
                          return ElevatedButton(
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
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'Save',
                              style:
                              TextStyle(fontWeight: FontWeight.w700),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}