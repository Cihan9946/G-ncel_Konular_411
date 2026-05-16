import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/content_repository.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

class DiscoveryLogScreen extends StatelessWidget {
  const DiscoveryLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Keşif Defteri')),
      body: FutureBuilder(
        future: ContentRepository().loadFish(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allFish = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allFish.length,
            itemBuilder: (context, i) {
              final fish = allFish[i];
              final found = game.isFishDiscovered(fish.id);
              return Opacity(
                opacity: found ? 1 : 0.45,
                child: Card(
                  child: ListTile(
                    leading: Text(fish.emoji, style: const TextStyle(fontSize: 40)),
                    title: Text(
                      found ? fish.name : '???',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: found
                        ? Text(fish.fact, maxLines: 2, overflow: TextOverflow.ellipsis)
                        : const Text('Henüz keşfedilmedi'),
                    trailing: found
                        ? const Icon(Icons.check_circle, color: AppColors.reefTeal)
                        : const Icon(Icons.lock, color: Colors.white38),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
