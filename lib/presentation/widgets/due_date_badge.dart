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
    final bool isPastDue = dueDate.isBefore(DateTime.now());
    final Color textColor = isPastDue ? Colors.red : Colors.grey;
    
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 14,
          color: textColor,
        ),
        const SizedBox(width: 4),
        Text(
          DateFormat('MMM dd, yyyy').format(dueDate),
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: isPastDue ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }
}