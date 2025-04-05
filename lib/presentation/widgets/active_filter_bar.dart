import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/task.dart';

class ActiveFiltersBar extends StatelessWidget {
  final Priority? priority;
  final bool? status;
  final DateTime? dueDate;
  final VoidCallback onRemovePriority;
  final VoidCallback onRemoveStatus;
  final VoidCallback onRemoveDueDate;
  final VoidCallback onClearAll;

  const ActiveFiltersBar({
    super.key,
    this.priority,
    this.status,
    this.dueDate,
    required this.onRemovePriority,
    required this.onRemoveStatus,
    required this.onRemoveDueDate,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text('Filters:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (priority != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text('Priority: ${priority!.label}'),
                        backgroundColor: priority!.color.withOpacity(0.2),
                        deleteIcon: const Icon(Icons.clear, size: 18),
                        onDeleted: onRemovePriority,
                      ),
                    ),
                  if (status != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text('Status: ${status! ? 'Completed' : 'Active'}'),
                        deleteIcon: const Icon(Icons.clear, size: 18),
                        onDeleted: onRemoveStatus,
                      ),
                    ),
                  if (dueDate != null)
                    Chip(
                      label: Text(
                        'Due: ${DateFormat('MMM dd, yyyy').format(dueDate!)}',
                      ),
                      deleteIcon: const Icon(Icons.clear, size: 18),
                      onDeleted: onRemoveDueDate,
                    ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: onClearAll,
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}