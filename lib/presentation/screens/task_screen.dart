import 'package:flutter/material.dart';
import 'package:smart_task_manager/data/models/task.dart';
import 'package:smart_task_manager/presentation/widgets/active_filter_bar.dart';
import 'package:smart_task_manager/presentation/widgets/empty_tasks_placeholder.dart';
import 'package:smart_task_manager/presentation/widgets/filter_bottom_sheet.dart';
import 'package:smart_task_manager/presentation/widgets/task_form_dialog.dart';
import 'package:smart_task_manager/presentation/widgets/task_list.dart';
import 'package:smart_task_manager/presentation/widgets/task_search_bar.dart';

class TaskScreen extends StatefulWidget {
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
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  // Sample task data
  final List<Task> _allTasks = [
    Task(
      id: '1',
      title: 'Complete Flutter Project',
      description: 'Finish the task manager app with all features',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      priority: Priority.high,
    ),
    Task(
      id: '2',
      title: 'Weekly Team Meeting',
      description: 'Discuss project progress and roadblocks',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: Priority.medium,
    ),
    Task(
      id: '3',
      title: 'Review Pull Requests',
      description: 'Check and approve pending PRs',
      dueDate: DateTime.now(),
      priority: Priority.low,
      isCompleted: true,
    ),
  ];

  List<Task> _filteredTasks = [];
  String _searchQuery = '';
  Priority? _selectedPriority;
  bool? _selectedStatus;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _filteredTasks = List.from(_allTasks);
  }

  // Apply filters to the task list
  void _applyFilters() {
    setState(() {
      _filteredTasks =
          _allTasks.where((task) {
            // Apply search filter
            final matchesSearch =
                task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                task.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );

            // Apply priority filter
            final matchesPriority =
                _selectedPriority == null || task.priority == _selectedPriority;

            // Apply status filter
            final matchesStatus =
                _selectedStatus == null || task.isCompleted == _selectedStatus;

            // Apply due date filter
            final matchesDueDate =
                _selectedDueDate == null ||
                (task.dueDate.year == _selectedDueDate!.year &&
                    task.dueDate.month == _selectedDueDate!.month &&
                    task.dueDate.day == _selectedDueDate!.day);

            return matchesSearch &&
                matchesPriority &&
                matchesStatus &&
                matchesDueDate;
          }).toList();
    });
  }

  // Reset all filters
  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedPriority = null;
      _selectedStatus = null;
      _selectedDueDate = null;
      _filteredTasks = List.from(_allTasks);
    });
  }

  // Mark task as completed/incomplete
  void _toggleTaskStatus(String taskId) {
    setState(() {
      final taskIndex = _allTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _allTasks[taskIndex].isCompleted = !_allTasks[taskIndex].isCompleted;
        _applyFilters(); // Reapply filters after updating
      }
    });
  }

  // Delete a task
  void _deleteTask(String taskId) {
    setState(() {
      _allTasks.removeWhere((task) => task.id == taskId);
      _applyFilters(); // Reapply filters after updating
    });
  }

  // Add or edit a task
  void _addOrEditTask({Task? task}) {
    showDialog(
      context: context,
      builder:
          (context) => TaskFormDialog(
            task: task,
            onSave: (title, description, priority, dueDate) {
              setState(() {
                if (task != null) {
                  // Update existing task
                  task.title = title;
                  task.description = description;
                  task.priority = priority;
                  task.dueDate = dueDate;
                } else {
                  // Add new task
                  final newTask = Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: title,
                    description: description,
                    priority: priority,
                    dueDate: dueDate,
                  );
                  _allTasks.add(newTask);
                }
              });
              _applyFilters(); // Reapply filters after adding/editing
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
      builder:
          (context) => FilterBottomSheet(
            initialPriority: _selectedPriority,
            initialStatus: _selectedStatus,
            initialDueDate: _selectedDueDate,
            onApplyFilters: (priority, status, dueDate) {
              setState(() {
                _selectedPriority = priority;
                _selectedStatus = status;
                _selectedDueDate = dueDate;
              });
              _applyFilters();
            },
          ),
    );
  }

  // Show logout confirmation dialog
  void _confirmLogout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
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
              _applyFilters();
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
              _applyFilters();
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
                _applyFilters();
              },
              onRemoveStatus: () {
                setState(() {
                  _selectedStatus = null;
                });
                _applyFilters();
              },
              onRemoveDueDate: () {
                setState(() {
                  _selectedDueDate = null;
                });
                _applyFilters();
              },
              onClearAll: _resetFilters,
            ),

          // Task list component
          Expanded(
            child:
                _filteredTasks.isEmpty
                    ? const EmptyTasksPlaceholder()
                    : TaskList(
                      tasks: _filteredTasks,
                      onToggleStatus: _toggleTaskStatus,
                      onEdit: (task) => _addOrEditTask(task: task),
                      onDelete: _deleteTask,
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
