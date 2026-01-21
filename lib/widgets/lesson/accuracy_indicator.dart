import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../constants/app_spacing.dart';
import '../../utils/text_similarity.dart';
import '../../l10n/app_localizations.dart';

class AccuracyIndicator extends StatelessWidget {
  final double accuracy;
  final bool showFeedback;

  const AccuracyIndicator({
    super.key,
    required this.accuracy,
    this.showFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = TextSimilarity.getColor(accuracy);
    final feedbackKey = TextSimilarity.getFeedbackKey(accuracy);

    // l10n에서 피드백 메시지 가져오기
    String feedback;
    switch (feedbackKey) {
      case 'feedback_perfect':
        feedback = l10n.feedback_perfect;
        break;
      case 'feedback_great':
        feedback = l10n.feedback_great;
        break;
      case 'feedback_good':
        feedback = l10n.feedback_good;
        break;
      case 'feedback_keep_practicing':
        feedback = l10n.feedback_keep_practicing;
        break;
      default:
        feedback = l10n.feedback_try_again;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 원형 정확도 표시
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: accuracy,
                strokeWidth: 10,
                backgroundColor: color.withValues(alpha: 0.2),
                color: color,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TextSimilarity.toPercentString(accuracy),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(
                  _getIcon(),
                  color: color,
                  size: 24,
                ),
              ],
            ),
          ],
        ),

        // 피드백 메시지
        if (showFeedback) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            feedback,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }

  IconData _getIcon() {
    if (accuracy >= 0.8) {
      return PhosphorIcons.trophy(PhosphorIconsStyle.fill);
    } else if (accuracy >= 0.6) {
      return PhosphorIcons.thumbsUp(PhosphorIconsStyle.fill);
    } else {
      return PhosphorIcons.arrowClockwise(PhosphorIconsStyle.fill);
    }
  }
}
