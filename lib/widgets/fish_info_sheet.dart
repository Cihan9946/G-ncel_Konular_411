import 'package:flutter/material.dart';

import '../models/fish_species.dart';
import '../theme/app_theme.dart';

Future<void> showFishInfoSheet(
  BuildContext context, {
  required FishSpecies fish,
  required bool isNew,
  required VoidCallback onDiscover,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _FishInfoSheet(fish: fish, isNew: isNew, onDiscover: onDiscover),
  );
}

class _FishInfoSheet extends StatelessWidget {
  const _FishInfoSheet({
    required this.fish,
    required this.isNew,
    required this.onDiscover,
  });

  final FishSpecies fish;
  final bool isNew;
  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.deepOcean,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.reefTeal, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(fish.emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 8),
          Text(
            fish.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          if (isNew)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Chip(
                label: const Text('Yeni keşif! +25 puan'),
                backgroundColor: AppColors.sand,
                labelStyle: const TextStyle(
                  color: AppColors.deepOcean,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 20),
          _InfoRow(icon: Icons.water, label: 'Yaşam alanı', value: fish.habitat),
          _InfoRow(icon: Icons.restaurant, label: 'Beslenme', value: fish.diet),
          _InfoRow(icon: Icons.vertical_align_bottom, label: 'Derinlik', value: fish.depth),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.oceanBlue.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              fish.fact,
              style: const TextStyle(fontSize: 16, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                onDiscover();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle),
              label: Text(isNew ? 'Keşfi Kaydet' : 'Tamam'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.reefTeal, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.bubble.withValues(alpha: 0.7), fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
