// STUB by A: Person B overwrites this file
import '../models/task.dart';
import '../models/team_member.dart';

class StorageService {
  static Future<List<Task>> loadTasks() async => [];
  static Future<void> saveTasks(List<Task> tasks) async {}
  static Future<List<TeamMember>> loadMembers() async => [];
  static Future<void> saveMembers(List<TeamMember> members) async {}
  static Future<String?> loadCurrentUserId() async => null;
  static Future<void> saveCurrentUserId(String id) async {}
}
