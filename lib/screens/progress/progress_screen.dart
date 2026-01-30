import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../services/progress_service.dart';
import '../../services/lesson_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressService _progressService = ProgressService();
  final LessonService _lessonService = LessonService();

  int _streak = 0;
  int _completedCount = 0;
  int _totalLessons = 0;
  int _totalPracticeCount = 0;
  double _averageAccuracy = 0.0;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    ProgressNotifier().addListener(_loadStats);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadStats();
    }
  }

  @override
  void dispose() {
    ProgressNotifier().removeListener(_loadStats);
    super.dispose();
  }

  Future<void> _loadStats() async {
    final locale = Localizations.localeOf(context).toString();
    final streak = await _progressService.getDailyStreak();
    final completed = await _progressService.getCompletedCount();
    final total = await _progressService.getTotalPracticeCount();
    final accuracy = await _progressService.getAverageAccuracy();
    final lessons = await _lessonService.getLessons(locale: locale);

    if (mounted) {
      setState(() {
        _streak = streak;
        _completedCount = completed;
        _totalPracticeCount = total;
        _averageAccuracy = accuracy;
        _totalLessons = lessons.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.progress),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            // 스트릭 카드
            Card(
              child: Padding(
                padding: AppSpacing.cardPaddingLg,
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.flame(PhosphorIconsStyle.fill),
                      size: 48,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_streak ${l10n.days}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            l10n.streak,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 통계 그리드
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                    value: '$_completedCount/$_totalLessons',
                    label: l10n.completed,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: PhosphorIcons.target(PhosphorIconsStyle.fill),
                    value: '${(_averageAccuracy * 100).round()}%',
                    label: l10n.accuracy,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 총 연습 횟수
            _buildStatCard(
              context,
              icon: PhosphorIcons.repeat(PhosphorIconsStyle.fill),
              value: '$_totalPracticeCount',
              label: 'Total Practices',
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
