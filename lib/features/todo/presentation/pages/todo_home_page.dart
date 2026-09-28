import 'package:flutter/material.dart';
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

import '../../../../core/constants/colors.dart';
import '../../../../core/route/route_names.dart';
import '../widgets/task_tile.dart';
import '../widgets/top_header.dart';
import 'add_task_dialog.dart';

class TodoHomePage extends StatefulWidget {
  final String username;

  const TodoHomePage({super.key, required this.username});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  bool _selectMode = false;
  late String _username;

  final Set<int> _selectedIds = {};

  Future<void> _reload() async {
    context.read<GetAllBloc>().add(GetAllEvent());
  }

  @override
  void initState() {
    super.initState();

    _username = widget.username.trim();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetAllBloc>().add(GetAllEvent(clearCurrent: true));
    });
  }

  void _toggleSelect(GetEntity task) {
    setState(() {
      if (_selectedIds.contains(task.id)) {
        _selectedIds.remove(task.id);
      } else {
        _selectedIds.add(task.id);
      }
    });
  }

  void _exitSelectMode() {
    setState(() {
      _selectMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _onDeletePressed(List<GetEntity> tasks) async {
    if (!_selectMode) {
      setState(() {
        _selectMode = true;
        _selectedIds.clear();
      });
      return;
    }

    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select tasks first')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete selected tasks?'),
        content: Text('This will remove ${_selectedIds.length} task(s).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final ids = _selectedIds.toList();

    setState(() {
      _selectedIds.clear();
      _selectMode = false;
    });

    context.read<DeleteBloc>().add(
      DeleteEvent(ids: ids.map((id) => id.toString()).toList()),
    );
  }

  Future<void> _addTaskLocal() async {
    final created = await showCreateTaskDialog(context);
    if (created == true && context.mounted) {
      context.read<GetAllBloc>().add(GetAllEvent());
    }
  }

  Widget _emptyUi() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: SvgPicture.asset(
              'assets/icons/no_todo.svg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'You have no task listed.',
            style: TextStyle(color: Color(0xFFB5B5B5), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _listUi(List<GetEntity> tasks) {
    final active = tasks.where((e) => !e.completed).toList();
    final done = tasks.where((e) => e.completed).toList();

    return ListView(
      padding: const EdgeInsets.only(top: 10, bottom: 120),
      children: [
        ...active.map((t) {
          final selected = _selectedIds.contains(t.id);
          return TaskTile(
            title: t.title,
            checked: t.completed,
            selected: selected,
            onCheck: () {
              context.read<GetAllBloc>().add(
                ToggleTodoEvent(
                  id: t.id,
                  value: !t.completed,
                  title: t.title,
                ),
              );
            },
            onTap: () async {
              if (_selectMode) {
                _toggleSelect(t);
                return;
              }

              final updated = await Navigator.pushNamed(
                context,
                RouteNames.taskDetail,
                arguments: {'task': t},
              );

              if (updated is GetEntity) {
                context.read<GetAllBloc>().add(GetAllEvent());
              }
            },
          );
        }),
        const SizedBox(height: 18),
        if (done.isNotEmpty) ...[
          const Text(
            'Completed',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...done.map((t) {
            final selected = _selectedIds.contains(t.id);
            return TaskTile(
              title: t.title,
              checked: t.completed,
              selected: selected,
              isCompletedStyle: true,
              onCheck: () {
                context.read<GetAllBloc>().add(
                  ToggleTodoEvent(
                    id: t.id,
                    value: !t.completed,
                    title: t.title,
                  ),
                );
              },
              onTap: () async {
                if (_selectMode) {
                  _toggleSelect(t);
                  return;
                }
              },
            );
          }),
        ],
      ],
    );
  }

  List<GetEntity> _extractItems(GetAllSuccess state) => state.getEntity;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ✅ Delete listener
        BlocListener<DeleteBloc, DeleteState>(
          listener: (context, state) {
            if (state is DeleteSuccess) {
              context.read<GetAllBloc>().add(GetAllEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${state.count} ta task o‘chirildi")),
              );
            }

            if (state is DeleteError) {
              // Some may have been deleted before the failure.
              context.read<GetAllBloc>().add(GetAllEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(state.message),
                ),
              );
            }
          },
        ),

        // ✅ Logout listener
        BlocListener<LogoutBloc, LogoutState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.login,
                    (_) => false,
              );
            }

            if (state is LogoutError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),

        // Toggle failed on the server → list was rolled back, tell the user.
        BlocListener<GetAllBloc, GetAllState>(
          listenWhen: (_, curr) => curr is GetAllSuccess && curr.errorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text((state as GetAllSuccess).errorMessage!),
              ),
            );
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: GestureDetector(
          onTap: () {
            if (_selectMode && _selectedIds.isEmpty) _exitSelectMode();
          },
          child: Column(
            children: [
              TodoHeader(
                username: _username,
                selecting: _selectMode,
                selectedCount: _selectedIds.length,
                onDelete: () {
                  final st = context.read<GetAllBloc>().state;
                  if (st is GetAllSuccess) {
                    _onDeletePressed(_extractItems(st));
                  } else {
                    _onDeletePressed(const []);
                  }
                },
                onCloseSelect: _exitSelectMode,

                // ✅ Logout event yuboramiz
                onLogout: () {
                  context.read<LogoutBloc>().add( LogoutEvent());
                },
              ),

              Expanded(
                child: BlocBuilder<GetAllBloc, GetAllState>(
                  builder: (context, state) {
                    if (state is GetAllInitial) {
                      return Center(
                        child: ElevatedButton(
                          onPressed: () =>
                              context.read<GetAllBloc>().add(GetAllEvent()),
                          child: const Text("Load"),
                        ),
                      );
                    }

                    if (state is GetAllLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is GetAllError) {
                      return RefreshIndicator(
                        onRefresh: _reload,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 180),
                            Center(child: Text(state.message)),
                          ],
                        ),
                      );
                    }

                    if (state is GetAllSuccess) {
                      final tasks = _extractItems(state);
                      if (tasks.isEmpty) return _emptyUi();

                      return Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: RefreshIndicator(
                          onRefresh: _reload,
                          child: _listUi(tasks),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addTaskLocal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Add New Task',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}