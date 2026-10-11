import '../models/enums.dart';
import '../models/task.dart';
import '../models/team_member.dart';
import 'sla_service.dart';

class MemberWorkload {
  const MemberWorkload({
    required this.taskCount,
    required this.overdueCount,
  });

  final int taskCount;
  final int overdueCount;
}

Map<String, MemberWorkload> calculateMemberWorkload({
  required List<Task> tasks,
  required List<TeamMember> members,
}) {
  final counts = {
    for (final member in members) member.id: [0, 0],
  };

  for (final task in tasks) {
    final memberCounts = counts[task.assigneeId];
    if (memberCounts == null) continue;

    memberCounts[0]++;
    if (SlaService.compute(task) == SlaStatus.overdue) {
      memberCounts[1]++;
    }
  }

  return {
    for (final member in members)
      member.id: MemberWorkload(
        taskCount: counts[member.id]![0],
        overdueCount: counts[member.id]![1],
      ),
  };
}
