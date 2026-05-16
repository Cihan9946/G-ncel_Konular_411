class DiscoveredFish {
  const DiscoveredFish({
    required this.fishId,
    required this.stationId,
    required this.discoveredAt,
    required this.discoveredBy,
  });

  final String fishId;
  final String stationId;
  final DateTime discoveredAt;
  final String discoveredBy;

  Map<String, dynamic> toMap() => {
        'fish_id': fishId,
        'station_id': stationId,
        'discovered_at': discoveredAt.toIso8601String(),
        'discovered_by': discoveredBy,
      };

  factory DiscoveredFish.fromMap(Map<String, dynamic> map) {
    return DiscoveredFish(
      fishId: map['fish_id'] as String,
      stationId: map['station_id'] as String,
      discoveredAt: DateTime.parse(map['discovered_at'] as String),
      discoveredBy: map['discovered_by'] as String,
    );
  }
}
