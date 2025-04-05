import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DueDateBadge extends StatelessWidget {
  final DateTime dueDate;
  final bool isOverdue;

  const DueDateBadge({
    super.key,
    required this.dueDate,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 14,
          color: isOverdue ? Colors.red : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          DateFormat('MMM dd, yyyy').format(dueDate),
          style: TextStyle(
            fontSize: 12,
            color: isOverdue ? Colors.red : Colors.grey,
            fontWeight: isOverdue ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }
}