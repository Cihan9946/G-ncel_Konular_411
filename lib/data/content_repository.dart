import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/ar_station.dart';
import '../models/fish_species.dart';

class ContentRepository {
  List<FishSpecies>? _fish;
  List<ArStation>? _stations;

  Future<List<FishSpecies>> loadFish() async {
    if (_fish != null) return _fish!;
    final raw = await rootBundle.loadString('assets/data/fish.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _fish = list.map((e) => FishSpecies.fromJson(e as Map<String, dynamic>)).toList();
    return _fish!;
  }

  Future<List<ArStation>> loadStations() async {
    if (_stations != null) return _stations!;
    final raw = await rootBundle.loadString('assets/data/stations.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _stations = list.map((e) => ArStation.fromJson(e as Map<String, dynamic>)).toList();
    return _stations!;
  }

  Future<ArStation?> stationByQr(String code) async {
    final stations = await loadStations();
    final normalized = code.trim().toUpperCase();
    for (final s in stations) {
      if (s.qrCode.toUpperCase() == normalized) return s;
    }
    return null;
  }

  Future<List<FishSpecies>> fishForStation(String stationId) async {
    final fish = await loadFish();
    return fish.where((f) => f.stationId == stationId).toList();
  }

  Future<ArStation?> stationById(String id) async {
    final stations = await loadStations();
    try {
      return stations.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
