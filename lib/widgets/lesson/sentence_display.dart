import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

class SentenceDisplay extends StatelessWidget {
  final String sentence;
  final String translation;
  final String? pronunciation;

  const SentenceDisplay({
    super.key,
    required this.sentence,
    required this.translation,
    this.pronunciation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 영어 문장
            Text(
              sentence,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
            ),

            // 발음 기호 (선택)
            if (pronunciation != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '/$pronunciation/',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),

            // 번역
            Text(
              translation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
