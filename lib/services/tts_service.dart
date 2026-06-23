import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.45); // comfortable rate for language learning
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      // On iOS, configure shared audio session if possible
      await _flutterTts.setSharedInstance(true);
      
      _isInitialized = true;
    } catch (e) {
      debugPrint("Error initializing FlutterTts: $e");
    }
  }

  Future<void> speak(String text) async {
    await init();
    try {
      await _flutterTts.stop(); // Stop any active speech first
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("Error speaking: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint("Error stopping TTS: $e");
    }
  }
}
