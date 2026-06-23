import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/sentence_model.dart';

class SentenceService {
  Future<List<SentenceModel>> loadTheme(String theme) async {
    String assetPath = theme;
    
    // Resolve theme ID or Name to its asset path if it's not already a direct path
    if (!theme.endsWith('.json')) {
      final normalized = theme.trim().toLowerCase();
      if (normalized == 'daily' || normalized == '일상' || normalized == '일상 회화') {
        assetPath = 'assets/data/daily.json';
      } else if (normalized == 'travel' || normalized == '여행') {
        assetPath = 'assets/data/travel.json';
      } else if (normalized == 'shopping' || normalized == '쇼핑') {
        assetPath = 'assets/data/shopping.json';
      } else if (normalized == 'restaurant' || normalized == '식당') {
        assetPath = 'assets/data/restaurant.json';
      } else if (normalized == 'business' || normalized == '비즈니스') {
        assetPath = 'assets/data/business.json';
      } else if (normalized == 'airport' || normalized == '공항') {
        assetPath = 'assets/data/airport.json';
      } else if (normalized == 'hotel' || normalized == '호텔') {
        assetPath = 'assets/data/hotel.json';
      } else if (normalized == 'hospital' || normalized == '병원') {
        assetPath = 'assets/data/hospital.json';
      } else {
        assetPath = 'assets/data/$theme.json';
      }
    }

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> sentencesJson = jsonData['sentences'] as List<dynamic>? ?? [];
      return sentencesJson
          .map((s) => SentenceModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Error loading sentences for theme '$theme' (path: $assetPath): $e");
      return [];
    }
  }
}
