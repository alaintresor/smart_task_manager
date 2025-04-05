import 'package:flutter/material.dart';

class TaskSearchBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon:
              searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: onClear,
                  )
                  : null,
        ),
        onChanged: onChanged,
        controller: TextEditingController(text: searchQuery),
      ),
    );
  }
}
