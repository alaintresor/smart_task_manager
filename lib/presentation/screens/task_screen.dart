import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/data/models/task.dart';
import 'package:smart_task_manager/data/providers/task_notifier.dart';
import 'package:smart_task_manager/data/providers/auth_provider.dart';
import 'package:smart_task_manager/data/repositories/task_repositiry.dart';
import 'package:smart_task_manager/presentation/widgets/active_filter_bar.dart';
import 'package:smart_task_manager/presentation/widgets/empty_tasks_placeholder.dart';
import 'package:smart_task_manager/presentation/widgets/filter_bottom_sheet.dart';
import 'package:smart_task_manager/presentation/widgets/task_form_dialog.dart';
import 'package:smart_task_manager/presentation/widgets/task_list.dart';
import 'package:smart_task_manager/presentation/widgets/task_search_bar.dart';

class TaskScreen extends ConsumerStatefulWidget {
  final Function()? onLogout;
  final Function(ThemeMode)? onThemeChanged;
  final ThemeMode currentThemeMode;

  const TaskScreen({
    super.key,
    this.onLogout,
    this.onThemeChanged,
    this.currentThemeMode = ThemeMode.system,
  });

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  String _searchQuery = '';
  Priority? _selectedPriority;
  bool? _selectedStatus;
  DateTime? _selectedDueDate;
  List<Task> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredTasks();
  }

  @override
  void didUpdateWidget(TaskScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateFilteredTasks();
  }

  // Update filtered tasks based on current filters
  void _updateFilteredTasks() {
    final asyncTasks = ref.read(taskNotifierProvider);
    
    asyncTasks.whenData((tasks) {
      setState(() {
        _filteredTasks = _filterTasks(tasks);
      });
    });
  }
  
  // Filter tasks based on criteria
  List<Task> _filterTasks(List<Task> tasks) {
    return tasks.where((task) {
      // Filter by search query
      final matchesQuery = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filter by priority
      final matchesPriority = _selectedPriority == null || task.priority == _selectedPriority;
      
      // Filter by status
      final matchesStatus = _selectedStatus == null || 
          (_selectedStatus! ? task.status == TaskStatus.completed : task.status != TaskStatus.completed);
      
      // Filter by due date
      final matchesDueDate = _selectedDueDate == null ||
          (task.dueDate.year == _selectedDueDate!.year &&
           task.dueDate.month == _selectedDueDate!.month &&
           task.dueDate.day == _selectedDueDate!.day);
      
      return matchesQuery && matchesPriority && matchesStatus && matchesDueDate;
    }).toList();
  }

  // Reset all filters
  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedPriority = null;
      _selectedStatus = null;
      _selectedDueDate = null;
    });
    _updateFilteredTasks();
  }

  // Mark task as completed/incomplete
  Future<void> _toggleTaskStatus(String taskId) async {
    final taskNotifier = ref.read(taskNotifierProvider.notifier);
    final asyncTasks = ref.read(taskNotifierProvider);
    
    asyncTasks.whenData((tasks) {
      final taskToUpdate = tasks.firstWhere((task) => task.id == taskId);
      final newStatus = taskToUpdate.status == TaskStatus.completed 
                       ? TaskStatus.pending 
                       : TaskStatus.completed;
      
      final updatedTask = taskToUpdate.copyWith(
        status: newStatus
      );
      
      taskNotifier.updateTask(updatedTask);
      _updateFilteredTasks();
    });
  }

  // Delete a task
  Future<void> _deleteTask(String taskId) async {
    final taskNotifier = ref.read(taskNotifierProvider.notifier);
    await taskNotifier.deleteTask(taskId);
    _updateFilteredTasks();
  }

  // Add or edit a task
  void _addOrEditTask({Task? task}) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(
        task: task,
        onSave: (title, description, priority, dueDate) async {
          final taskNotifier = ref.read(taskNotifierProvider.notifier);
          final asyncTasks = ref.read(taskNotifierProvider);
          final user = ref.read(authStateChangesProvider).value;
          
          if (user == null) return;
          
          if (task != null) {
            // Update existing task
            final updatedTask = task.copyWith(
              title: title,
              description: description,
              priority: priority,
              dueDate: dueDate,
            );
            await taskNotifier.updateTask(updatedTask);
          } else {
            // Add new task
            final newTask = Task(
              id: '', // This will be replaced by Firestore
              title: title,
              description: description,
              priority: priority,
              status: TaskStatus.pending,
              dueDate: dueDate,
              userId: user.uid,
            );
            await taskNotifier.addTask(newTask);
          }
          
          _updateFilteredTasks();
        },
      ),
    );
  }

  // Show filter bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FilterBottomSheet(
        initialPriority: _selectedPriority,
        initialStatus: _selectedStatus,
        initialDueDate: _selectedDueDate,
        onApplyFilters: (priority, status, dueDate) {
          setState(() {
            _selectedPriority = priority;
            _selectedStatus = status;
            _selectedDueDate = dueDate;
          });
          _updateFilteredTasks();
        },
      ),
    );
  }

  // Show logout confirmation dialog
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (widget.onLogout != null) {
                widget.onLogout!();
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Show theme selection dialog
  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeListTile(
                title: 'System',
                themeMode: ThemeMode.system,
                leadingIcon: Icons.brightness_auto,
              ),
              _buildThemeListTile(
                title: 'Light',
                themeMode: ThemeMode.light,
                leadingIcon: Icons.brightness_5,
              ),
              _buildThemeListTile(
                title: 'Dark',
                themeMode: ThemeMode.dark,
                leadingIcon: Icons.brightness_4,
              ),
            ],
          ),
        );
      },
    );
  }

  // Build a list tile for theme selection
  Widget _buildThemeListTile({
    required String title,
    required ThemeMode themeMode,
    required IconData leadingIcon,
  }) {
    final isSelected = widget.currentThemeMode == themeMode;

    return ListTile(
      leading: Icon(leadingIcon),
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () {
        if (widget.onThemeChanged != null) {
          widget.onThemeChanged!(themeMode);
        }
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to task changes for live updates
    ref.listen<AsyncValue<List<Task>>>(taskNotifierProvider, (_, next) {
      next.whenData((tasks) {
        setState(() {
          _filteredTasks = _filterTasks(tasks);
        });
      });
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Test Notifications',
            onPressed: () {
              Navigator.of(context).pushNamed('/notification_test');
            },
          ),
          IconButton(
            icon: _getThemeIcon(),
            onPressed: _showThemeSelectionDialog,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _confirmLogout),
        ],
      ),
      body: Column(
        children: [
          // Search bar component
          TaskSearchBar(
            searchQuery: _searchQuery,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _updateFilteredTasks();
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
              _updateFilteredTasks();
            },
          ),

          // Active filters display component
          if (_selectedPriority != null ||
              _selectedStatus != null ||
              _selectedDueDate != null)
            ActiveFiltersBar(
              priority: _selectedPriority,
              status: _selectedStatus,
              dueDate: _selectedDueDate,
              onRemovePriority: () {
                setState(() {
                  _selectedPriority = null;
                });
                _updateFilteredTasks();
              },
              onRemoveStatus: () {
                setState(() {
                  _selectedStatus = null;
                });
                _updateFilteredTasks();
              },
              onRemoveDueDate: () {
                setState(() {
                  _selectedDueDate = null;
                });
                _updateFilteredTasks();
              },
              onClearAll: _resetFilters,
            ),

          // Task list component with loading state handling
          Expanded(
            child: ref.watch(taskNotifierProvider).when(
              data: (tasks) => _filteredTasks.isEmpty
                  ? const EmptyTasksPlaceholder()
                  : TaskList(
                      tasks: _filteredTasks,
                      onToggleStatus: _toggleTaskStatus,
                      onEdit: (task) => _addOrEditTask(task: task),
                      onDelete: _deleteTask,
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditTask(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Get appropriate theme icon based on current theme mode
  Icon _getThemeIcon() {
    switch (widget.currentThemeMode) {
      case ThemeMode.system:
        return const Icon(Icons.brightness_auto);
      case ThemeMode.light:
        return const Icon(Icons.brightness_5);
      case ThemeMode.dark:
        return const Icon(Icons.brightness_4);
    }
  }
}
