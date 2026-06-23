import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sentence_model.dart';
import '../services/sentence_service.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';

class LearningProvider extends ChangeNotifier {
  final SentenceService _sentenceService;
  final AIService _aiService;
  final StorageService _storageService;
  final TTSService _ttsService;

  // Global settings & cache
  bool _isDarkMode = false;
  bool _randomMode = false;
  bool _autoPlayMode = false;
  int _autoPlayRevealSeconds = 3;
  int _autoPlayNextSeconds = 5;
  
  Set<String> _favorites = {};
  List<HistoryItem> _history = [];

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get randomMode => _randomMode;
  bool get autoPlayMode => _autoPlayMode;
  int get autoPlayRevealSeconds => _autoPlayRevealSeconds;
  int get autoPlayNextSeconds => _autoPlayNextSeconds;
  Set<String> get favorites => _favorites;
  List<HistoryItem> get history => _history;

  // Study Session State
  String _currentThemeId = '';
  String _currentThemeName = '';
  List<SentenceModel> _originalSentences = [];
  List<SentenceModel> _sentences = [];
  int _currentIndex = 0;
  bool _isAnswerRevealed = false;
  bool _isLoading = false;
  bool _isAIGenerating = false;
  bool _isSessionFinished = false;

  // Auto-play timers
  Timer? _revealTimer;
  Timer? _nextTimer;

  // Session Getters
  String get currentThemeId => _currentThemeId;
  String get currentThemeName => _currentThemeName;
  List<SentenceModel> get sentences => _sentences;
  int get currentIndex => _currentIndex;
  bool get isAnswerRevealed => _isAnswerRevealed;
  bool get isLoading => _isLoading;
  bool get isAIGenerating => _isAIGenerating;
  bool get isSessionFinished => _isSessionFinished;
  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex < _sentences.length - 1;
  double get progressPercentage => _sentences.isEmpty ? 0 : (_currentIndex + 1) / _sentences.length;

  SentenceModel? get currentSentence => _sentences.isNotEmpty ? _sentences[_currentIndex] : null;

  LearningProvider(
    this._sentenceService,
    this._aiService,
    this._storageService,
    this._ttsService,
  ) {
    _loadSettings();
  }

  void _loadSettings() {
    _isDarkMode = _storageService.isDarkMode();
    _randomMode = _storageService.isRandomMode();
    _autoPlayMode = _storageService.isAutoPlayMode();
    _autoPlayRevealSeconds = _storageService.getAutoPlayRevealSeconds();
    _autoPlayNextSeconds = _storageService.getAutoPlayNextSeconds();
    _favorites = _storageService.getFavorites();
    _history = _storageService.getHistory();
    notifyListeners();
  }

  // Toggles and Settings Update
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _storageService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> toggleRandomMode() async {
    _randomMode = !_randomMode;
    await _storageService.setRandomMode(_randomMode);
    notifyListeners();
  }

  Future<void> toggleAutoPlayMode() async {
    _autoPlayMode = !_autoPlayMode;
    await _storageService.setAutoPlayMode(_autoPlayMode);
    
    if (_autoPlayMode) {
      _startAutoPlayLoop();
    } else {
      _cancelTimers();
    }
    notifyListeners();
  }

  Future<void> setAutoPlayIntervals(int reveal, int next) async {
    _autoPlayRevealSeconds = reveal;
    _autoPlayNextSeconds = next;
    await _storageService.setAutoPlayRevealSeconds(reveal);
    await _storageService.setAutoPlayNextSeconds(next);
    notifyListeners();
  }

  // Favorites Management
  bool isFavorite(String english) {
    return _favorites.contains(english);
  }

  Future<void> toggleFavorite(String english) async {
    if (_favorites.contains(english)) {
      _favorites.remove(english);
    } else {
      _favorites.add(english);
    }
    await _storageService.saveFavorites(_favorites);
    notifyListeners();
  }

  // Study Session Life-Cycle
  Future<void> startThemeStudy(String themeId, String themeName, {bool useAI = false, int aiCount = 10}) async {
    _cancelTimers();
    _currentThemeId = themeId;
    _currentThemeName = themeName;
    _currentIndex = 0;
    _isAnswerRevealed = false;
    _isSessionFinished = false;
    _sentences = [];
    
    if (useAI) {
      _isAIGenerating = true;
      _isLoading = true;
      notifyListeners();
      try {
        _originalSentences = await _aiService.generateSentences(themeName, aiCount);
      } catch (e) {
        debugPrint("AI generation failed: $e");
        _originalSentences = [];
      } finally {
        _isAIGenerating = false;
      }
    } else {
      _isLoading = true;
      notifyListeners();
      _originalSentences = await _sentenceService.loadTheme(themeId);
    }

    _sentences = List.from(_originalSentences);
    if (_randomMode) {
      _sentences.shuffle();
    }

    _isLoading = false;
    notifyListeners();

    if (_sentences.isNotEmpty && _autoPlayMode) {
      _startAutoPlayLoop();
    }
  }

  void revealAnswer() {
    if (_isAnswerRevealed) return;
    _isAnswerRevealed = true;
    notifyListeners();
    
    // Auto-TTS on reveal
    if (currentSentence != null) {
      _ttsService.speak(currentSentence!.english);
    }

    // Schedule next sentence if auto play is active
    if (_autoPlayMode) {
      _scheduleNextSentenceTimer();
    }
  }

  void speakCurrent() {
    if (currentSentence != null) {
      _ttsService.speak(currentSentence!.english);
    }
  }

  void stopTTS() {
    _ttsService.stop();
  }

  void nextSentence({bool isAuto = false}) {
    _cancelTimers();
    _ttsService.stop();

    if (_currentIndex < _sentences.length - 1) {
      _currentIndex++;
      _isAnswerRevealed = false;
      notifyListeners();
      
      if (_autoPlayMode) {
        _startAutoPlayLoop();
      }
    } else {
      _isSessionFinished = true;
      notifyListeners();
    }
  }

  void prevSentence() {
    _cancelTimers();
    _ttsService.stop();

    if (_currentIndex > 0) {
      _currentIndex--;
      _isAnswerRevealed = false;
      _isSessionFinished = false; // Reset if user goes back
      notifyListeners();

      if (_autoPlayMode) {
        _startAutoPlayLoop();
      }
    }
  }

  Future<void> finishStudy() async {
    _cancelTimers();
    _ttsService.stop();

    if (_sentences.isNotEmpty) {
      final newItem = HistoryItem(
        date: DateTime.now().toIso8601String(),
        themeName: _currentThemeName,
        sentenceCount: _sentences.length,
      );
      await _storageService.addHistoryItem(newItem);
      _history = _storageService.getHistory();
    }
    notifyListeners();
  }

  void restartStudy() {
    _cancelTimers();
    _ttsService.stop();
    _currentIndex = 0;
    _isAnswerRevealed = false;
    _isSessionFinished = false;
    _sentences = List.from(_originalSentences);
    if (_randomMode) {
      _sentences.shuffle();
    }
    notifyListeners();

    if (_sentences.isNotEmpty && _autoPlayMode) {
      _startAutoPlayLoop();
    }
  }

  void stopSession() {
    _cancelTimers();
    _ttsService.stop();
  }

  // Timer logic for Auto-Play Mode
  void _cancelTimers() {
    _revealTimer?.cancel();
    _nextTimer?.cancel();
  }

  void _startAutoPlayLoop() {
    _cancelTimers();
    if (!_autoPlayMode || _sentences.isEmpty) return;

    _revealTimer = Timer(Duration(seconds: _autoPlayRevealSeconds), () {
      revealAnswer();
    });
  }

  void _scheduleNextSentenceTimer() {
    _nextTimer?.cancel();
    if (!_autoPlayMode) return;

    _nextTimer = Timer(Duration(seconds: _autoPlayNextSeconds), () {
      nextSentence(isAuto: true);
    });
  }

  Future<void> clearAllHistory() async {
    await _storageService.clearHistory();
    _history = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimers();
    _ttsService.stop();
    super.dispose();
  }
}
