import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BigActionButton extends StatelessWidget {
  const BigActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
    this.subtitle,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.reefTeal;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(24),
      elevation: 6,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              Icon(icon, size: 36, color: AppColors.deepOcean),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.deepOcean,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.deepOcean.withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.deepOcean, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
