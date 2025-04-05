import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_task_manager/data/models/task.dart';

class FilterBottomSheet extends StatefulWidget {
  final Priority? initialPriority;
  final bool? initialStatus;
  final DateTime? initialDueDate;
  final Function(Priority?, bool?, DateTime?) onApplyFilters;

  const FilterBottomSheet({
    super.key,
    this.initialPriority,
    this.initialStatus,
    this.initialDueDate,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Priority? _priority;
  late bool? _status;
  late DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _priority = widget.initialPriority;
    _status = widget.initialStatus;
    _dueDate = widget.initialDueDate;
  }

  void _resetFilters() {
    setState(() {
      _priority = null;
      _status = null;
      _dueDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Tasks',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Priority:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Wrap(
            spacing: 8,
            children: [
              ...Priority.values.map(
                (priority) => FilterChip(
                  label: Text(priority.label),
                  selected: _priority == priority,
                  onSelected: (selected) {
                    setState(() {
                      _priority = selected ? priority : null;
                    });
                  },
                  backgroundColor: priority.color.withOpacity(0.2),
                  selectedColor: priority.color.withOpacity(0.6),
                ),
              ),
              FilterChip(
                label: const Text('All'),
                selected: _priority == null,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _priority = null;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Status:', style: TextStyle(fontWeight: FontWeight.w500)),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Completed'),
                selected: _status == true,
                onSelected: (selected) {
                  setState(() {
                    _status = selected ? true : null;
                  });
                },
              ),
              FilterChip(
                label: const Text('Active'),
                selected: _status == false,
                onSelected: (selected) {
                  setState(() {
                    _status = selected ? false : null;
                  });
                },
              ),
              FilterChip(
                label: const Text('All'),
                selected: _status == null,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _status = null;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Due Date:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _dueDate == null
                        ? 'Select Date'
                        : DateFormat('MMM dd, yyyy').format(_dueDate!),
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _dueDate = date;
                      });
                    }
                  },
                ),
              ),
              if (_dueDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _dueDate = null;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: _resetFilters, child: const Text('Reset')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(_priority, _status, _dueDate);
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
