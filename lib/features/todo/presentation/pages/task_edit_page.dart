import 'package:flutter/material.dart';
import 'package:ntodo/features/todo/domain/entities/get_entity.dart';
import '../../../../core/constants/colors.dart';
import 'edit_dialog.dart';

class TaskEditPage extends StatefulWidget {
  final GetEntity task;
  const TaskEditPage({super.key, required this.task});

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  late String _title;

  @override
  void initState() {
    super.initState();
    _title = widget.task.title;
  }

  Future<void> _editTask() async {
    final newTitle = await showEditTaskDialog(
      context,
      initialTitle: _title,
      id: widget.task.id,
    );

    if (!mounted) return;

    final v = (newTitle ?? '').trim();
    if (v.isEmpty) return;

    //  detail page text update
    setState(() => _title = v);

    //  home'ga updated entity qaytar
    final updatedTask = widget.task.copyWith(title: v);
    Navigator.pop(context, updatedTask);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.buttonColor,
        foregroundColor: Colors.white,
        title: const Text('Task Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 64,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            _title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SizedBox(
            height: 60,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _editTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Edit Task',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
