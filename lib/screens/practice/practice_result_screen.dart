import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../models/lesson.dart';
import '../../utils/text_similarity.dart';

class PracticeResultScreen extends StatelessWidget {
  final List<Lesson> lessons;
  final List<double> accuracies;

  const PracticeResultScreen({
    super.key,
    required this.lessons,
    required this.accuracies,
  });

  double get _averageAccuracy {
    if (accuracies.isEmpty) return 0;
    return accuracies.reduce((a, b) => a + b) / accuracies.length;
  }

  int get _passedCount {
    return accuracies.where((a) => a >= 0.8).length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.practiceComplete),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              const Spacer(),

              // 트로피 아이콘
              Icon(
                PhosphorIcons.trophy(PhosphorIconsStyle.fill),
                size: 80,
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 완료 메시지
              Text(
                l10n.practiceComplete,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              // 통계 카드
              Card(
                child: Padding(
                  padding: AppSpacing.cardPaddingLg,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        context,
                        value: '$_passedCount/${accuracies.length}',
                        label: l10n.lessonsCompleted,
                        color: AppColors.success,
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: AppColors.divider,
                      ),
                      _buildStat(
                        context,
                        value: TextSimilarity.toPercentString(_averageAccuracy),
                        label: l10n.averageAccuracy,
                        color: TextSimilarity.getColor(_averageAccuracy),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // 완료 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.finish),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
