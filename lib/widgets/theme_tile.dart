import 'package:flutter/material.dart';
import '../models/theme_model.dart';

class ThemeTile extends StatelessWidget {
  final ThemeModel themeModel;
  final VoidCallback onTap;

  const ThemeTile({
    super.key,
    required this.themeModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: themeModel.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      color: isDark
          ? themeModel.color.withValues(alpha: 0.08)
          : themeModel.color.withValues(alpha: 0.05),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: themeModel.color.withValues(alpha: 0.15),
        highlightColor: themeModel.color.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon with colored circle background
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: themeModel.color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  themeModel.icon,
                  size: 36,
                  color: themeModel.color,
                ),
              ),
              const SizedBox(height: 16),
              // Theme Name
              Text(
                themeModel.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
