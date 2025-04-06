import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/core/services/notification_service.dart';
import 'package:smart_task_manager/data/models/task.dart';
import 'package:flutter/foundation.dart';

/// Repository for managing tasks in Firestore and related notifications
class TaskRepository {
  final FirebaseFirestore firestore;
  static const String collectionName = 'tasks';

  TaskRepository(this.firestore);

  CollectionReference get _taskCollection => firestore.collection(collectionName);

  /// Adds a new task to Firestore and schedules a notification if needed
  Future<void> addTask(Task task) async {
    try {
      debugPrint('TaskRepository: Adding task to Firestore: ${task.title}');
      
      // Add task to Firestore
      final docRef = await _taskCollection.add(task.toJson());
      debugPrint('TaskRepository: Task added with ID: ${docRef.id}');
      
      // Since the Firestore ID is generated after adding the document,
      // update the task with this ID if needed
      if (task.id.isEmpty) {
        final updatedTask = task.copyWith(id: docRef.id);
        await docRef.update({'id': docRef.id});
        debugPrint('TaskRepository: Updated task with Firestore ID');
        
        // Schedule notification only if the task has a future due date
        await _scheduleTaskNotification(updatedTask);
      } else {
        await _scheduleTaskNotification(task);
      }
    } catch (e) {
      debugPrint('TaskRepository: Error adding task: $e');
      throw _handleException('Error adding task', e);
    }
  }

  /// Updates an existing task in Firestore and reschedules notification
  Future<void> updateTask(Task task) async {
    try {
      if (task.id.isEmpty) {
        throw ArgumentError('Task ID cannot be empty when updating');
      }
      
      debugPrint('TaskRepository: Updating task in Firestore: ${task.title}');
      
      // Update the task in Firestore
      await _taskCollection.doc(task.id).update(task.toJson());
      debugPrint('TaskRepository: Task updated successfully');
      
      // Cancel existing notification and reschedule
      await NotificationService.cancel(task.id.hashCode);
      await _scheduleTaskNotification(task);
    } catch (e) {
      debugPrint('TaskRepository: Error updating task: $e');
      throw _handleException('Error updating task', e);
    }
  }

  /// Deletes a task and cancels its notification
  Future<void> deleteTask(String taskId) async {
    try {
      if (taskId.isEmpty) {
        throw ArgumentError('Task ID cannot be empty when deleting');
      }
      
      debugPrint('TaskRepository: Deleting task from Firestore: $taskId');
      
      // Delete the task from Firestore
      await _taskCollection.doc(taskId).delete();
      debugPrint('TaskRepository: Task deleted successfully');
      
      // Cancel any existing notification for this task
      await NotificationService.cancel(taskId.hashCode);
    } catch (e) {
      debugPrint('TaskRepository: Error deleting task: $e');
      throw _handleException('Error deleting task', e);
    }
  }

  /// Creates a stream of tasks for a specific user, ordered by due date
  Stream<List<Task>> watchTasksForUser(String userId) {
    try {
      if (userId.isEmpty) {
        throw ArgumentError('User ID cannot be empty');
      }
      
      debugPrint('TaskRepository: Watching tasks for user: $userId');
      
      return _taskCollection
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate')
          .snapshots()
          .map((snapshot) {
            final tasks = snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
            debugPrint('TaskRepository: Retrieved ${tasks.length} tasks for user $userId');
            return tasks;
          });
    } catch (e) {
      debugPrint('TaskRepository: Error watching tasks: $e');
      throw _handleException('Error watching tasks', e);
    }
  }
  
  /// Helper method to schedule a notification for a task if it has a future due date
  Future<void> _scheduleTaskNotification(Task task) async {
    try {
      // Only schedule notifications for tasks with future due dates
      if (task.dueDate.isAfter(DateTime.now())) {
        debugPrint('TaskRepository: Scheduling notification for task: ${task.title}');
        await NotificationService.scheduleNotification(
          id: task.id.hashCode,
          title: 'Reminder: ${task.title}',
          body: task.description ?? 'You have a task due!',
          dateTime: task.dueDate,
        );
        debugPrint('TaskRepository: Notification scheduled successfully');
      }
    } catch (e) {
      debugPrint('TaskRepository: Error scheduling notification: $e');
      // Don't throw here as notification scheduling is not critical
    }
  }
  
  /// Helper method to standardize exception handling
  Exception _handleException(String message, dynamic error) {
    debugPrint('TaskRepository: $message: $error');
    if (error is FirebaseException) {
      return Exception('$message (code: ${error.code}): ${error.message}');
    }
    return Exception('$message: $error');
  }
}

/// Provider for TaskRepository using Riverpod
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(FirebaseFirestore.instance);
});