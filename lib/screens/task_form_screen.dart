// STUB by A: Person B overwrites this file
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/team_member.dart';

class TaskFormScreen extends StatelessWidget {
  final List<TeamMember> members;
  final Task? existingTask; // null = create

  const TaskFormScreen({super.key, required this.members, this.existingTask});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(existingTask == null ? 'New Task' : 'Edit Task')),
      );
}
