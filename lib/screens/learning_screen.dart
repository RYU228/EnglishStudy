import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/learning_provider.dart';
import '../widgets/sentence_card.dart';
import '../widgets/control_buttons.dart';
import 'result_screen.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late LearningProvider _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = Provider.of<LearningProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _provider.stopSession();
    super.dispose();
  }

  void _onNextPressed(LearningProvider provider) {
    if (provider.hasNext) {
      provider.nextSentence();
    } else {
      // Manual finish when clicking next on the last slide
      provider.finishStudy();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResultScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<LearningProvider>(context);

    // Safe navigation when session finishes (e.g. from Auto-Play timer)
    if (provider.isSessionFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.finishStudy();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResultScreen(),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          provider.currentThemeName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Indicator badges for settings
          if (provider.randomMode)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: const Text("랜덤", style: TextStyle(fontSize: 10)),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: theme.colorScheme.secondaryContainer,
              ),
            ),
          if (provider.autoPlayMode)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Chip(
                label: const Text("자동", style: TextStyle(fontSize: 10)),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
            ),
        ],
      ),
      body: provider.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    provider.isAIGenerating
                        ? "AI가 문장을 제작하는 중입니다...\n잠시만 기다려주세요."
                        : "문장 데이터를 불러오는 중입니다...",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : provider.sentences.isEmpty
              ? Center(
                  child: Text(
                    "불러온 문장이 없습니다.",
                    style: theme.textTheme.titleMedium,
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Linear progress indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: provider.progressPercentage,
                            minHeight: 8,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Progress text (e.g. 3 / 20)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "학습 진도",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              "${provider.currentIndex + 1} / ${provider.sentences.length}",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // The Sentence card
                        SentenceCard(
                          sentence: provider.currentSentence!,
                          isAnswerRevealed: provider.isAnswerRevealed,
                          isFavorite: provider.isFavorite(provider.currentSentence!.english),
                          onFavoriteToggle: () {
                            provider.toggleFavorite(provider.currentSentence!.english);
                          },
                          onSpeakPressed: () {
                            provider.speakCurrent();
                          },
                        ),
                        const Spacer(),

                        // Control Buttons at the bottom
                        ControlButtons(
                          hasPrevious: provider.hasPrevious,
                          hasNext: provider.hasNext,
                          isAnswerRevealed: provider.isAnswerRevealed,
                          onPrevious: () => provider.prevSentence(),
                          onReveal: () => provider.revealAnswer(),
                          onNext: () => _onNextPressed(provider),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
    );
  }
}
