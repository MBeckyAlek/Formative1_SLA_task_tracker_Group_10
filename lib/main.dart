import 'package:flutter/material.dart';
import 'app_router.dart';
import 'core/theme/app_theme.dart';

void main() => runApp(const TaskTrackerApp());

class TaskTrackerApp extends StatelessWidget {
  const TaskTrackerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Task Tracker',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        initialRoute: Routes.signIn,
        onGenerateRoute: onGenerateRoute,
      );
}
