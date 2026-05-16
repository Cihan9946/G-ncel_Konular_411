import 'package:flutter/material.dart';

import '../models/crew_role.dart';
import '../theme/app_theme.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role, this.compact = false});

  final CrewRole role;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 6 : 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.oceanBlue,
            AppColors.reefTeal.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.reefTeal, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(role.emoji, style: TextStyle(fontSize: compact ? 18 : 24)),
          const SizedBox(width: 8),
          Text(
            role.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}
