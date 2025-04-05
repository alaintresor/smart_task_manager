import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_task_manager/data/models/task.dart';

class TaskFormDialog extends StatefulWidget {
  final Task? task;
  final Function(String, String, Priority, DateTime) onSave;

  const TaskFormDialog({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late Priority _selectedPriority;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.task != null;
    _titleController = TextEditingController(text: isEditing ? widget.task!.title : '');
    _descriptionController = TextEditingController(text: isEditing ? widget.task!.description : '');
    _selectedPriority = isEditing ? widget.task!.priority : Priority.medium;
    _selectedDate = isEditing ? widget.task!.dueDate : DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Task' : 'Add New Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Priority>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: Priority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: priority.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(priority.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Due Date"),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a title')),
              );
              return;
            }
            
            widget.onSave(
              _titleController.text.trim(),
              _descriptionController.text.trim(),
              _selectedPriority,
              _selectedDate,
            );
            
            Navigator.pop(context);
          },
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}