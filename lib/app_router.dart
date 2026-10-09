import 'package:flutter/material.dart';
import 'models/enums.dart';
import 'models/task.dart';
import 'models/team_member.dart';
import 'screens/home_shell.dart';
import 'screens/sign_in_screen.dart';
import 'screens/task_details_screen.dart';
import 'screens/task_form_screen.dart';

class Routes {
  static const signIn = '/';
  static const home = '/home';
  static const taskDetails = '/task-details';
  static const taskForm = '/task-form';
}

class TaskDetailsArgs {
  final Task task;
  final List<TeamMember> members;
  final void Function(Task, TaskStatus) onStatusChanged;
  final void Function(Task) onEdit;
  final void Function(Task) onDelete;

  const TaskDetailsArgs({
    required this.task,
    required this.members,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
  });
}

class TaskFormArgs {
  final List<TeamMember> members;
  final Task? existingTask; // null = create a new task

  const TaskFormArgs({required this.members, this.existingTask});
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.home:
      return MaterialPageRoute(
        builder: (_) => const HomeShell(),
        settings: settings,
      );

    case Routes.taskDetails:
      final args = settings.arguments as TaskDetailsArgs;
      return MaterialPageRoute(
        builder: (_) => TaskDetailsScreen(
          task: args.task,
          members: args.members,
          onStatusChanged: args.onStatusChanged,
          onEdit: args.onEdit,
          onDelete: args.onDelete,
        ),
        settings: settings,
      );

    case Routes.taskForm:
      final args = settings.arguments as TaskFormArgs;
      return MaterialPageRoute<Task>(
        builder: (_) => TaskFormScreen(
          members: args.members,
          existingTask: args.existingTask,
        ),
        settings: settings,
      );

    default: // Routes.signIn and anything unknown
      return MaterialPageRoute(
        builder: (_) => const SignInScreen(),
        settings: settings,
      );
  }
}
