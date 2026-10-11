import 'package:flutter/material.dart';
import '../core/theme/app_spacing.dart';
import '../models/enums.dart';
import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/sla_badge.dart';
import '../widgets/task_card.dart';

/// Shows all tasks with a search box, status filters and swipe-to-delete
/// This screen does not own any task data
/// HomeShell gives it the list and we tell HomeShell what the user did through the two callbacks
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({
    super.key,
    required this.tasks,
    required this.members,
    this.initialFilter,
    required this.onOpenTask,
    required this.onDeleteTask,
  });

  final List<Task> tasks;
  final List<TeamMember> members;

  /// Status filter is selected when the screen opens. The Dashboard sets it when a status card is tapped
  final SlaStatus? initialFilter;

  final void Function(Task task) onOpenTask;
  final void Function(Task task) onDeleteTask;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();

  // The two things the user can change on this screen
  String _searchText = '';
  SlaStatus? _selectedStatus; // null = All

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialFilter;
  }

  @override
  void didUpdateWidget(TaskListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFilter != oldWidget.initialFilter) {
      _selectedStatus = widget.initialFilter;
    }
  }

  @override
  void dispose() {
    // Controllers must always be disposed to free their memory
    _searchController.dispose();
    super.dispose();
  }

  // Filtering and sorting
  /// Applies the search text and the status filter, then sorts
  List<Task> _getVisibleTasks() {
    final query = _searchText.trim().toLowerCase();

    final result = widget.tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(query);
      final matchesStatus =
          _selectedStatus == null || SlaService.compute(task) == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    result.sort(_compareTasks);
    return result;
  }

  /// Overdue first, then At Risk, then On Track, then Completed
  /// Tasks with the same status are ordered by deadline
  int _compareTasks(Task a, Task b) {
    final rankA = _statusRank(SlaService.compute(a));
    final rankB = _statusRank(SlaService.compute(b));
    if (rankA != rankB) return rankA.compareTo(rankB);
    return a.deadline.compareTo(b.deadline);
  }

  /// A smaller number is shown higher in the list
  int _statusRank(SlaStatus status) {
    return switch (status) {
      SlaStatus.overdue => 0,
      SlaStatus.atRisk => 1,
      SlaStatus.onTrack => 2,
      SlaStatus.completed => 3,
    };
  }

  // ui
  @override
  Widget build(BuildContext context) {
    final visibleTasks = _getVisibleTasks();

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Column(
        children: [
          _buildSearchField(),
          _buildFilterChips(),
          Expanded(child: _buildTaskList(visibleTasks)),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search tasks by title',
          prefixIcon: const Icon(Icons.search),
          // Show the clear button only when there is something to clear
          suffixIcon: _searchText.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchText = '');
                  },
                ),
        ),
        //the list filters as you type
        onChanged: (value) => setState(() => _searchText = value),
      ),
    );
  }

  /// "All, On Track, At Risk, Overdue, Completed" in a row that scrolls sideways
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _buildFilterChip(label: 'All', status: null),
          // SlaStatus.values is in the order: onTrack, atRisk, overdue, completed.
          for (final status in SlaStatus.values)
            _buildFilterChip(label: SlaBadge.labelFor(status), status: status),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required SlaStatus? status}) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: _selectedStatus == status,
        onSelected: (_) => setState(() => _selectedStatus = status),
      ),
    );
  }

  Widget _buildTaskList(List<Task> visibleTasks) {
    if (visibleTasks.isEmpty) {
      // Two different empty states: no tasks at all, or nothing matches
      final noTasksAtAll = widget.tasks.isEmpty;
      return EmptyState(
        icon: noTasksAtAll ? Icons.inbox_outlined : Icons.search_off,
        message: noTasksAtAll
            ? 'No tasks yet.'
            : 'No tasks match your search or filters.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: visibleTasks.length,
      itemBuilder: (context, index) {
        final task = visibleTasks[index];

        return Dismissible(
          // The key tells Flutter which task this row is, even when the
          // list changes order. The task id is unique, so it is a safe key
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart, // swipe left only
          background: _buildDeleteBackground(context),
          // Ask first. Only a "true" answer lets the card slide away
          confirmDismiss: (direction) => confirmDeleteTask(context, task),
          // this runs after the card has slid away; tell HomeShell to delete it
          onDismissed: (direction) => widget.onDeleteTask(task),
          child: TaskCard(
            task: task,
            members: widget.members,
            onTap: () => widget.onOpenTask(task),
          ),
        );
      },
    );
  }

  /// This is the red area with a bin icon that appears behind the card while swiping
  Widget _buildDeleteBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.delete_outline, color: colorScheme.onError),
    );
  }
}