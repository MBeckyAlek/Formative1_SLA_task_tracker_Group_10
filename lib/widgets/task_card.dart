import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_spacing.dart';
import '../models/enums.dart';
import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import 'member_avatar.dart';
import 'priority_chip.dart';
import 'sla_badge.dart';

/// One task shown as a card. Used by the Task List and by the Dashboard.
///
/// Widget tree
///
///   Card
///   └─ InkWell                       whole card tappable
///      └─ Padding
///         └─ Column
///            ├─ Row   title (Expanded) + SlaBadge
///            ├─ Row   assignee avatar + name
///            └─ Wrap  PriorityChip, deadline with calendar icon, "Due in 2 days"

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.members,
    required this.onTap,
  });

  final Task task;

  final List<TeamMember> members;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final slaStatus = SlaService.compute(task);
    final assignee = findMemberById(members, task.assigneeId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleRow(context, slaStatus),
              const SizedBox(height: AppSpacing.sm),
              _buildAssigneeRow(context, assignee),
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow(context, slaStatus),
            ],
          ),
        ),
      ),
    );
  }

  /// Top row: the title takes all the free space, the badge keeps its size.
  Widget _buildTitleRow(BuildContext context, SlaStatus slaStatus) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            task.title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SlaBadge(status: slaStatus),
      ],
    );
  }

  /// avatar and name of the person the task is assigned to
  Widget _buildAssigneeRow(BuildContext context, TeamMember? assignee) {
    return Row(
      children: [
        // The assignee can be null if that member was deleted.
        if (assignee != null)
          MemberAvatar(member: assignee, radius: 14)
        else
          const CircleAvatar(
            radius: 14,
            child: Icon(Icons.person_outline, size: 16),
          ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            assignee?.name ?? 'Unassigned',
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// priority, deadline and "Due in ...".
  Widget _buildInfoRow(BuildContext context, SlaStatus slaStatus) {
    final theme = Theme.of(context);
    final subtleColor = theme.colorScheme.onSurfaceVariant;
    final isOverdue = slaStatus == SlaStatus.overdue;
    final deadlineText = DateFormat('MMM d, yyyy').format(task.deadline);

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PriorityChip(priority: task.priority),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined, size: 14, color: subtleColor),
            const SizedBox(width: AppSpacing.xs),
            Text(
              deadlineText,
              style: theme.textTheme.bodySmall?.copyWith(color: subtleColor),
            ),
          ],
        ),
        Text(
          dueInText(task),
          style: theme.textTheme.bodySmall?.copyWith(
            color: isOverdue ? SlaBadge.colorFor(SlaStatus.overdue) : subtleColor,
            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

TeamMember? findMemberById(List<TeamMember> members, String? id) {
  for (final member in members) {
    if (member.id == id) return member;
  }
  return null;
}

String dueInText(Task task) {
  if (task.status == TaskStatus.done) return 'Done';

  final days = _daysUntil(task.deadline);

  if (days < 0) {
    final daysLate = -days;
    return daysLate == 1 ? '1 day overdue' : '$daysLate days overdue';
  }
  if (days == 0) return 'Due today';
  if (days == 1) return 'Due tomorrow';
  return 'Due in $days days';
}

int _daysUntil(DateTime deadline) {
  final now = DateTime.now();
  // DateTime.utc avoids daylight-saving shifts that could be off by one day.
  final deadlineDay = DateTime.utc(deadline.year, deadline.month, deadline.day);
  final today = DateTime.utc(now.year, now.month, now.day);
  return deadlineDay.difference(today).inDays;
}

Future<bool> confirmDeleteTask(BuildContext context, Task task) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete task?'),
      content: Text('"${task.title}" will be removed permanently.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}