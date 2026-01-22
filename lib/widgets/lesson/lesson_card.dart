import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../models/lesson.dart';
import '../../models/user_progress.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final UserProgress? progress;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress?.isCompleted ?? false;
    final accuracy = progress?.bestAccuracy;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              // 완료 상태 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.divider,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted
                      ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                      : PhosphorIcons.circle(PhosphorIconsStyle.regular),
                  color: isCompleted ? AppColors.success : AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // 레슨 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.sentence,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      lesson.getTranslation(
                        Localizations.localeOf(context).toString(),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 정확도 표시
              if (accuracy != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${(accuracy * 100).round()}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.getAccuracyColor(accuracy),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],

              const SizedBox(width: AppSpacing.sm),
              Icon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
