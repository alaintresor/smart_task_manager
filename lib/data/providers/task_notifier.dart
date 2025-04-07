import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/data/models/task.dart';
import 'package:smart_task_manager/data/providers/auth_provider.dart';
import 'package:smart_task_manager/data/repositories/task_repositiry.dart';
import 'package:flutter/foundation.dart';

class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository repository;
  final Ref ref;
  StreamSubscription? _authSubscription;
  StreamSubscription? _tasksSubscription;

  TaskNotifier(this.repository, this.ref) : super(const AsyncValue.loading()) {
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // Cancel any existing subscriptions
    _authSubscription?.cancel();
    _tasksSubscription?.cancel();
    
    // Listen for auth state changes
    _authSubscription = ref.read(authStateChangesProvider.stream).listen((user) {
      debugPrint('TaskNotifier: Auth state changed, user: ${user?.uid ?? 'null'}');
      _loadTasks();
    });
  }

  void _loadTasks() {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) {
      debugPrint('TaskNotifier: No authenticated user found');
      state = const AsyncValue.data([]);
      return;
    }

    // Cancel any existing task subscription
    _tasksSubscription?.cancel();
    
    debugPrint('TaskNotifier: Loading tasks for user ${user.uid}');
    _tasksSubscription = repository.watchTasksForUser(user.uid).listen((tasks) {
      debugPrint('TaskNotifier: Loaded ${tasks.length} tasks');
      state = AsyncValue.data(tasks);
    }, onError: (e, st) {
      debugPrint('TaskNotifier: Error loading tasks: $e');
      state = AsyncValue.error(e, st);
    });
  }

  Future<void> addTask(Task task) async {
    try {
      debugPrint('TaskNotifier: Adding task: ${task.title}');
      await repository.addTask(task);
      debugPrint('TaskNotifier: Task added successfully');
    } catch (e, st) {
      debugPrint('TaskNotifier: Error adding task: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      debugPrint('TaskNotifier: Updating task: ${task.title}');
      await repository.updateTask(task);
      debugPrint('TaskNotifier: Task updated successfully');
    } catch (e, st) {
      debugPrint('TaskNotifier: Error updating task: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      debugPrint('TaskNotifier: Deleting task with ID: $id');
      await repository.deleteTask(id);
      debugPrint('TaskNotifier: Task deleted successfully');
    } catch (e, st) {
      debugPrint('TaskNotifier: Error deleting task: $e');
      state = AsyncValue.error(e, st);
    }
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    _tasksSubscription?.cancel();
    super.dispose();
  }
}

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repo, ref);
});
