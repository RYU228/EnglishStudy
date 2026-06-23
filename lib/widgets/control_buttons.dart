import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final bool hasPrevious;
  final bool hasNext;
  final bool isAnswerRevealed;
  final VoidCallback onPrevious;
  final VoidCallback onReveal;
  final VoidCallback onNext;

  const ControlButtons({
    super.key,
    required this.hasPrevious,
    required this.hasNext,
    required this.isAnswerRevealed,
    required this.onPrevious,
    required this.onReveal,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Previous Card Button
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: hasPrevious ? onPrevious : null,
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: const Text("이전"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Reveal Answer Button
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: isAnswerRevealed ? null : onReveal,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 1,
              shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 16),
              disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              disabledForegroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "정답 확인",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Next Card or Complete Session Button
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: onNext,
            icon: Icon(
              hasNext ? Icons.arrow_forward_rounded : Icons.check_circle_outline_rounded,
              size: 20,
            ),
            label: Text(hasNext ? "다음" : "완료"),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasNext
                  ? theme.colorScheme.secondaryContainer
                  : theme.colorScheme.primaryContainer,
              foregroundColor: hasNext
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onPrimaryContainer,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
