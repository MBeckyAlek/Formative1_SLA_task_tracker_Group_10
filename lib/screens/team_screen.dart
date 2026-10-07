// STUB by A: Person D overwrites this file
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/team_member.dart';

class TeamScreen extends StatelessWidget {
  final List<Task> tasks;
  final List<TeamMember> members;
  final void Function(TeamMember) onAddMember;
  final void Function(TeamMember) onOpenMemberTasks;

  const TeamScreen({
    super.key,
    required this.tasks,
    required this.members,
    required this.onAddMember,
    required this.onOpenMemberTasks,
  });

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Team')));
}
