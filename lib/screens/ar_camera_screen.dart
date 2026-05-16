import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/crew_role.dart';
import '../models/fish_species.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ar_fish_overlay.dart';
import '../widgets/fish_info_sheet.dart';
import '../widgets/puzzle_panel.dart';

/// AR ekranı: arka planda sürekli canlı kamera, üstte 3D/emoji balıklar.
/// QR tarama ve AR aynı kamera akışında — siyah ekran / ikinci kamera yok.
class ArCameraScreen extends StatefulWidget {
  const ArCameraScreen({super.key});

  @override
  State<ArCameraScreen> createState() => _ArCameraScreenState();
}

class _ArCameraScreenState extends State<ArCameraScreen> {
  MobileScannerController? _scanner;
  bool _permissionDenied = false;
  bool _processingQr = false;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  Future<void> _initScanner() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) setState(() => _permissionDenied = true);
      return;
    }
    final controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      formats: const [BarcodeFormat.qrCode],
    );
    if (mounted) {
      setState(() => _scanner = controller);
    } else {
      await controller.dispose();
    }
  }

  @override
  void dispose() {
    _scanner?.dispose();
    super.dispose();
  }

  Future<void> _onQrDetected(String raw) async {
    if (_processingQr) return;
    final game = context.read<GameProvider>();
    if (game.activeStation != null) return;

    _processingQr = true;
    final ok = await game.activateStation(raw);
    if (!mounted) return;
    _processingQr = false;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İstasyon bulundu: ${game.activeStation!.title}'),
          backgroundColor: AppColors.reefTeal,
        ),
      );
    }
  }

  Future<void> _onFishTap(FishSpecies fish) async {
    final game = context.read<GameProvider>();
    final role = game.playerRole;

    if (role == CrewRole.gozcu) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gözcü: Biyoloğa balığı bildir!')),
      );
      return;
    }

    if (role != CrewRole.biyolog && role != CrewRole.kaptan) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu balığı incelemek için Biyolog rolü gerekli.')),
      );
      return;
    }

    final already = game.isFishDiscovered(fish.id);
    await showFishInfoSheet(
      context,
      fish: fish,
      isNew: !already,
      onDiscover: () async {
        if (!already) {
          final isNew = await game.discoverFish(fish);
          if (mounted && isNew) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('+25 puan kazandınız!')),
            );
          }
        }
      },
    );
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    final game = context.read<GameProvider>();
    if (game.activeStation != null) return;

    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw != null && raw.toUpperCase().startsWith('DDM-')) {
        _onQrDetected(raw);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final role = game.playerRole;
    final hasStation = game.activeStation != null;

    if (_permissionDenied) {
      return Scaffold(
        appBar: AppBar(title: const Text('AR Kamera')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.no_photography, size: 64, color: AppColors.coral),
                const SizedBox(height: 16),
                const Text(
                  'Kamera izni gerekli',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => openAppSettings(),
                  child: const Text('Ayarlara Git'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildLiveCamera(),
          if (hasStation) ..._buildArLayer(game),
          if (!hasStation) _buildQrScanOverlay(role),
          _buildHud(context, game, role, hasStation),
        ],
      ),
    );
  }

  /// Her zaman arka kamera — QR ve AR aynı görüntü üzerinde.
  Widget _buildLiveCamera() {
    if (_scanner == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.reefTeal),
              SizedBox(height: 16),
              Text('Kamera açılıyor...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return MobileScanner(
      controller: _scanner,
      fit: BoxFit.cover,
      onDetect: _onBarcodeDetect,
    );
  }

  /// QR tarama modunda hafif çerçeve (kamera görünür kalır).
  Widget _buildQrScanOverlay(CrewRole? role) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.reefTeal.withValues(alpha: 0.6), width: 2),
        ),
        child: CustomPaint(
          painter: _QrFramePainter(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  List<Widget> _buildArLayer(GameProvider game) {
    return [
      // Hafif vignette — balıklar kameranın üstünde okunaklı kalsın
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.12),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.2),
            ],
          ),
        ),
      ),
      ...game.stationFish.asMap().entries.map(
            (e) => ArFishOverlay(
              fish: e.value,
              index: e.key,
              discovered: game.isFishDiscovered(e.value.id),
              onTap: () => _onFishTap(e.value),
            ),
          ),
      if (game.playerRole == CrewRole.biyolog && !game.puzzleSolved)
        Positioned(
          left: 16,
          right: 16,
          bottom: 140,
          child: PuzzlePanel(
            puzzleType: game.activeStation!.puzzleType,
            stationTitle: game.activeStation!.title,
            onSolved: () => game.completePuzzle(),
          ),
        ),
    ];
  }

  Widget _buildHud(
    BuildContext context,
    GameProvider game,
    CrewRole? role,
    bool hasStation,
  ) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: AppColors.panel),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hasStation
                          ? '📍 ${game.activeStation!.title} · AR aktif'
                          : role == CrewRole.gozcu
                              ? 'QR işaretçiyi kameraya tut'
                              : 'Gözcü QR tarayınca balıklar görünür',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                if (hasStation)
                  IconButton(
                    tooltip: 'Yeni istasyon tara',
                    onPressed: () {
                      game.clearActiveStation();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Yeni QR tarayabilirsiniz'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: AppColors.panel),
                  ),
              ],
            ),
          ),
          if (!hasStation && role == CrewRole.kaptan)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.oceanBlue.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  game.lastCaptainHint ?? 'İpucu vermek için ana ekrana dön',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const Spacer(),
          if (!hasStation)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Kamera açık — QR kodu çerçeveye getirin\nDDM-REEF-01 · DDM-GRASS-02 · DDM-SAND-03',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 13, shadows: [
                      Shadow(blurRadius: 8, color: Colors.black),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  if (role == CrewRole.gozcu ||
                      role == CrewRole.kaptan ||
                      role == CrewRole.biyolog)
                    ElevatedButton.icon(
                      onPressed: () => game.activateStationById('STATION_REEF'),
                      icon: const Icon(Icons.science),
                      label: const Text('Demo: Resif (3D balıklar)'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// QR tarama köşe çerçevesi (kamera üstünde).
class _QrFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.reefTeal
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const len = 40.0;
    final margin = size.shortestSide * 0.12;
    final rect = Rect.fromLTWH(
      margin,
      size.height * 0.28,
      size.width - margin * 2,
      size.height * 0.38,
    );

    // Köşe L çizgileri
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(len, 0), paint);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, len), paint);

    canvas.drawLine(rect.topRight, rect.topRight + const Offset(-len, 0), paint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, len), paint);

    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(len, 0), paint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(0, -len), paint);

    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(-len, 0), paint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(0, -len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
