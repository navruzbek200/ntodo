import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ntodo/features/todo/domain/entities/get_entity.dart';
import 'package:ntodo/features/todo/presentation/bloc/bloc_event.dart';
import 'package:ntodo/features/todo/presentation/bloc/get_all/get_all_bloc.dart';
import 'package:ntodo/features/todo/presentation/bloc/get_all/get_all_state.dart';

import 'package:ntodo/features/todo/presentation/bloc/delete/delete_bloc.dart';
import 'package:ntodo/features/todo/presentation/bloc/delete/delete_state.dart';

import 'package:ntodo/features/auth/presentation/bloc/auth_event.dart';
import 'package:ntodo/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:ntodo/features/auth/presentation/bloc/logout/logout_state.dart';

import '../../../../core/route/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/home_header.dart';
import '../widgets/task_tile.dart';
import 'task_sheet.dart';

class TodoHomePage extends StatefulWidget {
  final String username;

  const TodoHomePage({super.key, required this.username});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  bool _selectMode = false;
  final Set<int> _selectedIds = {};

  /// Swiped away, waiting for the undo window to close (or for the reload
  /// after the server delete). Hidden locally so Dismissible can remove them.
  final Set<int> _hiddenIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetAllBloc>().add(GetAllEvent(clearCurrent: true));
    });
  }

  Future<void> _reload() async => context.read<GetAllBloc>().add(GetAllEvent());

  // ---- selection -----------------------------------------------------------

  void _startSelect(GetEntity task) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectMode = true;
      _selectedIds
        ..clear()
        ..add(task.id);
    });
  }

  void _toggleSelect(GetEntity task) {
    setState(() {
      if (!_selectedIds.remove(task.id)) _selectedIds.add(task.id);
    });
  }

  void _exitSelectMode() {
    setState(() {
      _selectMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _deleteSelected() async {
    final count = _selectedIds.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $count ${count == 1 ? 'task' : 'tasks'}?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppPalette.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final ids = _selectedIds.map((id) => id.toString()).toList();
    _exitSelectMode();
    context.read<DeleteBloc>().add(DeleteEvent(ids: ids));
  }

  // ---- single-task actions -------------------------------------------------

  void _onSwipeDelete(GetEntity task) {
    setState(() => _hiddenIds.add(task.id));

    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger
        .showSnackBar(
          SnackBar(
            content: const Text('Task deleted'),
            duration: const Duration(seconds: 4),
            // With an action Flutter keeps the snackbar open until dismissed,
            // which would postpone the real delete indefinitely.
            persist: false,
            action: SnackBarAction(label: 'Undo', onPressed: () {}),
          ),
        )
        .closed
        .then((reason) {
      if (!mounted) return;
      if (reason == SnackBarClosedReason.action) {
        setState(() => _hiddenIds.remove(task.id));
      } else {
        context.read<DeleteBloc>().add(DeleteEvent(ids: ['${task.id}'], quiet: true));
      }
    });
  }

  void _onTapTask(GetEntity task) {
    if (_selectMode) {
      _toggleSelect(task);
    } else {
      _openSheet(task: task);
    }
  }

  void _onCheck(GetEntity task) {
    HapticFeedback.lightImpact();
    context.read<GetAllBloc>().add(
          ToggleTodoEvent(id: task.id, value: !task.completed, title: task.title),
        );
  }

  Future<void> _openSheet({GetEntity? task}) async {
    final saved = await showTaskSheet(context, task: task);
    if (saved && mounted) _reload();
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can sign in again anytime.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log out')),
        ],
      ),
    );
    if (ok == true && mounted) context.read<LogoutBloc>().add(LogoutEvent());
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppPalette.danger, content: Text(message)),
    );
  }

  // ---- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Gradient header sits under the status bar → light (white) icons.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: MultiBlocListener(
        listeners: [
          BlocListener<DeleteBloc, DeleteState>(
            listener: (context, state) {
              if (state is DeleteSuccess) {
                _reload();
                if (!state.quiet) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${state.count} ${state.count == 1 ? 'task' : 'tasks'} deleted',
                      ),
                    ),
                  );
                }
              }
              if (state is DeleteError) {
                // Some may have been deleted before the failure; show truth.
                setState(_hiddenIds.clear);
                _reload();
                _showError(state.message);
              }
            },
          ),
          BlocListener<LogoutBloc, LogoutState>(
            listener: (context, state) {
              if (state is LogoutSuccess) {
                Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (_) => false);
              }
              if (state is LogoutError) _showError(state.message);
            },
          ),
          BlocListener<GetAllBloc, GetAllState>(
            listener: (context, state) {
              if (state is! GetAllSuccess) return;
              // Forget hidden ids the server no longer returns.
              final alive = state.getEntity.map((t) => t.id).toSet();
              if (_hiddenIds.any((id) => !alive.contains(id))) {
                setState(() => _hiddenIds.removeWhere((id) => !alive.contains(id)));
              }
              // Toggle failed on the server → list was rolled back.
              if (state.errorMessage != null) _showError(state.errorMessage!);
            },
          ),
        ],
        child: PopScope(
          canPop: !_selectMode,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _selectMode) _exitSelectMode();
          },
          child: Scaffold(
            floatingActionButton: _selectMode
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => _openSheet(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New task'),
                  ),
            body: BlocBuilder<GetAllBloc, GetAllState>(
              builder: (context, state) {
                final tasks = state is GetAllSuccess
                    ? state.getEntity.where((t) => !_hiddenIds.contains(t.id)).toList()
                    : const <GetEntity>[];

                return RefreshIndicator(
                  onRefresh: _reload,
                  edgeOffset: 120,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: BlocBuilder<LogoutBloc, LogoutState>(
                          builder: (context, logoutState) => HomeHeader(
                            username: widget.username.trim(),
                            total: tasks.length,
                            done: tasks.where((t) => t.completed).length,
                            selecting: _selectMode,
                            selectedCount: _selectedIds.length,
                            loggingOut: logoutState is LogoutLoading,
                            onLogout: _confirmLogout,
                            onCloseSelect: _exitSelectMode,
                            onDeleteSelected: _deleteSelected,
                          ),
                        ),
                      ),
                      ..._content(state, tasks),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(GetAllState state, List<GetEntity> tasks) {
    if (state is GetAllInitial || state is GetAllLoading) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (state is GetAllError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _Message(
            icon: const Icon(Icons.cloud_off_rounded, size: 56, color: AppPalette.muted),
            title: "Couldn't load your tasks",
            subtitle: state.message,
            action: OutlinedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ),
        ),
      ];
    }

    if (tasks.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _Message(
            icon: SvgPicture.asset('assets/icons/no_todo.svg', width: 140, height: 140),
            title: 'No tasks yet',
            subtitle: 'Tap “New task” to add your first one.',
          ),
        ),
      ];
    }

    final active = tasks.where((t) => !t.completed).toList();
    final done = tasks.where((t) => t.completed).toList();

    return [
      if (active.isNotEmpty) ...[
        _SectionTitle('To do', active.length),
        _taskList(active),
      ],
      if (done.isNotEmpty) ...[
        _SectionTitle('Completed', done.length),
        _taskList(done),
      ],
      const SliverToBoxAdapter(child: SizedBox(height: 110)),
    ];
  }

  Widget _taskList(List<GetEntity> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final task = items[i];
          return Dismissible(
            key: ValueKey('task-${task.id}'),
            direction: _selectMode ? DismissDirection.none : DismissDirection.endToStart,
            onDismissed: (_) => _onSwipeDelete(task),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: AppPalette.danger,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
            ),
            child: TaskTile(
              title: task.title,
              checked: task.completed,
              selecting: _selectMode,
              selected: _selectedIds.contains(task.id),
              onCheck: () => _onCheck(task),
              onTap: () => _onTapTask(task),
              onLongPress: () => _selectMode ? _toggleSelect(task) : _startSelect(task),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;
  const _SectionTitle(this.title, this.count);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE9E4F7),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.brand,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const _Message({required this.icon, required this.title, required this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 110),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppPalette.muted, height: 1.5),
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}
