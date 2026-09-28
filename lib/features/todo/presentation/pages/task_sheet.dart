import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass.dart';
import '../../domain/entities/get_entity.dart';
import '../bloc/bloc_event.dart';
import '../bloc/create/create_bloc.dart';
import '../bloc/create/create_state.dart';
import '../bloc/update/update_bloc.dart';
import '../bloc/update/update_state.dart';

/// Bottom sheet for creating a task, or editing [task] when given.
/// Resolves to true when the server accepted the change.
Future<bool> showTaskSheet(BuildContext context, {GetEntity? task}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: const Color(0x66090614),
    builder: (_) => _GlassSheet(
      child: task == null
          ? BlocProvider(
              create: (_) => sl<CreateBloc>(),
              child: const _CreateSheet(),
            )
          : BlocProvider(
              create: (_) => sl<UpdateBloc>(),
              child: _EditSheet(task: task),
            ),
    ),
  );
  return saved ?? false;
}

class _GlassSheet extends StatelessWidget {
  final Widget child;
  const _GlassSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Glass(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      color: t.surface.withValues(alpha: context.isDark ? 0.82 : 0.9),
      blur: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 14),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: t.checkIdle, borderRadius: BorderRadius.circular(99)),
          ),
          child,
        ],
      ),
    );
  }
}

class _CreateSheet extends StatelessWidget {
  const _CreateSheet();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateBloc, CreateState>(
      listener: (context, state) {
        if (state is CreateSuccess) Navigator.pop(context, true);
      },
      builder: (context, state) => _TaskForm(
        heading: 'New task',
        actionLabel: 'Add task',
        loading: state is CreateLoading,
        error: state is CreateError ? state.message : null,
        onSubmit: (title) => context.read<CreateBloc>().add(CreateEvent(title: title)),
      ),
    );
  }
}

class _EditSheet extends StatelessWidget {
  final GetEntity task;
  const _EditSheet({required this.task});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateBloc, UpdateState>(
      listener: (context, state) {
        if (state is UpdateSuccess) Navigator.pop(context, true);
      },
      builder: (context, state) => _TaskForm(
        heading: 'Edit task',
        actionLabel: 'Save changes',
        initialTitle: task.title,
        loading: state is UpdateLoading,
        error: state is UpdateError ? state.message : null,
        onSubmit: (title) => context.read<UpdateBloc>().add(
              UpdateEvent(id: task.id, title: title, completed: task.completed),
            ),
      ),
    );
  }
}

class _TaskForm extends StatefulWidget {
  final String heading;
  final String actionLabel;
  final String? initialTitle;
  final bool loading;
  final String? error;
  final ValueChanged<String> onSubmit;

  const _TaskForm({
    required this.heading,
    required this.actionLabel,
    required this.loading,
    required this.error,
    required this.onSubmit,
    this.initialTitle,
  });

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  late final _ctrl = TextEditingController(text: widget.initialTitle);
  bool _showEmptyError = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _ctrl.text.trim();
    if (title.isEmpty) {
      setState(() => _showEmptyError = true);
      return;
    }
    if (title == widget.initialTitle) {
      Navigator.pop(context, false);
      return;
    }
    widget.onSubmit(title);
  }

  @override
  Widget build(BuildContext context) {
    final error = _showEmptyError ? 'Please enter a task' : widget.error;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.heading,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            enabled: !widget.loading,
            minLines: 1,
            maxLines: 4,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (_showEmptyError) setState(() => _showEmptyError = false);
            },
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'What do you need to do?',
              errorText: error,
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.loading ? null : _submit,
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                  )
                : Text(widget.actionLabel),
          ),
        ],
      ),
    );
  }
}
