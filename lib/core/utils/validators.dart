//Validation rules for the forms.

class Validators {
  static const int tMinLen = 3;
  static const int tMaxLen = 80;
  static const int dMaxLen = 500;

  static String? title(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Title is required';
    if (text.length < tMinLen) {
      return 'Title must be at least $tMinLen characters';
    }
    if (text.length > tMaxLen) {
      return 'Title is more than $tMaxLen characters';
    }
    return null;
  }

  static String? description(String? value) {
    final text = value?.trim() ?? '';
    if (text.length > dMaxLen) {
      return 'Description is more than $dMaxLen characters';
    }
    return null;
  }

  static String? assignee(String? value) {
    if (value == null || value.isEmpty) return 'Please choose who this is assigned to';
    return null;
  }

  //A deadline is required. For a new task it cannot be before the present day

  static String? deadline(
      DateTime? value, {
        required bool isNewTask,
        DateTime? now,
      }) {
    if (value == null) return 'Please pick a deadline';
    if (isNewTask) {
      final current = now ?? DateTime.now();
      final today = DateTime(current.year, current.month, current.day);
      final picked = DateTime(value.year, value.month, value.day);
      if (picked.isBefore(today)) return 'Deadline cannot be in the past';
    }
    return null;
  }
  static String? memberName(String? value, List<String> existingNames) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Name is required';
    final lower = text.toLowerCase();
    final exists = existingNames.any((n) => n.trim().toLowerCase() == lower);
    if (exists) return 'A member with this name already exists';
    return null;
  }

  //email regex validation
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }
}