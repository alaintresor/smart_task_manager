import 'package:flutter/material.dart';

// Model class for Task
class Task {
  final String id;
  String title;
  String description;
  DateTime dueDate;
  Priority priority;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });
}

// Enum for Priority levels
enum Priority { low, medium, high }

extension PriorityColor on Priority {
  Color get color {
    switch (this) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      }
  }

  String get label {
    return toString().split('.').last.toUpperCase();
  }
}


