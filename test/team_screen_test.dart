// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/models/team_member.dart';
import '../lib/screens/team_screen.dart';

void main() {
  const member = TeamMember(
    id: 'm1',
    name: 'Alex Morgan',
    role: 'Project Lead',
    email: 'alex@example.com',
  );

  testWidgets('shows workload and opens member task filter', (tester) async {
    TeamMember? selectedMember;
    await tester.pumpWidget(
      MaterialApp(
        home: TeamScreen(
          tasks: const [],
          members: const [member],
          onAddMember: (_) {},
          onOpenMemberTasks: (value) => selectedMember = value,
        ),
      ),
    );

    expect(find.text('0 tasks'), findsOneWidget);
    await tester.tap(find.text('Alex Morgan'));
    expect(selectedMember, member);
  });

  testWidgets('validates and adds a member from the bottom sheet', (
    tester,
  ) async {
    TeamMember? addedMember;
    await tester.pumpWidget(
      MaterialApp(
        home: TeamScreen(
          tasks: const [],
          members: const [member],
          onAddMember: (value) => addedMember = value,
          onOpenMemberTasks: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('Add member'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save member'));
    await tester.pumpAndSettle();
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Role is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Taylor Kim');
    await tester.enterText(find.byType(TextFormField).at(1), 'QA Engineer');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'taylor@example.com',
    );
    await tester.tap(find.text('Save member'));
    await tester.pumpAndSettle();

    expect(addedMember?.name, 'Taylor Kim');
    expect(addedMember?.role, 'QA Engineer');
    expect(addedMember?.email, 'taylor@example.com');
  });
}
