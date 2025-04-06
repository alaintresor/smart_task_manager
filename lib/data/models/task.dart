import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { low, medium, high }
enum TaskStatus { pending, inProgress, completed }

class Task {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final TaskStatus status;
  final DateTime dueDate;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.userId,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      priority: Priority.values[data['priority'] ?? 0],
      status: TaskStatus.values[data['status'] ?? 0],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'priority': priority.index,
        'status': status.index,
        'dueDate': Timestamp.fromDate(dueDate),
        'userId': userId,
      };

  Task copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      userId: userId ?? this.userId,
    );
  }
}

extension TaskCompletion on Task {
  bool get isCompleted => status == TaskStatus.completed;
}

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


