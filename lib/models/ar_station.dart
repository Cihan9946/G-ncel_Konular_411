class ArStation {
  const ArStation({
    required this.id,
    required this.qrCode,
    required this.title,
    required this.hint,
    required this.markerLabel,
    required this.puzzleType,
  });

  final String id;
  final String qrCode;
  final String title;
  final String hint;
  final String markerLabel;
  final String puzzleType;

  factory ArStation.fromJson(Map<String, dynamic> json) {
    return ArStation(
      id: json['id'] as String,
      qrCode: json['qrCode'] as String,
      title: json['title'] as String,
      hint: json['hint'] as String,
      markerLabel: json['markerLabel'] as String,
      puzzleType: json['puzzleType'] as String,
    );
  }
}
