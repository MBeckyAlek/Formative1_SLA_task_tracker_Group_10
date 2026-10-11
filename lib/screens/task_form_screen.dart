import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/team_member.dart';
import '../models/enums.dart';
import '../core/utils/validators.dart';
import '../core/theme/app_spacing.dart';

class TaskFormScreen extends StatefulWidget {
  final List<TeamMember> members;
  final Task? existingTask;

  const TaskFormScreen({super.key, required this.members, this.existingTask});

  @override
  State<TaskFormScreen> createState() => TaskFormScreenState();
}

class TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  String? _assigneeId;
  Priority _priority = Priority.medium;
  DateTime? _deadline;
  TaskStatus _status = TaskStatus.todo;

  bool get _isNew => widget.existingTask == null;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');

    if (task != null) {
      _assigneeId = task.assigneeId;
      _priority = task.priority;
      _deadline = task.deadline;
      _status = task.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline(FormFieldState<DateTime> field) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? today,
      firstDate: _isNew ? today : DateTime(2026),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    setState(() => _deadline = picked);
    field.didChange(picked);
  }

  void _save() {
    // this runs every validator
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    final Task result;
    final existing = widget.existingTask;
    if (existing == null) {
      result = Task(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        description: description,
        assigneeId: _assigneeId!,
        priority: _priority,
        deadline: _deadline!,
        status: TaskStatus.todo,
        createdAt: DateTime.now(),
      );
    } else {
      result = existing.copyWith(
        title: title,
        description: description,
        assigneeId: _assigneeId,
        priority: _priority,
        deadline: _deadline,
        status: _status,
      );
    }
    Navigator.pop(context, result);
  }

  String _statusLabel(TaskStatus s) => switch (s) {
    TaskStatus.todo => 'To Do',
    TaskStatus.inProgress => 'In Progress',
    TaskStatus.done => 'Done',
  };

  String _priorityLabel(Priority p) => switch (p) {
    Priority.low => 'Low',
    Priority.medium => 'Medium',
    Priority.high => 'High',
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(_isNew ? 'New Task' : 'Edit Task')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: Validators.title,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description(optional)',
                  alignLabelWithHint: true,
                ),
                validator: Validators.description,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _assigneeId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Assigned to'),
                items: [
                  for (final m in widget.members)
                    DropdownMenuItem(value: m.id, child: Text(m.name)),
                ],
                onChanged: (value) => setState(() => _assigneeId = value),
                validator: Validators.assignee,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Priority', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              SegmentedButton<Priority>(
                segments: [
                  for (final p in Priority.values)
                    ButtonSegment(value: p, label: Text(_priorityLabel(p))),
                ],
                selected: {_priority},
                onSelectionChanged: (set) =>
                    setState(() => _priority = set.first),
              ),
              const SizedBox(height: AppSpacing.md),
              // show validation errors like a text field.
              FormField<DateTime>(
                initialValue: _deadline,
                validator: (_) =>
                    Validators.deadline(_deadline, isNewTask: _isNew),
                builder: (field) => InkWell(
                  onTap: () => _pickDeadline(field),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Deadline',
                      suffixIcon: const Icon(Icons.calendar_today),
                      errorText: field.errorText,
                    ),
                    child: Text(
                      _deadline == null
                          ? 'Pick a date'
                          : MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(_deadline!),
                    ),
                  ),
                ),
              ),
              //new tasks are set as to do.
              if (!_isNew) ...[
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<TaskStatus>(
                  initialValue: _status,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    for (final s in TaskStatus.values)
                      DropdownMenuItem(value: s, child: Text(_statusLabel(s))),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _save,
                child: Text(_isNew ? 'Create task' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}