// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter_test/flutter_test.dart';

import '../lib/models/enums.dart';
import '../lib/models/task.dart';
import '../lib/services/sla_service.dart';

void main() {
  // example time
  final now = DateTime(2026, 10, 12, 10, 0);

  Task makeTask({
    required DateTime deadline,
    TaskStatus status = TaskStatus.todo,
    Priority priority = Priority.medium,
  }) =>
      Task(
        id: 't',
        title: 'Test task',
        description: '',
        assigneeId: 'm1',
        priority: priority,
        deadline: deadline,
        status: status,
        createdAt: DateTime(2026, 10, 1),
      );

  group('Completed', () {
    test('done task is Completed', () {
      final t = makeTask(
          deadline: DateTime(2026, 10, 20), status: TaskStatus.done);
      expect(SlaService.compute(t, now: now), SlaStatus.completed);
    });

    test('done task is Completed even if the deadline has passed', () {
      final t = makeTask(
          deadline: DateTime(2026, 10, 1), status: TaskStatus.done);
      expect(SlaService.compute(t, now: now), SlaStatus.completed);
    });
  });

  group('Overdue', () {
    test('deadline was yesterday and not done', () {
      final t = makeTask(deadline: DateTime(2026, 10, 11));
      expect(SlaService.compute(t, now: now), SlaStatus.overdue);
    });

    test('deadline is today is NOT overdue yet', () {
      final t = makeTask(deadline: DateTime(2026, 10, 12));
      expect(SlaService.compute(t, now: now), SlaStatus.atRisk);
    });
  });

  group('At Risk', () {
    test('due tomorrow', () {
      final t = makeTask(deadline: DateTime(2026, 10, 13));
      expect(SlaService.compute(t, now: now), SlaStatus.atRisk);
    });

    test('boundary: exactly 48 hours left is At Risk', () {
      final lateNow = DateTime(2026, 10, 12, 23, 59, 59);
      final t = makeTask(deadline: DateTime(2026, 10, 14));
      expect(SlaService.compute(t, now: lateNow), SlaStatus.atRisk);
    });

    test('high priority, not started, due in 2 days', () {
      final t = makeTask(
          deadline: DateTime(2026, 10, 14), priority: Priority.high);
      expect(SlaService.compute(t, now: now), SlaStatus.atRisk);
    });

    test('boundary: exactly 72 hours left is At Risk', () {
      final lateNow = DateTime(2026, 10, 12, 23, 59, 59);
      final t = makeTask(
          deadline: DateTime(2026, 10, 15), priority: Priority.high);
      expect(SlaService.compute(t, now: lateNow), SlaStatus.atRisk);
    });
  });

  group('On Track', () {
    test('due in 10 days', () {
      final t = makeTask(deadline: DateTime(2026, 10, 22));
      expect(SlaService.compute(t, now: now), SlaStatus.onTrack);
    });

    test('high priority but already started is On Track', () {
      final t = makeTask(
        deadline: DateTime(2026, 10, 14),
        priority: Priority.high,
        status: TaskStatus.inProgress,
      );
      expect(SlaService.compute(t, now: now), SlaStatus.onTrack);
    });

    test('medium priority, not started, due in 2 days is On Track', () {
      final t = makeTask(deadline: DateTime(2026, 10, 14));
      expect(SlaService.compute(t, now: now), SlaStatus.onTrack);
    });

    test('boundary:1 sec over 72 hours is On Track', () {
      final earlyNow = DateTime(2026, 10, 12, 23, 59, 58);
      final t = makeTask(
          deadline: DateTime(2026, 10, 15), priority: Priority.high);
      expect(SlaService.compute(t, now: earlyNow), SlaStatus.onTrack);
    });
  });
}