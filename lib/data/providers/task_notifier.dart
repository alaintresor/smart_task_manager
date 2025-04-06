import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/data/models/task.dart';
import 'package:smart_task_manager/data/providers/auth_provider.dart';
import 'package:smart_task_manager/data/repositories/task_repositiry.dart';

class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository repository;
  final Ref ref;

  TaskNotifier(this.repository, this.ref) : super(const AsyncValue.loading()) {
    _loadTasks();
  }

  void _loadTasks() {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }

    repository.watchTasksForUser(user.uid).listen((tasks) {
      state = AsyncValue.data(tasks);
    }, onError: (e, st) {
      state = AsyncValue.error(e, st);
    });
  }

  Future<void> addTask(Task task) async {
    try {
      await repository.addTask(task);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await repository.updateTask(task);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await repository.deleteTask(id);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repo, ref);
});
