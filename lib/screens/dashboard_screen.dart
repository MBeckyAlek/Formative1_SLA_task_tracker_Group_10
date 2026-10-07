// STUB by A: Person D overwrites this file
import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/task.dart';
import '../models/team_member.dart';

class DashboardScreen extends StatelessWidget {
  final List<Task> tasks;
  final List<TeamMember> members;
  final TeamMember currentUser;
  final void Function(Task) onOpenTask;
  final void Function(SlaStatus) onOpenListWithFilter;

  const DashboardScreen({
    super.key,
    required this.tasks,
    required this.members,
    required this.currentUser,
    required this.onOpenTask,
    required this.onOpenListWithFilter,
  });

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Dashboard')));
}
