import 'dart:math';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../data/fish_model_assets.dart';
import '../models/fish_species.dart';
import '../theme/app_theme.dart';

/// Kamera üzerinde GLB balık modeli (animasyonlu).
class ArFish3DOverlay extends StatefulWidget {
  const ArFish3DOverlay({
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
  State<ArFish3DOverlay> createState() => _ArFish3DOverlayState();
}

class _ArFish3DOverlayState extends State<ArFish3DOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _swim;
  bool _modelReady = false;

  String get _modelSrc =>
      FishModelAssets.pathFor(widget.fish.id) ?? FishModelAssets.balik1;

  @override
  void initState() {
    super.initState();
    _swim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2400 + widget.index * 350),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final positions = [
      const Alignment(-0.55, -0.15),
      const Alignment(0.48, 0.08),
      const Alignment(-0.15, 0.42),
      const Alignment(0.62, -0.3),
    ];
    final align = positions[widget.index % positions.length];
    const modelSize = 200.0;

    return Align(
      alignment: align,
      child: AnimatedBuilder(
        animation: _swim,
        builder: (context, child) {
          final drift = sin(_swim.value * pi * 2) * 14;
          return Transform.translate(
            offset: Offset(drift, drift * 0.35),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: modelSize,
                height: modelSize,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: (widget.discovered ? AppColors.sand : AppColors.reefTeal)
                        .withValues(alpha: 0.85),
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (!_modelReady)
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.reefTeal,
                          strokeWidth: 2,
                        ),
                      ),
                    IgnorePointer(
                      child: ModelViewer(
                        key: ValueKey(_modelSrc),
                        src: _modelSrc,
                        alt: widget.fish.name,
                        ar: false,
                        autoPlay: true,
                        autoRotate: true,
                        rotationPerSecond: '18deg',
                        cameraControls: false,
                        disablePan: true,
                        disableZoom: true,
                        disableTap: true,
                        interactionPrompt: InteractionPrompt.none,
                        backgroundColor: Colors.transparent,
                        onWebViewCreated: (_) {
                          if (mounted && !_modelReady) {
                            Future.delayed(const Duration(milliseconds: 800), () {
                              if (mounted) setState(() => _modelReady = true);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.discovered ? '✓ ${widget.fish.name}' : '3D · Dokun',
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
