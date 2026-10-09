import '../models/enums.dart';
import '../models/task.dart';

class SlaService {
  static const Duration atRiskWindow = Duration(hours: 48);

  static const Duration highPriorityWindow = Duration(days: 3);

  static SlaStatus compute(Task task, {DateTime? now}) {
    final current = now ?? DateTime.now();

    if (task.status == TaskStatus.done) return SlaStatus.completed;

    final endOfDeadline = DateTime(
      task.deadline.year,
      task.deadline.month,
      task.deadline.day,
      23,
      59,
      59,
    );

    if (current.isAfter(endOfDeadline)) return SlaStatus.overdue;

    final remaining = endOfDeadline.difference(current);

    if (remaining <= atRiskWindow) return SlaStatus.atRisk;

    if (task.priority == Priority.high &&
        task.status == TaskStatus.todo &&
        remaining <= highPriorityWindow) {
      return SlaStatus.atRisk;
    }

    return SlaStatus.onTrack;
  }
}