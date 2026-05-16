class FishSpecies {
  const FishSpecies({
    required this.id,
    required this.name,
    required this.emoji,
    required this.habitat,
    required this.fact,
    required this.diet,
    required this.depth,
    required this.stationId,
  });

  final String id;
  final String name;
  final String emoji;
  final String habitat;
  final String fact;
  final String diet;
  final String depth;
  final String stationId;

  factory FishSpecies.fromJson(Map<String, dynamic> json) {
    return FishSpecies(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      habitat: json['habitat'] as String,
      fact: json['fact'] as String,
      diet: json['diet'] as String,
      depth: json['depth'] as String,
      stationId: json['stationId'] as String,
    );
  }
}
