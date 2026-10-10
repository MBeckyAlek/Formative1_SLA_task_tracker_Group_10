import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/enums.dart';
import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../widgets/member_avatar.dart';

class ProfileScreen extends StatelessWidget {
  final TeamMember currentUser;
  final List<Task> tasks;
  final VoidCallback onSwitchUser;
  final VoidCallback onClearData;

  const ProfileScreen({
    super.key,
    required this.currentUser,
    required this.tasks,
    required this.onSwitchUser,
    required this.onClearData,
  });

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This resets all tasks and team members to the sample data and '
          'signs you out. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.overdue),
            child: const Text('Clear data'),
          ),
        ],
      ),
    );
    if (confirmed == true) onClearData();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final mine = tasks.where((t) => t.assigneeId == currentUser.id).toList();
    final completed = mine
        .where((t) => SlaService.compute(t) == SlaStatus.completed)
        .length;
    final overdue = mine
        .where((t) => SlaService.compute(t) == SlaStatus.overdue)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(child: MemberAvatar(member: currentUser, radius: 44)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            currentUser.name,
            textAlign: TextAlign.center,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            currentUser.role,
            textAlign: TextAlign.center,
            style: text.bodyLarge?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 18, color: scheme.outline),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  currentUser.email,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  count: mine.length,
                  label: 'Assigned',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatTile(
                  count: completed,
                  label: 'Completed',
                  color: AppColors.completed,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatTile(
                  count: overdue,
                  label: 'Overdue',
                  color: AppColors.overdue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: onSwitchUser,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Switch user'),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: AppColors.overdue,
              side: const BorderSide(color: AppColors.overdue),
            ),
            onPressed: () => _confirmClear(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear all data'),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatTile({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.sm,
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: text.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}
