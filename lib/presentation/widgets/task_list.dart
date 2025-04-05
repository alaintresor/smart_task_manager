import 'package:flutter/material.dart';
import 'package:smart_task_manager/data/models/task.dart';
import 'package:smart_task_manager/presentation/widgets/task_card.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(String) onToggleStatus;
  final Function(Task) onEdit;
  final Function(String) onDelete;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        return TaskCard(
          task: tasks[index],
          onToggleStatus: onToggleStatus,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
    );
  }
}
