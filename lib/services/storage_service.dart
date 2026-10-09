import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/task.dart';
import '../models/team_member.dart';

//we're saving everything as json
class StorageService {
  //tasks
  static Future<List<Task>> loadTasks() =>
      _loadList(AppConstants.tasksKey, Task.fromJson);

  static Future<void> saveTasks(List<Task> tasks) =>
      _saveList(AppConstants.tasksKey, tasks.map((t) => t.toJson()).toList());

  //team members
  static Future<List<TeamMember>> loadMembers() =>
      _loadList(AppConstants.membersKey, TeamMember.fromJson);

  static Future<void> saveMembers(List<TeamMember> members) => _saveList(
    AppConstants.membersKey, members.map((m) => m.toJson()).toList());

  //current user
  static Future<String?> loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.currentUserKey);
  }

  static Future<void> saveCurrentUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.currentUserKey, id);
  }

  //helper functions below. y'all can use these instead of repeating the same code for tasks and members

  // this function reads the json list and converts each item back to an object
  static Future<List<T>> _loadList<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson
      ) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final raw = prefs.getString(key);
          if (raw == null) return [];
          final decoded = jsonDecode(raw) as List<dynamic>;
          return decoded
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList();
        } catch (_) {
          return [];
        }
    }

  //this turns a list of maps into json text and saves it
  static Future<void> _saveList(
      String key, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(items));
  }
}
