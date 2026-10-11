import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_spacing.dart';
import '../models/enums.dart';
import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../widgets/priority_chip.dart';
import '../widgets/sla_badge.dart';
import '../widgets/task_card.dart';

/// Shows one task in full and lets the user change its progress.
/// This screen is opened with Navigator.push, so HomeShell cannot redraw it
/// when data changes. That is why it keeps its own copy of the task (_task):
/// when the user changes the status we update the copy and call setState, so
/// the screen updates immediately, and we also tell HomeShell to save it

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.members,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final List<TeamMember> members;

  final void Function(Task task, TaskStatus newStatus) onStatusChanged;
  final void Function(Task task) onEdit;
  final void Function(Task task) onDelete;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  // Local copy of the task; this is what the screen displays
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  // Actions
  /// Called when the user taps a segment of the status button
  void _onStatusSelected(TaskStatus newStatus) {
    if (newStatus == _task.status) return;

    final previousStatus = _task.status;
    _applyStatus(newStatus);

    // Feedback with an Undo button. Undo applies the previous status again
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Status changed to ${_statusLabel(newStatus)}'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _applyStatus(previousStatus),
          ),
        ),
      );
  }

  /// Changes the status in two places: on this screen and in HomeShell
  void _applyStatus(TaskStatus newStatus) {
    final updatedTask = _task.copyWith(status: newStatus);

    // Update the local copy and redraw
    if (mounted) {
      setState(() => _task = updatedTask);
    }

    // Tell HomeShell, which saves it to the phone
    widget.onStatusChanged(updatedTask, newStatus);
  }

  Future<void> _confirmAndDelete() async {
    final confirmed = await confirmDeleteTask(context, _task);
    // After an await, always check that the screen still exists
    if (!confirmed || !mounted) return;

    widget.onDelete(_task);
    Navigator.pop(context); // the task is gone; close its details page
  }

  // ui
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final slaStatus = SlaService.compute(_task);
    final assignee = findMemberById(widget.members, _task.assigneeId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit task',
            onPressed: () => widget.onEdit(_task),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete task',
            onPressed: _confirmAndDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _task.title,
              style: textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                SlaBadge(status: slaStatus),
                PriorityChip(priority: _task.priority),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildInfoCard(assignee),
            const SizedBox(height: AppSpacing.lg),
            _buildDescriptionSection(context),
            const SizedBox(height: AppSpacing.lg),
            _buildStatusSection(context),
          ],
        ),
      ),
    );
  }

  /// Card with four rows: assignee, deadline, created date, time remaining
  Widget _buildInfoCard(TeamMember? assignee) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Assignee',
              value: assignee?.name ?? 'Unassigned',
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Deadline',
              value: dateFormat.format(_task.deadline),
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              icon: Icons.event_outlined,
              label: 'Created',
              value: dateFormat.format(_task.createdAt),
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              icon: Icons.timer_outlined,
              label: 'Time remaining',
              value: dueInText(_task),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    final theme = Theme.of(context);
    final description = _task.description.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            // The description is optional, show a friendly text if empty
            Text(
              description.isEmpty ? 'No description provided.' : description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: description.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Update progress',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        // the user picks exactly one of three options
        SegmentedButton<TaskStatus>(
          segments: const <ButtonSegment<TaskStatus>>[
            ButtonSegment(value: TaskStatus.todo, label: Text('To Do')),
            ButtonSegment(
              value: TaskStatus.inProgress,
              label: Text('In Progress'),
            ),
            ButtonSegment(value: TaskStatus.done, label: Text('Done')),
          ],
          selected: {_task.status},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => _onStatusSelected(selection.first),
        ),
      ],
    );
  }

  String _statusLabel(TaskStatus status) {
    return switch (status) {
      TaskStatus.todo => 'To Do',
      TaskStatus.inProgress => 'In Progress',
      TaskStatus.done => 'Done',
    };
  }
}

/// One row of the info card: an icon, a small grey label, and the value
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
