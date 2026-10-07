import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/enums.dart';

class SlaBadge extends StatelessWidget {
  const SlaBadge({super.key, required this.status});

  final SlaStatus status;


  static Color colorFor(SlaStatus status) {
    return switch (status) {
      SlaStatus.onTrack => AppColors.onTrack,
      SlaStatus.atRisk => AppColors.atRisk,
      SlaStatus.overdue => AppColors.overdue,
      SlaStatus.completed => AppColors.completed,
    };
  }

  static String labelFor(SlaStatus status) {
    return switch (status) {
      SlaStatus.onTrack => 'On Track',
      SlaStatus.atRisk => 'At Risk',
      SlaStatus.overdue => 'Overdue',
      SlaStatus.completed => 'Completed',
    };
  }

  static IconData iconFor(SlaStatus status) {
    return switch (status) {
      SlaStatus.onTrack => Icons.schedule,
      SlaStatus.atRisk => Icons.warning_amber_rounded,
      SlaStatus.overdue => Icons.error_outline,
      SlaStatus.completed => Icons.check_circle_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconFor(status), size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),

          Text(
            labelFor(status),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}