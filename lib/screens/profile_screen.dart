import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/team_member.dart';

class ProfileScreen extends StatelessWidget {
  final TeamMember currentUser;
  final List<Task> tasks;
  final VoidCallback onSwitchUser;
  final VoidCallback onClearData;

  const ProfileScreen({
    super.key,
    required this.currentUser,
    required this.tasks,
    required this.onSwitchUser,
    required this.onClearData,
  });

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Profile')));
}
