import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/sentence_service.dart';
import 'services/ai_service.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';
import 'providers/learning_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized before accessing SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent Storage Service
  final storageService = await StorageService.init();
  final sentenceService = SentenceService();
  final aiService = MockAIService();
  final ttsService = TTSService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LearningProvider>(
          create: (_) => LearningProvider(
            sentenceService,
            aiService,
            storageService,
            ttsService,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final learningProvider = Provider.of<LearningProvider>(context);

    // Premium Color Palette - Indigo & Lavender
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5A4FCF), // Deep Indigo
      brightness: Brightness.light,
      primary: const Color(0xFF5A4FCF),
      secondary: const Color(0xFF8A4FFF),
      surface: const Color(0xFFF9F9FC),
      surfaceContainerHighest: const Color(0xFFEEECF8),
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF9B8FFF),
      brightness: Brightness.dark,
      primary: const Color(0xFF9B8FFF),
      secondary: const Color(0xFFB58FFF),
      surface: const Color(0xFF0F0E17),
      surfaceContainerHighest: const Color(0xFF232035),
    );

    return MaterialApp(
      title: 'Echo English Study',
      debugShowCheckedModeBanner: false,
      themeMode: learningProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: lightColorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: lightColorScheme.surface,
          foregroundColor: lightColorScheme.onSurface,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: lightColorScheme.surface,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontFamily: 'Roboto', fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          headlineSmall: TextStyle(fontFamily: 'Roboto', fontSize: 21, fontWeight: FontWeight.w600, letterSpacing: -0.2),
          titleMedium: TextStyle(fontFamily: 'Roboto', fontSize: 17, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 16, height: 1.4),
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 14),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: darkColorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: darkColorScheme.surface,
          foregroundColor: darkColorScheme.onSurface,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: darkColorScheme.surface,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontFamily: 'Roboto', fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.white),
          headlineSmall: TextStyle(fontFamily: 'Roboto', fontSize: 21, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: Colors.white),
          titleMedium: TextStyle(fontFamily: 'Roboto', fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 16, height: 1.4, color: Colors.white70),
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: Colors.white60),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
