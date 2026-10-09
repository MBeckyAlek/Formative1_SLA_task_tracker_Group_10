import 'package:flutter/material.dart';
import '../models/enums.dart';

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final Priority priority;

  String _label() {
    return switch (priority) {
      Priority.low => 'Low',
      Priority.medium => 'Medium',
      Priority.high => 'High',
    };
  }

  Color _color() {
    return switch (priority) {
      Priority.low => const Color.fromARGB(255, 120, 239, 93),
      Priority.medium => const Color.fromARGB(255, 225, 210, 74),
      Priority.high => const Color.fromARGB(205, 250, 104, 104),
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();

    return Chip(
      avatar: Icon(Icons.flag, size: 16, color: color),
      label: Text(_label()),
      labelStyle: Theme.of(context).textTheme.labelSmall,
      backgroundColor: color.withAlpha(30),
      side: BorderSide(color: color),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}