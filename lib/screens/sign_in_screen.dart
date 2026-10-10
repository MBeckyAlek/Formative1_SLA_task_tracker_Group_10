import 'package:flutter/material.dart';

import '../app_router.dart';
import '../core/theme/app_spacing.dart';
import '../models/team_member.dart';
import '../services/storage_service.dart';
import '../widgets/member_avatar.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  List<TeamMember> _members = [];
  String? _selectedId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final members = await StorageService.loadMembers();
      final savedId = await StorageService.loadCurrentUserId();
      if (!mounted) return;

      final alreadySignedIn =
          savedId != null &&
          savedId.isNotEmpty &&
          members.any((m) => m.id == savedId);
      if (alreadySignedIn) {
        Navigator.pushReplacementNamed(context, Routes.home);
        return;
      }
      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Could not load team members.');
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _continue() async {
    final id = _selectedId;
    if (id == null) return;
    try {
      await StorageService.saveCurrentUserId(id);
    } catch (e) {
      _showMessage('Could not save your choice.');
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Image.asset(
                      'assets/images/app_icon.jpeg',
                      height: 96,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.checklist,
                        size: 80,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Task Tracker',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Who are you?',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _members.length,
                        itemBuilder: (context, i) {
                          final m = _members[i];
                          final selected = m.id == _selectedId;
                          return Card(
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              selected: selected,
                              selectedTileColor: scheme.primaryContainer,
                              leading: MemberAvatar(member: m),
                              title: Text(m.name),
                              subtitle: Text(m.role),
                              trailing: selected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: scheme.primary,
                                    )
                                  : null,
                              onTap: () => setState(() => _selectedId = m.id),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: _selectedId == null ? null : _continue,
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
