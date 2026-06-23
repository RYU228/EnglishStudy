import 'package:flutter/material.dart';
import '../models/sentence_model.dart';

class SentenceCard extends StatelessWidget {
  final SentenceModel sentence;
  final bool isAnswerRevealed;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onSpeakPressed;

  const SentenceCard({
    super.key,
    required this.sentence,
    required this.isAnswerRevealed,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onSpeakPressed,
  });

  @override
  Widget build(BuildContext buildContext) {
    final theme = Theme.of(buildContext);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 280),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [theme.colorScheme.surfaceContainerHighest, theme.colorScheme.surface]
              : [Colors.white, theme.colorScheme.primaryContainer.withValues(alpha: 0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Favorite Star Top-Right
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: onFavoriteToggle,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: child,
                  ),
                  child: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    key: ValueKey<bool>(isFavorite),
                    color: isFavorite ? Colors.amber : theme.colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                ),
                tooltip: '즐겨찾기 추가/해제',
              ),
            ),
          ),

          // Main Card Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Korean Sentence (Question)
                const SizedBox(height: 12),
                Text(
                  sentence.korean,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Divider(thickness: 1.5, indent: 40, endIndent: 40),
                ),

                // English Sentence (Answer) - Animated reveal
                AnimatedCrossFade(
                  firstChild: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_open_rounded,
                          size: 36,
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "정답을 확인해보세요",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  secondChild: Column(
                    children: [
                      Text(
                        sentence.english,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // TTS Button
                      ElevatedButton.icon(
                        onPressed: onSpeakPressed,
                        icon: const Icon(Icons.volume_up_rounded),
                        label: const Text("다시 듣기"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                  crossFadeState: isAnswerRevealed
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
