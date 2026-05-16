import 'package:flutter/foundation.dart';

import '../data/content_repository.dart';
import '../data/database_helper.dart';
import '../models/ar_station.dart';
import '../models/crew_role.dart';
import '../models/discovered_fish.dart';
import '../models/fish_species.dart';

class GameProvider extends ChangeNotifier {
  GameProvider({
    ContentRepository? content,
    DatabaseHelper? db,
  })  : _content = content ?? ContentRepository(),
        _db = db ?? DatabaseHelper.instance;

  final ContentRepository _content;
  final DatabaseHelper _db;

  String teamName = '';
  CrewRole? playerRole;
  int? sessionId;
  int score = 0;

  ArStation? activeStation;
  List<FishSpecies> stationFish = [];
  List<DiscoveredFish> discoveries = [];
  List<String> completedStations = [];
  List<ArStation> allStations = [];
  String? lastCaptainHint;
  bool puzzleSolved = false;

  bool get isReady => teamName.isNotEmpty && playerRole != null && sessionId != null;

  Future<void> init() async {
    allStations = await _content.loadStations();
    notifyListeners();
  }

  Future<void> startTeam(String name, CrewRole role) async {
    teamName = name.trim().isEmpty ? 'Denizaltı-1' : name.trim();
    playerRole = role;
    sessionId = await _db.createSession(teamName);
    score = 0;
    discoveries = [];
    completedStations = [];
    activeStation = null;
    stationFish = [];
    lastCaptainHint = null;
    puzzleSolved = false;
    notifyListeners();
  }

  Future<void> refreshScore() async {
    if (sessionId == null) return;
    score = await _db.getScore(sessionId!);
    discoveries = await _db.getDiscoveries(sessionId!);
    completedStations = await _db.completedStationIds(sessionId!);
    notifyListeners();
  }

  void setCaptainHint(ArStation station) {
    lastCaptainHint = '${station.title}: ${station.hint}';
    notifyListeners();
  }

  Future<bool> activateStation(String qrOrCode) async {
    final station = await _content.stationByQr(qrOrCode);
    if (station == null) return false;
    activeStation = station;
    stationFish = await _content.fishForStation(station.id);
    puzzleSolved = false;
    notifyListeners();
    return true;
  }

  Future<void> activateStationById(String stationId) async {
    final station = await _content.stationById(stationId);
    if (station == null) return;
    activeStation = station;
    stationFish = await _content.fishForStation(station.id);
    puzzleSolved = false;
    notifyListeners();
  }

  void clearActiveStation() {
    activeStation = null;
    stationFish = [];
    puzzleSolved = false;
    notifyListeners();
  }

  Future<bool> discoverFish(FishSpecies fish) async {
    if (sessionId == null || playerRole == null) return false;
    final d = DiscoveredFish(
      fishId: fish.id,
      stationId: fish.stationId,
      discoveredAt: DateTime.now(),
      discoveredBy: playerRole!.title,
    );
    final isNew = await _db.saveDiscovery(sessionId!, d);
    if (isNew) {
      await _db.addScore(sessionId!, 25);
    }
    await refreshScore();
    return isNew;
  }

  Future<void> completePuzzle() async {
    if (sessionId == null || activeStation == null || puzzleSolved) return;
    final firstTime = await _db.markStationComplete(sessionId!, activeStation!.id);
    if (firstTime) {
      await _db.addScore(sessionId!, 50);
    }
    puzzleSolved = true;
    await refreshScore();
  }

  int get discoveryCount => discoveries.length;

  bool isFishDiscovered(String fishId) {
    return discoveries.any((d) => d.fishId == fishId);
  }
}
