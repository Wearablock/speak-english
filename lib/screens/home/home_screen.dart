import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 환영 메시지
              Text(
                l10n.appSubtitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 오늘의 진도 카드
              _buildProgressCard(context, l10n),
              const SizedBox(height: AppSpacing.md),

              // 연습 시작 버튼
              ElevatedButton(
                onPressed: () {
                  // TODO: Phase 3에서 PracticeScreen으로 이동
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Phase 3에서 구현 예정')),
                  );
                },
                child: Text(l10n.startPractice),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 정보 텍스트
              Text(
                'Phase 1 프로젝트 셋업 완료!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '다음 단계: Phase 2 - 핵심 기능 구현',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todayProgress,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.check_circle_outline,
                  value: '0',
                  label: l10n.completed,
                  color: AppColors.success,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.local_fire_department,
                  value: '0',
                  label: l10n.streak,
                  color: AppColors.warning,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.percent,
                  value: '0%',
                  label: l10n.accuracy,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppSpacing.iconLg),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
