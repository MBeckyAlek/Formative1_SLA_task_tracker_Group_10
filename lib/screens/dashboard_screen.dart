import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../models/enums.dart';
import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.tasks,
    required this.members,
    required this.currentUser,
    required this.onOpenTask,
    required this.onOpenListWithFilter,
  });

  final List<Task> tasks;
  final List<TeamMember> members;
  final TeamMember currentUser;
  final void Function(Task) onOpenTask;
  final void Function(SlaStatus) onOpenListWithFilter;

  @override
  Widget build(BuildContext context) {
    final counts = {for (final status in SlaStatus.values) status: 0};
    for (final task in tasks) {
      final status = SlaService.compute(task);
      counts[status] = counts[status]! + 1;
    }

    final firstName = currentUser.name.trim().split(RegExp(r'\s+')).first;
    final doneCount = counts[SlaStatus.completed]!;
    final attentionTasks =
        tasks.where((task) {
          final status = SlaService.compute(task);
          return status == SlaStatus.overdue || status == SlaStatus.atRisk;
        }).toList()..sort((a, b) {
          final byDeadline = a.deadline.compareTo(b.deadline);
          return byDeadline != 0 ? byDeadline : a.title.compareTo(b.title);
        });
    final visibleAttentionTasks = attentionTasks.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $firstName',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    ProgressRing(
                      completed: doneCount,
                      total: tasks.length,
                      size: 88,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TEAM OVERVIEW',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Overall progress',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '$doneCount of ${tasks.length} tasks completed',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.45,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(
                  count: counts[SlaStatus.onTrack]!,
                  label: 'On Track',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF2E7D32),
                  onTap: () => onOpenListWithFilter(SlaStatus.onTrack),
                ),
                StatCard(
                  count: counts[SlaStatus.atRisk]!,
                  label: 'At Risk',
                  icon: Icons.warning_amber_outlined,
                  color: const Color(0xFFF9A825),
                  onTap: () => onOpenListWithFilter(SlaStatus.atRisk),
                ),
                StatCard(
                  count: counts[SlaStatus.overdue]!,
                  label: 'Overdue',
                  icon: Icons.error_outline,
                  color: const Color(0xFFC62828),
                  onTap: () => onOpenListWithFilter(SlaStatus.overdue),
                ),
                StatCard(
                  count: counts[SlaStatus.completed]!,
                  label: 'Completed',
                  icon: Icons.task_alt,
                  color: const Color(0xFF607D8B),
                  onTap: () => onOpenListWithFilter(SlaStatus.completed),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (attentionTasks.isNotEmpty) ...[
              _AttentionBanner(count: attentionTasks.length),
              const SizedBox(height: AppSpacing.md),
            ],
            const SectionHeader(title: 'Needs attention'),
            if (visibleAttentionTasks.isEmpty)
              const EmptyState(
                icon: Icons.task_alt,
                message: 'No overdue or at-risk tasks.',
              )
            else
              ListView.builder(
                itemCount: visibleAttentionTasks.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => TaskCard(
                  task: visibleAttentionTasks[index],
                  members: members,
                  onTap: () => onOpenTask(visibleAttentionTasks[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttentionBanner extends StatelessWidget {
  const _AttentionBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.errorContainer;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$count ${count == 1 ? 'task needs' : 'tasks need'} attention',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
