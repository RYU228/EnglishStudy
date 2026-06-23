import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/learning_provider.dart';
import '../models/theme_model.dart';
import '../widgets/theme_tile.dart';
import 'learning_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _aiThemeController = TextEditingController();
  int _aiCount = 10;
  bool _isSettingsExpanded = false;

  @override
  void dispose() {
    _aiThemeController.dispose();
    super.dispose();
  }

  void _startStudy(BuildContext context, String themeId, String themeName, {bool useAI = false}) {
    final provider = Provider.of<LearningProvider>(context, listen: false);
    provider.startThemeStudy(themeId, themeName, useAI: useAI, aiCount: _aiCount);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LearningScreen(),
      ),
    );
  }

  void _showAICustomDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text("AI 맞춤형 문장 생성"),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "원하는 테마를 입력하시면 생성형 AI가 학습할 영어 문장을 맞춤 제작해 드립니다.",
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _aiThemeController,
                      decoration: InputDecoration(
                        labelText: "학습할 테마 (예: 스포츠, 파티, IT 회사)",
                        prefixIcon: const Icon(Icons.topic_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "생성할 문장 개수: $_aiCount개",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _aiCount.toDouble(),
                      min: 5,
                      max: 20,
                      divisions: 3,
                      label: "$_aiCount",
                      onChanged: (val) {
                        setDialogState(() {
                          _aiCount = val.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final theme = _aiThemeController.text.trim();
                    if (theme.isEmpty) return;
                    Navigator.pop(context);
                    _startStudy(context, 'ai_custom', theme, useAI: true);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("생성 및 학습 시작"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultThemes = ThemeModel.getDefaultThemes();
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive Columns
    int crossAxisCount = 2;
    if (screenWidth > 900) {
      crossAxisCount = 4;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Echo English",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Dark Mode Toggle
          Consumer<LearningProvider>(
            builder: (context, provider, child) => IconButton(
              icon: Icon(
                provider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
              onPressed: () => provider.toggleDarkMode(),
              tooltip: '화면 테마 변경',
            ),
          ),
          // AI Mode Shortcut
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded),
            onPressed: _showAICustomDialog,
            tooltip: 'AI 맞춤 생성',
          ),
        ],
      ),
      body: Consumer<LearningProvider>(
        builder: (context, provider, child) {
          final history = provider.history;
          final totalStudies = history.length;
          final totalSentences = history.fold<int>(0, (sum, item) => sum + item.sentenceCount);
          final favoritesCount = provider.favorites.length;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [theme.colorScheme.primaryContainer.withValues(alpha: 0.4), theme.colorScheme.surfaceContainerHighest]
                          : [theme.colorScheme.primary.withValues(alpha: 0.08), theme.colorScheme.secondaryContainer.withValues(alpha: 0.3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "오늘의 대화 학습 대시보드",
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem("학습 횟수", "$totalStudies회", Icons.done_all_rounded, theme),
                          _buildStatItem("학습 문장", "$totalSentences개", Icons.menu_book_rounded, theme),
                          _buildStatItem("즐겨찾기", "$favoritesCount개", Icons.star_rounded, theme, color: Colors.amber),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Settings Bar
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                  ),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Icon(Icons.tune_rounded, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          "학습 환경 설정",
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    initiallyExpanded: _isSettingsExpanded,
                    onExpansionChanged: (val) => setState(() => _isSettingsExpanded = val),
                    shape: const Border(), // remove border lines
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          children: [
                            // Random Mode Switch
                            SwitchListTile(
                              title: const Text("랜덤 학습 모드", style: TextStyle(fontSize: 14)),
                              subtitle: const Text("문장의 출제 순서를 무작위로 섞습니다", style: TextStyle(fontSize: 12)),
                              value: provider.randomMode,
                              onChanged: (val) => provider.toggleRandomMode(),
                              secondary: const Icon(Icons.shuffle_rounded),
                              dense: true,
                            ),
                            const Divider(height: 1),
                            // Auto Play Switch
                            SwitchListTile(
                              title: const Text("자동 재생 모드", style: TextStyle(fontSize: 14)),
                              value: provider.autoPlayMode,
                              onChanged: (val) => provider.toggleAutoPlayMode(),
                              secondary: const Icon(Icons.play_circle_outline_rounded),
                              dense: true,
                            ),
                            if (provider.autoPlayMode) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("정답 표시 시간: ${provider.autoPlayRevealSeconds}초", style: const TextStyle(fontSize: 12)),
                                        Text("다음 문제 이동 시간: ${provider.autoPlayNextSeconds}초", style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(trackHeight: 2),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Slider(
                                              value: provider.autoPlayRevealSeconds.toDouble(),
                                              min: 2,
                                              max: 8,
                                              divisions: 6,
                                              onChanged: (val) {
                                                provider.setAutoPlayIntervals(val.toInt(), provider.autoPlayNextSeconds);
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Slider(
                                              value: provider.autoPlayNextSeconds.toDouble(),
                                              min: 3,
                                              max: 10,
                                              divisions: 7,
                                              onChanged: (val) {
                                                provider.setAutoPlayIntervals(provider.autoPlayRevealSeconds, val.toInt());
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Theme Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "학습 테마 선택",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _showAICustomDialog,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                      label: const Text("AI 테마 생성"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Theme Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: defaultThemes.length,
                  itemBuilder: (context, index) {
                    final themeModel = defaultThemes[index];
                    return ThemeTile(
                      themeModel: themeModel,
                      onTap: () => _startStudy(context, themeModel.id, themeModel.name),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // History Section
                if (history.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "최근 학습 기록",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => provider.clearAllHistory(),
                        child: const Text("전체 기록 삭제", style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length > 5 ? 5 : history.length, // show up to 5
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      final dateObj = DateTime.tryParse(item.date) ?? DateTime.now();
                      final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(dateObj);

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.history_rounded, color: theme.colorScheme.secondary),
                        ),
                        title: Text(item.themeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(dateStr, style: const TextStyle(fontSize: 12)),
                        trailing: Text(
                          "${item.sentenceCount}문장 완료",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, ThemeData theme, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? theme.colorScheme.primary, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
