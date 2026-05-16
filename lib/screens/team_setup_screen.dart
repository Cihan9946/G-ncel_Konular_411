import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/crew_role.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import 'role_home_screen.dart';

class TeamSetupScreen extends StatefulWidget {
  const TeamSetupScreen({super.key});

  @override
  State<TeamSetupScreen> createState() => _TeamSetupScreenState();
}

class _TeamSetupScreenState extends State<TeamSetupScreen> {
  final _nameController = TextEditingController(text: 'Denizaltı-1');
  CrewRole? _selectedRole;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce bir rol seç!')),
      );
      return;
    }
    final game = context.read<GameProvider>();
    await game.startTeam(_nameController.text, _selectedRole!);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const RoleHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mürettebat Kur')),
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
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Takım adını yaz ve rolünü seç',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Takım adı',
                  filled: true,
                  fillColor: AppColors.panel,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 32),
              ...CrewRole.values.map((role) => _RoleCard(
                    role: role,
                    selected: _selectedRole == role,
                    onTap: () => setState(() => _selectedRole = role),
                  )),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _start,
                  child: const Text('Göreve Başla!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final CrewRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected ? AppColors.reefTeal.withValues(alpha: 0.25) : AppColors.panel,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected ? AppColors.reefTeal : Colors.white24,
                width: selected ? 3 : 1,
              ),
            ),
            child: Row(
              children: [
                Text(role.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(role.subtitle, style: TextStyle(color: AppColors.bubble.withValues(alpha: 0.8))),
                      const SizedBox(height: 6),
                      Text(role.description, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                if (selected) const Icon(Icons.check_circle, color: AppColors.reefTeal, size: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
