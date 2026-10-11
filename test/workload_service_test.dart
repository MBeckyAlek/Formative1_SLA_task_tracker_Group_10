// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter_test/flutter_test.dart';

import '../lib/models/enums.dart';
import '../lib/models/task.dart';
import '../lib/models/team_member.dart';
import '../lib/services/workload_service.dart';

void main() {
  final members = [
    const TeamMember(id: 'm1', name: 'Alex Morgan', role: 'Lead', email: 'a@b.com'),
    const TeamMember(id: 'm2', name: 'Sam Rivera', role: 'QA', email: 's@b.com'),
  ];

  Task makeTask({
    required String id,
    required String assigneeId,
    required DateTime deadline,
    TaskStatus status = TaskStatus.todo,
  }) =>
      Task(
        id: id,
        title: id,
        description: '',
        assigneeId: assigneeId,
        priority: Priority.medium,
        deadline: deadline,
        status: status,
        createdAt: DateTime(2026, 1, 1),
      );

  test('counts assigned and overdue tasks for each member', () {
    final now = DateTime.now();
    final results = calculateMemberWorkload(
      members: members,
      tasks: [
        makeTask(
          id: 'overdue',
          assigneeId: 'm1',
          deadline: DateTime(now.year, now.month, now.day - 2),
        ),
        makeTask(
          id: 'completed',
          assigneeId: 'm1',
          deadline: DateTime(now.year, now.month, now.day - 1),
          status: TaskStatus.done,
        ),
        makeTask(
          id: 'future',
          assigneeId: 'm2',
          deadline: DateTime(now.year, now.month, now.day + 10),
        ),
        makeTask(
          id: 'unknown',
          assigneeId: 'missing-member',
          deadline: DateTime(now.year, now.month, now.day - 3),
        ),
      ],
    );

    expect(results['m1']!.taskCount, 2);
    expect(results['m1']!.overdueCount, 1);
    expect(results['m2']!.taskCount, 1);
    expect(results['m2']!.overdueCount, 0);
  });

  test('includes members with no tasks', () {
    final results = calculateMemberWorkload(members: members, tasks: []);

    expect(results['m1']!.taskCount, 0);
    expect(results['m1']!.overdueCount, 0);
    expect(results['m2']!.taskCount, 0);
  });
}
