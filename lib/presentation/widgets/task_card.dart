import 'package:flutter/material.dart';
import 'package:smart_task_manager/data/models/task.dart';
import 'package:smart_task_manager/presentation/widgets/due_date_badge.dart';
import 'package:smart_task_manager/presentation/widgets/priority_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(String) onToggleStatus;
  final Function(Task) onEdit;
  final Function(String) onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = !task.isCompleted && 
        task.dueDate.isBefore(DateTime.now().subtract(const Duration(hours: 24)));
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Checkbox(
          value: task.isCompleted,
          activeColor: Colors.green,
          onChanged: (_) => onToggleStatus(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(task.description),
            const SizedBox(height: 8),
            Row(
              children: [
                PriorityBadge(priority: task.priority),
                const SizedBox(width: 8),
                DueDateBadge(dueDate: task.dueDate, isOverdue: isOverdue),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              onEdit(task);
            } else if (value == 'delete') {
              onDelete(task.id);
            }
          },
        ),
      ),
    );
  }
}