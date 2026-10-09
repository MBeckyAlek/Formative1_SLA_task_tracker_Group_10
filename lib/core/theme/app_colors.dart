import 'package:flutter/material.dart';
import '../../models/enums.dart';

class AppColors {
  static const primary = Color(0xFF3F51B5);
  static const background = Color(0xFFF5F6FA);

  static const onTrack = Color(0xFF2E7D32);
  static const atRisk = Color(0xFFF9A825);
  static const overdue = Color(0xFFC62828);
  static const completed = Color(0xFF607D8B);

  static Color forSla(SlaStatus status) {
    switch (status) {
      case SlaStatus.onTrack:
        return onTrack;
      case SlaStatus.atRisk:
        return atRisk;
      case SlaStatus.overdue:
        return overdue;
      case SlaStatus.completed:
        return completed;
    }
  }
}
