import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/crew_role.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/big_action_button.dart';
import '../widgets/role_badge.dart';
import 'ar_camera_screen.dart';
import 'discovery_log_screen.dart';
import 'station_map_screen.dart';

class RoleHomeScreen extends StatefulWidget {
  const RoleHomeScreen({super.key});

  @override
  State<RoleHomeScreen> createState() => _RoleHomeScreenState();
}

class _RoleHomeScreenState extends State<RoleHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().refreshScore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final role = game.playerRole!;

    return Scaffold(
      appBar: AppBar(
        title: Text(game.teamName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Chip(
                avatar: const Icon(Icons.star, color: AppColors.sand, size: 18),
                label: Text(
                  '${game.score} puan',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: AppColors.oceanBlue,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.oceanBlue, AppColors.deepOcean],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(child: RoleBadge(role: role)),
              const SizedBox(height: 8),
              Text(
                role.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.bubble.withValues(alpha: 0.9), fontSize: 16),
              ),
              const SizedBox(height: 24),
              _MissionPanel(role: role),
              const SizedBox(height: 24),
              if (role == CrewRole.kaptan) _CaptainPanel(game: game),
              if (role == CrewRole.gozcu) _ScoutPanel(game: game),
              if (role == CrewRole.biyolog) _BiologistPanel(game: game),
              const SizedBox(height: 16),
              BigActionButton(
                label: 'AR Kamera',
                subtitle: 'İşaretçiyi tara, balıkları keşfet',
                icon: Icons.camera_alt,
                color: AppColors.coral,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const ArCameraScreen()),
                ),
              ),
              const SizedBox(height: 12),
              BigActionButton(
                label: 'İstasyon Haritası',
                subtitle: 'Akvaryum bölgeleri ve ipuçları',
                icon: Icons.map,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const StationMapScreen()),
                ),
              ),
              const SizedBox(height: 12),
              BigActionButton(
                label: 'Keşif Defteri',
                subtitle: '${game.discoveryCount} balık kayıtlı',
                icon: Icons.menu_book,
                color: AppColors.sand,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const DiscoveryLogScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionPanel extends StatelessWidget {
  const _MissionPanel({required this.role});

  final CrewRole role;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Görevlerin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.sand)),
            const SizedBox(height: 12),
            ...role.missions.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.reefTeal,
                          child: Text('${e.key + 1}', style: const TextStyle(color: AppColors.deepOcean, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(e.value)),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _CaptainPanel extends StatelessWidget {
  const _CaptainPanel({required this.game});

  final GameProvider game;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('⚓ Komuta Paneli', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.sand)),
            const SizedBox(height: 8),
            const Text('Gözcüye verilecek ipucu seç:'),
            const SizedBox(height: 8),
            ...game.allStations.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: OutlinedButton(
                    onPressed: () {
                      game.setCaptainHint(s);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('İpucu gönderildi: ${s.title}')),
                      );
                    },
                    child: Text(s.title),
                  ),
                )),
            if (game.lastCaptainHint != null) ...[
              const SizedBox(height: 8),
              Text('Son ipucu: ${game.lastCaptainHint}', style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoutPanel extends StatelessWidget {
  const _ScoutPanel({required this.game});

  final GameProvider game;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔭 Gözcü Durumu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.sand)),
            const SizedBox(height: 8),
            if (game.lastCaptainHint != null)
              Text('Kaptanın ipucu:\n${game.lastCaptainHint}', style: const TextStyle(fontSize: 15))
            else
              const Text('Kaptan henüz ipucu vermedi. Bekle veya haritaya bak!'),
            const SizedBox(height: 8),
            Text('Tamamlanan istasyon: ${game.completedStations.length}/${game.allStations.length}'),
          ],
        ),
      ),
    );
  }
}

class _BiologistPanel extends StatelessWidget {
  const _BiologistPanel({required this.game});

  final GameProvider game;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔬 Biyolog Notları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.sand)),
            const SizedBox(height: 8),
            Text('Keşfedilen tür: ${game.discoveryCount} / 6'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: game.discoveryCount / 6,
              backgroundColor: AppColors.deepOcean,
              color: AppColors.reefTeal,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
  }
}
