import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ntodo/features/todo/domain/entities/get_entity.dart';
import 'package:ntodo/features/todo/presentation/bloc/bloc_event.dart';
import 'package:ntodo/features/todo/presentation/bloc/get_all/get_all_bloc.dart';
import 'package:ntodo/features/todo/presentation/bloc/get_all/get_all_state.dart';

import 'package:ntodo/features/todo/presentation/bloc/delete/delete_bloc.dart';
import 'package:ntodo/features/todo/presentation/bloc/delete/delete_state.dart';

import 'package:ntodo/features/auth/presentation/bloc/auth_event.dart';
import 'package:ntodo/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:ntodo/features/auth/presentation/bloc/logout/logout_state.dart';

import '../../../../core/constants/links.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/route/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../core/widgets/spotlight_tour.dart';
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
  static const _tourDoneKey = 'home_tour_done_v1';

  bool _selectMode = false;
  final Set<int> _selectedIds = {};

  /// Swiped away, waiting for the undo window to close (or for the reload
  /// after the server delete). Hidden locally so Dismissible can remove them.
  final Set<int> _hiddenIds = {};

  // ---- first-run tutorial state ----
  static const _samples = [
    '💪 Do 20 push-ups',
    '📚 Read 10 pages of a book',
    '📝 Finish my homework',
    '💧 Drink a glass of water',
    '🚶 Take a 15-minute walk',
    '🧘 Stretch for 5 minutes',
  ];
  final _tour = TourController();
  final _fabKey = GlobalKey();
  final _tutorialTileKey = GlobalKey();
  final _tutorialCheckKey = GlobalKey();
  final _progressKey = GlobalKey();
  final _themeKey = GlobalKey();
  bool _tourScheduled = false;
  String _suggestion = _samples.first;

  /// Title the user saved during the tutorial; we look it up after reload.
  String? _tutorialTitle;
  int? _tutorialTaskId;

  @override
  void initState() {
    super.initState();
    _tour.onFinish = _onTourFinished;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetAllBloc>().add(GetAllEvent(clearCurrent: true));
    });
  }

  @override
  void dispose() {
    _tour.dispose();
    super.dispose();
  }

  Future<void> _reload() async => context.read<GetAllBloc>().add(GetAllEvent());

  // ---- onboarding tour -----------------------------------------------------

  void _maybeStartTour() {
    if (_tour.active || _tourScheduled) return;
    if (sl<SharedPreferences>().getBool(_tourDoneKey) ?? false) return;
    _tourScheduled = true;
    // Let the list's entrance animation settle so spotlights land correctly.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _startTour();
    });
  }

  void _onTourFinished() {
    sl<SharedPreferences>().setBool(_tourDoneKey, true);
    _tourScheduled = false;
    if (mounted) {
      setState(() {
        _tutorialTitle = null;
        _tutorialTaskId = null;
      });
    }
  }

  /// Advance from an interactive step after the UI has settled.
  void _advanceFrom(String stepId, Duration delay) {
    _tour.suspend();
    Future.delayed(delay, () {
      if (mounted && _tour.isAt(stepId)) _tour.next();
    });
  }

  /// Hands-on tutorial: the user creates a sample task, completes it and
  /// swipes it away, then gets two quick tips. Any step can be skipped.
  void _startTour() {
    if (_tour.active || _selectMode) return;
    _suggestion = _samples[math.Random().nextInt(_samples.length)];
    _tutorialTitle = null;
    _tutorialTaskId = null;
    _tour.start([
      TourStep(
        id: 'create',
        target: _fabKey,
        icon: Icons.add_task_rounded,
        title: "Let's add a task",
        body:
            'Tap “New task” – we’ll suggest one so you can try it right away.',
        gesture: TourGesture.tap,
        interactive: true,
      ),
      TourStep(
        id: 'complete',
        target: _tutorialCheckKey,
        icon: Icons.check_circle_outline_rounded,
        title: 'Now tick it off',
        body: 'Done with it? Tap the circle to mark the task as completed.',
        gesture: TourGesture.tap,
        interactive: true,
        radius: 30,
        inflate: const EdgeInsets.all(4),
      ),
      TourStep(
        id: 'swipe',
        target: _tutorialTileKey,
        icon: Icons.swipe_left_rounded,
        title: 'Swipe to delete',
        body:
            'Swipe the task to the left to remove it. You can undo for a few seconds.',
        gesture: TourGesture.swipeLeft,
        interactive: true,
      ),
      TourStep(
        id: 'progress',
        target: _progressKey,
        icon: Icons.insights_rounded,
        title: 'Your daily progress',
        body:
            'Completed tasks fill this bar – reach 100% for a little celebration 🎉',
        radius: 22,
      ),
      TourStep(
        id: 'theme',
        target: _themeKey,
        icon: Icons.dark_mode_rounded,
        title: 'Make it yours',
        body:
            'Switch between light and dark here. Tip: press and hold a task to select '
            'several. Replay this tour from the ⋮ menu.',
        radius: 26,
        inflate: const EdgeInsets.all(2),
      ),
    ]);
  }

  // ---- selection -----------------------------------------------------------

  void _startSelect(GetEntity task) {
    if (_tour.active) return;
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
    final ok = await _confirm(
      title: 'Delete $count ${count == 1 ? 'task' : 'tasks'}?',
      message: 'This cannot be undone.',
      action: 'Delete',
      destructive: true,
    );
    if (!ok || !mounted) return;

    final ids = _selectedIds.map((id) => id.toString()).toList();
    _exitSelectMode();
    context.read<DeleteBloc>().add(DeleteEvent(ids: ids));
  }

  // ---- single-task actions -------------------------------------------------

  void _onSwipeDelete(GetEntity task) {
    setState(() => _hiddenIds.add(task.id));
    if (_tour.isAt('swipe') && task.id == _tutorialTaskId) {
      _advanceFrom('swipe', const Duration(milliseconds: 450));
    }

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
            context.read<DeleteBloc>().add(
              DeleteEvent(ids: ['${task.id}'], quiet: true),
            );
          }
        });
  }

  void _onTapTask(GetEntity task) {
    if (_tour.active) return;
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
    if (_tour.isAt('complete') &&
        task.id == _tutorialTaskId &&
        !task.completed) {
      // Wait for the card to move into "Completed" before pointing at it.
      _advanceFrom('complete', const Duration(milliseconds: 800));
    }
  }

  Future<void> _openSheet({GetEntity? task}) async {
    final tutorial = task == null && _tour.isAt('create');
    if (tutorial) _tour.suspend();
    final saved = await showTaskSheet(
      context,
      task: task,
      suggestion: tutorial ? _suggestion : null,
    );
    if (!mounted) return;
    if (saved != null) {
      if (tutorial) _tutorialTitle = saved; // picked up after the reload
      _reload();
    } else if (tutorial) {
      _tour.suspend(false); // closed without saving – show the step again
    }
  }

  /// After the tutorial task is created, find it in the fresh list.
  void _findTutorialTask(List<GetEntity> tasks) {
    final title = _tutorialTitle;
    if (title == null || !_tour.isAt('create')) return;
    final matches =
        tasks.where((t) => t.title == title && !t.completed).toList()
          ..sort((a, b) => b.id.compareTo(a.id));
    if (matches.isEmpty) return;
    setState(() {
      _tutorialTitle = null;
      _tutorialTaskId = matches.first.id;
    });
    _advanceFrom('create', const Duration(milliseconds: 650));
  }

  // ---- menu ----------------------------------------------------------------

  Future<void> _onMenu(HeaderMenu item) async {
    switch (item) {
      case HeaderMenu.tips:
        _startTour();
      case HeaderMenu.privacy:
        if (!await AppLinks.open(AppLinks.privacyPolicy)) {
          _showError('Could not open the page');
        }
      case HeaderMenu.deleteAccount:
        final ok = await _confirm(
          title: 'Delete your account?',
          message:
              'We will permanently delete your account and all your tasks within 30 days. '
              'Your email app will open with a ready-to-send request.',
          action: 'Continue',
          destructive: true,
        );
        if (ok) await AppLinks.requestAccountDeletion(widget.username.trim());
      case HeaderMenu.logout:
        final ok = await _confirm(
          title: 'Log out?',
          message: 'You can sign in again anytime.',
          action: 'Log out',
        );
        if (ok && mounted) context.read<LogoutBloc>().add(LogoutEvent());
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
    bool destructive = false,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: destructive
                ? TextButton.styleFrom(foregroundColor: AppPalette.danger)
                : null,
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true;
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
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.login,
                  (_) => false,
                );
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
                setState(
                  () => _hiddenIds.removeWhere((id) => !alive.contains(id)),
                );
              }
              // Toggle failed on the server → list was rolled back.
              if (state.errorMessage != null) _showError(state.errorMessage!);
              _findTutorialTask(state.getEntity);
              _maybeStartTour();
            },
          ),
        ],
        child: ListenableBuilder(
          listenable: _tour,
          builder: (context, child) => PopScope(
            canPop: !_selectMode && !_tour.active,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              if (_tour.active) {
                _tour.finish();
              } else if (_selectMode) {
                _exitSelectMode();
              }
            },
            child: child!,
          ),
          child: SpotlightTour(
            controller: _tour,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: AnimatedScale(
                duration: const Duration(milliseconds: 220),
                scale: _selectMode ? 0 : 1,
                child: FloatingActionButton.extended(
                  key: _fabKey,
                  onPressed: _selectMode ? null : () => _openSheet(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New task'),
                ),
              ),
              body: AuroraBackground(
                child: BlocBuilder<GetAllBloc, GetAllState>(
                  builder: (context, state) {
                    final tasks = state is GetAllSuccess
                        ? state.getEntity
                              .where((t) => !_hiddenIds.contains(t.id))
                              .toList()
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
                                onToggleTheme: () => sl<ThemeController>()
                                    .toggle(Theme.of(context).brightness),
                                onMenu: _onMenu,
                                onCloseSelect: _exitSelectMode,
                                onDeleteSelected: _deleteSelected,
                                themeKey: _themeKey,
                                progressKey: _progressKey,
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
            icon: Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: context.tokens.muted,
            ),
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
            icon: SvgPicture.asset(
              'assets/icons/no_todo.svg',
              width: 140,
              height: 140,
            ),
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
        _taskList(active, offset: 0),
      ],
      if (done.isNotEmpty) ...[
        _SectionTitle('Completed', done.length),
        _taskList(done, offset: active.length),
      ],
      const SliverToBoxAdapter(child: SizedBox(height: 110)),
    ];
  }

  Widget _taskList(List<GetEntity> items, {required int offset}) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final task = items[i];
          final isTutorial = task.id == _tutorialTaskId;
          return Entrance(
            key: ValueKey('in-${task.id}'),
            index: offset + i,
            child: Dismissible(
              key: ValueKey('task-${task.id}'),
              direction: _selectMode
                  ? DismissDirection.none
                  : DismissDirection.endToStart,
              onDismissed: (_) => _onSwipeDelete(task),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: AppPalette.danger,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                ),
              ),
              child: TaskTile(
                key: isTutorial ? _tutorialTileKey : null,
                checkKey: isTutorial ? _tutorialCheckKey : null,
                title: task.title,
                checked: task.completed,
                selecting: _selectMode,
                selected: _selectedIds.contains(task.id),
                onCheck: () => _onCheck(task),
                onTap: () => _onTapTask(task),
                onLongPress: () =>
                    _selectMode ? _toggleSelect(task) : _startSelect(task),
              ),
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
    final t = context.tokens;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: t.ink,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
              decoration: BoxDecoration(
                color: t.chip,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: t.chipText,
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

  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: t.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: t.muted, height: 1.5),
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}
