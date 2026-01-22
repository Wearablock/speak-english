import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../utils/text_similarity.dart';

class SpeechResultCard extends StatelessWidget {
  final String recognizedText;
  final double? accuracy;

  const SpeechResultCard({
    super.key,
    required this.recognizedText,
    this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 인식된 텍스트
            Text(
              recognizedText.isEmpty ? '...' : recognizedText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: recognizedText.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color: recognizedText.isEmpty
                        ? AppColors.textSecondary
                        : null,
                  ),
            ),

            // 정확도 표시
            if (accuracy != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: accuracy,
                        backgroundColor: AppColors.divider,
                        color: TextSimilarity.getColor(accuracy!),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    TextSimilarity.toPercentString(accuracy!),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: TextSimilarity.getColor(accuracy!),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
