// STUB by A: Person C overwrites this file
import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/task.dart';
import '../models/team_member.dart';

class TaskListScreen extends StatelessWidget {
  final List<Task> tasks;
  final List<TeamMember> members;
  final SlaStatus? initialFilter;
  final void Function(Task) onOpenTask;
  final void Function(Task) onDeleteTask;

  const TaskListScreen({
    super.key,
    required this.tasks,
    required this.members,
    this.initialFilter,
    required this.onOpenTask,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Tasks')));
}
