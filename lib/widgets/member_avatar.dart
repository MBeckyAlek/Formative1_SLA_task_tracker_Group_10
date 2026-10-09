import 'package:flutter/material.dart';
import '../../models/team_member.dart';

class MemberAvatar extends StatelessWidget {
  final TeamMember member;
  final double radius;

  const MemberAvatar({super.key, required this.member, this.radius = 20});

  static const _palette = [
    Color(0xFF3F51B5),
    Color(0xFF00897B),
    Color(0xFF8E24AA),
    Color(0xFFEF6C00),
    Color(0xFF1E88E5),
  ];

  String get _initials {
    final parts = member.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final index =
        member.id.codeUnits.fold<int>(0, (sum, c) => sum + c) % _palette.length;
    return CircleAvatar(
      radius: radius,
      backgroundColor: _palette[index],
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
