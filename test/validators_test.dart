// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter_test/flutter_test.dart';

import '../lib/core/utils/validators.dart';

void main() {
  group('title', () {
    test('null, empty and spaces-only are rejected', () {
      expect(Validators.title(null), isNotNull);
      expect(Validators.title(''), isNotNull);
      expect(Validators.title('     '), isNotNull);
    });

    test('too short (2 characters) is rejected', () {
      expect(Validators.title('ab'), isNotNull);
    });

    test('3 characters is accepted', () {
      expect(Validators.title('abc'), isNull);
    });

    test('spaces around the text are ignored', () {
      expect(Validators.title('  ab  '), isNotNull);
    });

    test('80 characters is accepted, 81 is rejected', () {
      expect(Validators.title('a' * 80), isNull);
      expect(Validators.title('a' * 81), isNotNull);
    });
  });

  group('description', () {
    test('empty or null is fine', () {
      expect(Validators.description(null), isNull);
      expect(Validators.description(''), isNull);
    });

    test('500 is accepted, 501 is rejected', () {
      expect(Validators.description('a' * 500), isNull);
      expect(Validators.description('a' * 501), isNotNull);
    });
  });

  group('assignee', () {
    test('null or empty is rejected', () {
      expect(Validators.assignee(null), isNotNull);
      expect(Validators.assignee(''), isNotNull);
    });

    test('a chosen id is accepted', () {
      expect(Validators.assignee('m1'), isNull);
    });
  });

  group('deadline', () {
    final now = DateTime(2026, 10, 12, 15, 0);

    test('missing deadline is rejected', () {
      expect(Validators.deadline(null, isNewTask: true, now: now), isNotNull);
    });

    test('past date is rejected for a new task', () {
      expect(
          Validators.deadline(DateTime(2026, 10, 11), isNewTask: true, now: now),
          isNotNull);
    });

    test('today is accepted for a new task', () {
      expect(
          Validators.deadline(DateTime(2026, 10, 12), isNewTask: true, now: now),
          isNull);
    });

    test('past date is accepted when editing', () {
      expect(
          Validators.deadline(DateTime(2026, 10, 1), isNewTask: false, now: now),
          isNull);
    });
  });

  group('memberName', () {
    final existing = ['Alek Alek', 'Janna Vitalina'];

    test('empty is rejected', () {
      expect(Validators.memberName('  ', existing), isNotNull);
    });

    test('duplicate is rejected ignoring case and spaces', () {
      expect(Validators.memberName(' alek alek ', existing), isNotNull);
    });

    test('a new name is accepted', () {
      expect(Validators.memberName('Peniel Lee', existing), isNull);
    });
  });

  group('email', () {
    test('empty is rejected', () {
      expect(Validators.email(''), isNotNull);
    });

    test('invalid formats are rejected', () {
      expect(Validators.email('plainaddress'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
      expect(Validators.email('a b@c.com'), isNotNull);
    });

    test('valid email is accepted', () {
      expect(Validators.email('alek@example.com'), isNull);
    });
  });
}