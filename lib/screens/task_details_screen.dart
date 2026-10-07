// STUB by A: Person C overwrites this file
import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/task.dart';
import '../models/team_member.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;
  final List<TeamMember> members;
  final void Function(Task, TaskStatus) onStatusChanged;
  final void Function(Task) onEdit;
  final void Function(Task) onDelete;

  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.members,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text('Task Details')));
}
