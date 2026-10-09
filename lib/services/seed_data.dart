import '../models/enums.dart';
import '../models/task.dart';
import '../models/team_member.dart';

class SeedData {
  static DateTime _daysFromToday(int days) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + days);
  }

  static List<TeamMember> get members => const [
    TeamMember(
      id: 'm1',
      name: 'Alex Morgan',
      role: 'Project Lead',
      email: 'alex@example.com',
    ),
    TeamMember(
      id: 'm2',
      name: 'Sam Rivera',
      role: 'Backend Developer',
      email: 'sam@example.com',
    ),
    TeamMember(
      id: 'm3',
      name: 'Jordan Lee',
      role: 'Frontend Developer',
      email: 'jordan@example.com',
    ),
    TeamMember(
      id: 'm4',
      name: 'Taylor Kim',
      role: 'QA Engineer',
      email: 'taylor@example.com',
    ),
  ];

  static List<Task> get tasks => [
    Task(
      id: 't1',
      title: 'Set up project repository',
      description: 'Create the repo, branches and CI.',
      assigneeId: 'm1',
      priority: Priority.medium,
      deadline: _daysFromToday(-2),
      status: TaskStatus.done,
      createdAt: _daysFromToday(-9),
    ),
    Task(
      id: 't2',
      title: 'Design database schema',
      description: 'Define tables for users and projects.',
      assigneeId: 'm2',
      priority: Priority.high,
      deadline: _daysFromToday(-3),
      status: TaskStatus.inProgress,
      createdAt: _daysFromToday(-10),
    ),
    Task(
      id: 't3',
      title: 'Write onboarding guide',
      description: 'Short guide for new team members.',
      assigneeId: 'm1',
      priority: Priority.medium,
      deadline: _daysFromToday(-1),
      status: TaskStatus.todo,
      createdAt: _daysFromToday(-8),
    ),
    Task(
      id: 't4',
      title: 'Build login screen',
      description: 'Sign in with user selection.',
      assigneeId: 'm3',
      priority: Priority.medium,
      deadline: _daysFromToday(1),
      status: TaskStatus.inProgress,
      createdAt: _daysFromToday(-5),
    ),
    Task(
      id: 't5',
      title: 'Fix payment bug',
      description: 'Customers see the wrong total at checkout.',
      assigneeId: 'm2',
      priority: Priority.high,
      deadline: _daysFromToday(2),
      status: TaskStatus.todo,
      createdAt: _daysFromToday(-3),
    ),
    Task(
      id: 't6',
      title: 'Plan test cases',
      description: 'List test cases for the main flows.',
      assigneeId: 'm4',
      priority: Priority.low,
      deadline: _daysFromToday(10),
      status: TaskStatus.todo,
      createdAt: _daysFromToday(-2),
    ),
    Task(
      id: 't7',
      title: 'Create dashboard layout',
      description: 'Progress ring and status cards.',
      assigneeId: 'm3',
      priority: Priority.medium,
      deadline: _daysFromToday(6),
      status: TaskStatus.inProgress,
      createdAt: _daysFromToday(-4),
    ),
    Task(
      id: 't8',
      title: 'Add data validation',
      description: 'Validate all form inputs.',
      assigneeId: 'm2',
      priority: Priority.high,
      deadline: _daysFromToday(5),
      status: TaskStatus.inProgress,
      createdAt: _daysFromToday(-3),
    ),
  ];
}
