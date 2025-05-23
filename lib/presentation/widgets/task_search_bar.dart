import 'package:flutter/material.dart';

class TaskSearchBar extends StatefulWidget {
  final String searchQuery;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const TaskSearchBar({
    super.key,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  _TaskSearchBarState createState() => _TaskSearchBarState();
}

class _TaskSearchBarState extends State<TaskSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onClear();
                  },
                )
              : null,
        ),
        onChanged: (value) {
          widget.onChanged(value);
        },
        controller: _controller,
      ),
    );
  }
}
