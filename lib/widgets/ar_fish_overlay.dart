import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/fish_model_assets.dart';
import '../models/fish_species.dart';
import '../theme/app_theme.dart';
import 'ar_fish_3d_overlay.dart';

class ArFishOverlay extends StatefulWidget {
  const ArFishOverlay({
    super.key,
    required this.fish,
    required this.index,
    required this.onTap,
    this.discovered = false,
  });

  final FishSpecies fish;
  final int index;
  final VoidCallback onTap;
  final bool discovered;

  @override
  State<ArFishOverlay> createState() => _ArFishOverlayState();
}

class _ArFishOverlayState extends State<ArFishOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _swim;

  @override
  void initState() {
    super.initState();
    _swim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2200 + widget.index * 300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (FishModelAssets.hasModel(widget.fish.id)) {
      return ArFish3DOverlay(
        fish: widget.fish,
        index: widget.index,
        onTap: widget.onTap,
        discovered: widget.discovered,
      );
    }

    final positions = [
      const Alignment(-0.6, -0.2),
      const Alignment(0.5, 0.1),
      const Alignment(-0.2, 0.45),
      const Alignment(0.65, -0.35),
    ];
    final align = positions[widget.index % positions.length];

    return Align(
      alignment: align,
      child: AnimatedBuilder(
        animation: _swim,
        builder: (context, child) {
          final drift = sin(_swim.value * pi * 2) * 12;
          return Transform.translate(
            offset: Offset(drift, drift * 0.4),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.reefTeal.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: widget.discovered ? AppColors.sand : AppColors.reefTeal,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.reefTeal.withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  widget.fish.emoji,
                  style: const TextStyle(fontSize: 56),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2.seconds, color: Colors.white24),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.discovered ? '✓ ${widget.fish.name}' : '? Dokun',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
