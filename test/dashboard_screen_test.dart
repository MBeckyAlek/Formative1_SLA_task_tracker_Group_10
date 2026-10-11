// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/models/enums.dart';
import '../lib/models/task.dart';
import '../lib/models/team_member.dart';
import '../lib/screens/dashboard_screen.dart';
import '../lib/widgets/dashboard_widgets.dart';
import '../lib/widgets/task_card.dart';

void main() {
  const user = TeamMember(
    id: 'm1',
    name: 'Alex Morgan',
    role: 'Lead',
    email: 'alex@example.com',
  );

  testWidgets('shows zero progress safely and opens a selected status filter', (
    tester,
  ) async {
    SlaStatus? selectedStatus;
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(
          tasks: const [],
          members: const [user],
          currentUser: user,
          onOpenTask: (_) {},
          onOpenListWithFilter: (status) => selectedStatus = status,
        ),
      ),
    );

    expect(find.text('Hello, Alex'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('0/0'), findsOneWidget);
    expect(find.text('No overdue or at-risk tasks.'), findsOneWidget);

    await tester.tap(find.text('At Risk'));
    expect(selectedStatus, SlaStatus.atRisk);
  });

  testWidgets('progress ring clamps invalid ratios and shows the percentage', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProgressRing(completed: 8, total: 4)),
      ),
    );

    expect(find.text('100%'), findsOneWidget);
    expect(
      tester.getSize(find.byType(CircularProgressIndicator)),
      const Size(112, 112),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard layout remains valid on a narrow display', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final task = Task(
      id: 't1',
      title: 'A very long task title that should wrap without overflow',
      description: '',
      assigneeId: user.id,
      priority: Priority.medium,
      deadline: DateTime.now().add(const Duration(days: 1)),
      status: TaskStatus.inProgress,
      createdAt: DateTime.now(),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(
          tasks: [task],
          members: const [user],
          currentUser: user,
          onOpenTask: (_) {},
          onOpenListWithFilter: (_) {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('attention list sorts by deadline and shows at most five tasks', (
    tester,
  ) async {
    final now = DateTime.now();
    final tasks = List.generate(
      6,
      (index) => Task(
        id: 't$index',
        title: 'Task ${index + 1}',
        description: '',
        assigneeId: user.id,
        priority: Priority.medium,
        deadline: now.subtract(Duration(days: index + 1)),
        status: TaskStatus.inProgress,
        createdAt: now,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(
          tasks: tasks,
          members: const [user],
          currentUser: user,
          onOpenTask: (_) {},
          onOpenListWithFilter: (_) {},
        ),
      ),
    );

    expect(find.byType(TaskCard), findsNWidgets(5));
    expect(find.text('Task 6'), findsOneWidget);
    expect(find.text('Task 1'), findsNothing);
  });
}
