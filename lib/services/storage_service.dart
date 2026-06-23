import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String date;
  final String themeName;
  final int sentenceCount;

  HistoryItem({
    required this.date,
    required this.themeName,
    required this.sentenceCount,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'themeName': themeName,
        'sentenceCount': sentenceCount,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        date: json['date'] as String? ?? '',
        themeName: json['themeName'] as String? ?? '알 수 없음',
        sentenceCount: json['sentenceCount'] as int? ?? 0,
      );
}

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Favorites (using English sentence as unique identifier)
  Set<String> getFavorites() {
    final list = _prefs.getStringList('favorites') ?? [];
    return list.toSet();
  }

  Future<void> saveFavorites(Set<String> favorites) async {
    await _prefs.setStringList('favorites', favorites.toList());
  }

  // History
  List<HistoryItem> getHistory() {
    final list = _prefs.getStringList('history') ?? [];
    return list.map((item) {
      try {
        return HistoryItem.fromJson(json.decode(item) as Map<String, dynamic>);
      } catch (e) {
        debugPrint("Error parsing history item: $e");
        return HistoryItem(
          date: DateTime.now().toIso8601String(),
          themeName: '오류',
          sentenceCount: 0,
        );
      }
    }).toList();
  }

  Future<void> addHistoryItem(HistoryItem item) async {
    final history = getHistory();
    history.insert(0, item); // insert at the top (newest first)
    final list = history.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('history', list);
  }

  Future<void> clearHistory() async {
    await _prefs.remove('history');
  }

  // User Settings Cache
  bool isDarkMode() {
    return _prefs.getBool('darkMode') ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('darkMode', value);
  }

  bool isRandomMode() {
    return _prefs.getBool('randomMode') ?? false;
  }

  Future<void> setRandomMode(bool value) async {
    await _prefs.setBool('randomMode', value);
  }

  bool isAutoPlayMode() {
    return _prefs.getBool('autoPlayMode') ?? false;
  }

  Future<void> setAutoPlayMode(bool value) async {
    await _prefs.setBool('autoPlayMode', value);
  }

  int getAutoPlayRevealSeconds() {
    return _prefs.getInt('autoPlayRevealSeconds') ?? 3;
  }

  Future<void> setAutoPlayRevealSeconds(int seconds) async {
    await _prefs.setInt('autoPlayRevealSeconds', seconds);
  }

  int getAutoPlayNextSeconds() {
    return _prefs.getInt('autoPlayNextSeconds') ?? 5;
  }

  Future<void> setAutoPlayNextSeconds(int seconds) async {
    await _prefs.setInt('autoPlayNextSeconds', seconds);
  }
}
