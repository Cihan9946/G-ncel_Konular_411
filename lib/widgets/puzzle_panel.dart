import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PuzzlePanel extends StatefulWidget {
  const PuzzlePanel({
    super.key,
    required this.puzzleType,
    required this.stationTitle,
    required this.onSolved,
  });

  final String puzzleType;
  final String stationTitle;
  final VoidCallback onSolved;

  @override
  State<PuzzlePanel> createState() => _PuzzlePanelState();
}

class _PuzzlePanelState extends State<PuzzlePanel> {
  bool _solved = false;

  @override
  Widget build(BuildContext context) {
    if (_solved) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.reefTeal.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.sand),
        ),
        child: const Row(
          children: [
            Icon(Icons.celebration, color: AppColors.sand, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Bulmaca çözüldü! Takıma +50 puan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.coral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.sand),
          ),
          const SizedBox(height: 8),
          Text(_instruction, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 12),
          ..._options.map((opt) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => _onAnswer(opt.correct),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.reefTeal),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(opt.label, textAlign: TextAlign.center),
                ),
              )),
        ],
      ),
    );
  }

  String get _title {
    switch (widget.puzzleType) {
      case 'dna_match':
        return '🧬 DNA Eşleştirme';
      case 'food_chain':
        return '🍽️ Besin Zinciri';
      default:
        return '🌿 Habitat Sıralama';
    }
  }

  String get _instruction {
    switch (widget.puzzleType) {
      case 'dna_match':
        return 'Mercan resifinde yaşayan balık hangisidir?';
      case 'food_chain':
        return 'Kumda yaşayan ve kabukluyla beslenen canlı?';
      default:
        return 'Deniz çayırında gizlenen canlı hangisi?';
    }
  }

  List<({String label, bool correct})> get _options {
    switch (widget.puzzleType) {
      case 'dna_match':
        return [
          (label: 'Palyaço Balığı', correct: true),
          (label: 'Denizanası', correct: false),
          (label: 'Ahtapot', correct: false),
        ];
      case 'food_chain':
        return [
          (label: 'Vatoz', correct: true),
          (label: 'Melek Balığı', correct: false),
          (label: 'Deniz Atı', correct: false),
        ];
      default:
        return [
          (label: 'Deniz Atı', correct: true),
          (label: 'Palyaço Balığı', correct: false),
          (label: 'Vatoz', correct: false),
        ];
    }
  }

  void _onAnswer(bool correct) {
    if (correct) {
      setState(() => _solved = true);
      widget.onSolved();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harika! Sanal yakıt kilidi açıldı ⚡'),
          backgroundColor: AppColors.oceanBlue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tekrar dene, mürettebat sana güveniyor!'),
          backgroundColor: AppColors.coral,
        ),
      );
    }
  }
}
