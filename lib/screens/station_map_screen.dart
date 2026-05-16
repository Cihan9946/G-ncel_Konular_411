import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

class StationMapScreen extends StatelessWidget {
  const StationMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Akvaryum İstasyonları')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: game.allStations.length,
        itemBuilder: (context, i) {
          final s = game.allStations[i];
          final done = game.completedStations.contains(s.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: done ? AppColors.reefTeal : AppColors.oceanBlue,
                child: Icon(done ? Icons.check : Icons.place, color: Colors.white),
              ),
              title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.hint),
                  const SizedBox(height: 4),
                  Text(
                    'QR: ${s.qrCode}',
                    style: TextStyle(color: AppColors.bubble.withValues(alpha: 0.6), fontSize: 12),
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: game.playerRole == null
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.play_arrow, color: AppColors.sand),
                      onPressed: () async {
                        await game.activateStationById(s.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${s.title} AR moduna hazır — kameraya git!')),
                          );
                        }
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
