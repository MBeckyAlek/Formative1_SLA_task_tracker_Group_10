import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/task.dart';
import '../models/team_member.dart';
import 'seed_data.dart';

class StorageService {
  static Future<List<Task>> loadTasks() =>
      _loadList(AppConstants.tasksKey, Task.fromJson, SeedData.tasks);

  static Future<void> saveTasks(List<Task> tasks) =>
      _saveList(AppConstants.tasksKey, tasks.map((t) => t.toJson()).toList());

  static Future<List<TeamMember>> loadMembers() =>
      _loadList(AppConstants.membersKey, TeamMember.fromJson, SeedData.members);

  static Future<void> saveMembers(List<TeamMember> members) => _saveList(
    AppConstants.membersKey,
    members.map((m) => m.toJson()).toList(),
  );

  static Future<String?> loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.currentUserKey);
  }

  static Future<void> saveCurrentUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.currentUserKey, id);
  }

  static Future<List<T>> _loadList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
    List<T> fallback,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return List<T>.of(fallback);
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return List<T>.of(fallback);
    }
  }

  static Future<void> _saveList(
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(items));
  }
}
