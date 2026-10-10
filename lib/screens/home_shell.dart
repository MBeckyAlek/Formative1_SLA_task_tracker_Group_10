import 'package:flutter/material.dart';

import '../app_router.dart';
import '../models/enums.dart';
import '../models/task.dart';
import '../models/team_member.dart';
import '../services/seed_data.dart';
import '../services/storage_service.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'task_list_screen.dart';
import 'team_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  List<Task> tasks = [];
  List<TeamMember> members = [];
  TeamMember? currentUser;
  bool _loading = true;
  int _tabIndex = 0;
  SlaStatus? _listFilter;
  String? _memberFilterId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final loadedMembers = await StorageService.loadMembers();
      final loadedTasks = await StorageService.loadTasks();
      final userId = await StorageService.loadCurrentUserId();

      TeamMember? user;
      for (final m in loadedMembers) {
        if (m.id == userId) user = m;
      }

      if (!mounted) return;
      if (user == null) {
        // Nobody signed in: go back to Sign In.
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.signIn,
          (route) => false,
        );
        return;
      }
      setState(() {
        members = loadedMembers;
        tasks = loadedTasks;
        currentUser = user;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Could not load saved data.');
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // Every change follows the same order: build new list, save, setState.
  Future<void> _persistTasks(List<Task> updated) async {
    try {
      await StorageService.saveTasks(updated);
      if (!mounted) return;
      setState(() => tasks = updated);
    } catch (e) {
      _showMessage('Could not save your changes.');
    }
  }

  Future<void> saveTask(Task task) async {
    final updated = [...tasks];
    final i = updated.indexWhere((t) => t.id == task.id);
    if (i == -1) {
      updated.add(task);
    } else {
      updated[i] = task;
    }
    await _persistTasks(updated);
  }

  Future<void> deleteTask(Task task) =>
      _persistTasks(tasks.where((t) => t.id != task.id).toList());

  Future<void> changeStatus(Task task, TaskStatus status) =>
      saveTask(task.copyWith(status: status));

  Future<void> addMember(TeamMember member) async {
    final updated = [...members, member];
    try {
      await StorageService.saveMembers(updated);
      if (!mounted) return;
      setState(() => members = updated);
    } catch (e) {
      _showMessage('Could not save the new member.');
    }
  }

  Future<void> switchUser() async {
    try {
      await StorageService.saveCurrentUserId('');
    } catch (e) {
      _showMessage('Could not switch user.');
      return;
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, Routes.signIn, (route) => false);
  }

  Future<void> clearData() async {
    try {
      await StorageService.saveTasks(SeedData.tasks);
      await StorageService.saveMembers(SeedData.members);
      await StorageService.saveCurrentUserId('');
    } catch (e) {
      _showMessage('Could not clear data.');
      return;
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, Routes.signIn, (route) => false);
  }

  Future<void> _openNewTask() async {
    final saved = await Navigator.pushNamed<Task>(
      context,
      Routes.taskForm,
      arguments: TaskFormArgs(members: members),
    );
    if (saved != null) await saveTask(saved);
  }

  Future<void> _editTask(Task task) async {
    final saved = await Navigator.pushNamed<Task>(
      context,
      Routes.taskForm,
      arguments: TaskFormArgs(members: members, existingTask: task),
    );
    if (saved != null) {
      await saveTask(saved);
      if (mounted) Navigator.pop(context); // close the old Details screen
    }
  }

  void openTask(Task task) {
    Navigator.pushNamed(
      context,
      Routes.taskDetails,
      arguments: TaskDetailsArgs(
        task: task,
        members: members,
        onStatusChanged: changeStatus,
        onEdit: _editTask,
        onDelete: deleteTask,
      ),
    );
  }

  void _openListWithFilter(SlaStatus status) {
    setState(() {
      _listFilter = status;
      _memberFilterId = null;
      _tabIndex = 1;
    });
  }

  void _openMemberTasks(TeamMember member) {
    setState(() {
      _memberFilterId = member.id;
      _listFilter = null;
      _tabIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    if (_loading || user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final listTasks = _memberFilterId == null
        ? tasks
        : tasks.where((t) => t.assigneeId == _memberFilterId).toList();

    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: [
          DashboardScreen(
            tasks: tasks,
            members: members,
            currentUser: user,
            onOpenTask: openTask,
            onOpenListWithFilter: _openListWithFilter,
          ),
          TaskListScreen(
            key: ValueKey('$_listFilter-$_memberFilterId'),
            tasks: listTasks,
            members: members,
            initialFilter: _listFilter,
            onOpenTask: openTask,
            onDeleteTask: deleteTask,
          ),
          TeamScreen(
            tasks: tasks,
            members: members,
            onAddMember: addMember,
            onOpenMemberTasks: _openMemberTasks,
          ),
          ProfileScreen(
            currentUser: user,
            tasks: tasks,
            onSwitchUser: switchUser,
            onClearData: clearData,
          ),
        ],
      ),
      floatingActionButton: _tabIndex <= 1
          ? FloatingActionButton.extended(
              onPressed: _openNewTask,
              icon: const Icon(Icons.add),
              label: const Text('New Task'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() {
          _tabIndex = i;
          if (i == 1) {
            _listFilter = null;
            _memberFilterId = null;
          }
        }),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Team',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
