import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/theme/app_spacing.dart';
import '../core/utils/validators.dart';
import '../models/task.dart';
import '../models/team_member.dart';
import '../services/workload_service.dart';
import '../widgets/member_avatar.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({
    super.key,
    required this.tasks,
    required this.members,
    required this.onAddMember,
    required this.onOpenMemberTasks,
  });

  final List<Task> tasks;
  final List<TeamMember> members;
  final void Function(TeamMember) onAddMember;
  final void Function(TeamMember) onOpenMemberTasks;

  Future<void> _showAddMemberForm(BuildContext context) async {
    final member = await showModalBottomSheet<TeamMember>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddMemberSheet(members: members),
    );
    if (member != null) onAddMember(member);
  }

  @override
  Widget build(BuildContext context) {
    final workloads = calculateMemberWorkload(tasks: tasks, members: members);
    final maxTasks = workloads.values.fold<int>(
      0,
      (max, workload) => workload.taskCount > max ? workload.taskCount : max,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team'),
        actions: [
          IconButton(
            tooltip: 'Add member',
            onPressed: () => _showAddMemberForm(context),
            icon: const Icon(Icons.person_add_alt_1),
          ),
        ],
      ),
      body: members.isEmpty
          ? const Center(child: Text('No team members yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: members.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final member = members[index];
                final workload = workloads[member.id]!;
                final progress = maxTasks == 0
                    ? 0.0
                    : workload.taskCount / maxTasks;

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onOpenMemberTasks(member),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          MemberAvatar(member: member, radius: 22),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                Text(
                                  member.role,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                LinearProgressIndicator(value: progress),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${workload.taskCount} ${workload.taskCount == 1 ? 'task' : 'tasks'}',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              if (workload.overdueCount > 0)
                                _OverdueCount(count: workload.overdueCount),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.lg),
        child: FilledButton.icon(
          onPressed: () => _showAddMemberForm(context),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Add member'),
        ),
      ),
    );
  }
}

class _OverdueCount extends StatelessWidget {
  const _OverdueCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count overdue',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onErrorContainer,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AddMemberSheet extends StatefulWidget {
  const _AddMemberSheet({required this.members});

  final List<TeamMember> members;

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      TeamMember(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        role: _roleController.text.trim(),
        email: _emailController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        top: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add team member',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.words,
                validator: (value) => Validators.memberName(
                  value,
                  widget.members.map((member) => member.name).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Role'),
                textCapitalization: TextCapitalization.words,
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Role is required'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _save,
                child: const Text('Save member'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
