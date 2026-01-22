import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../services/progress_service.dart';
import '../../services/lesson_service.dart';
import '../../widgets/progress/streak_badge.dart';
import '../practice/practice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProgressService _progressService = ProgressService();
  final LessonService _lessonService = LessonService();

  int _streak = 0;
  int _completedCount = 0;
  int _todayCount = 0;
  double _averageAccuracy = 0.0;
  int _totalLessons = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _checkForUpdates();
    ProgressNotifier().addListener(_loadStats);
  }

  Future<void> _checkForUpdates() async {
    final result = await _lessonService.syncFromRemote();

    if (!mounted) return;

    if (result.status == SyncStatus.completed) {
      // 데이터가 업데이트됨 - 통계 새로고침
      await _loadStats();

      if (!mounted) return;

      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dataUpdated(result.newVersion ?? '')),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    ProgressNotifier().removeListener(_loadStats);
    super.dispose();
  }

  Future<void> _loadStats() async {
    final streak = await _progressService.getDailyStreak();
    final completed = await _progressService.getCompletedCount();
    final today = await _progressService.getTodayPracticeCount();
    final accuracy = await _progressService.getAverageAccuracy();
    final lessons = await _lessonService.getLessons();

    if (mounted) {
      setState(() {
        _streak = streak;
        _completedCount = completed;
        _todayCount = today;
        _averageAccuracy = accuracy;
        _totalLessons = lessons.length;
      });
    }
  }

  void _startPractice() async {
    final lessons = await _lessonService.getLessons();
    if (lessons.isEmpty || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeScreen(lessons: lessons),
      ),
    ).then((_) => _loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (_streak > 0)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: StreakBadge(streak: _streak),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
              const SizedBox(height: AppSpacing.lg),

              // 연습 시작 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startPractice,
                  icon: Icon(PhosphorIcons.play(PhosphorIconsStyle.fill)),
                  label: Text(
                    _todayCount > 0 ? l10n.continuePractice : l10n.startPractice,
                  ),
                ),
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
                  icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  value: '$_completedCount/$_totalLessons',
                  label: l10n.completed,
                  color: AppColors.success,
                ),
                _buildStatItem(
                  context,
                  icon: PhosphorIcons.flame(PhosphorIconsStyle.fill),
                  value: '$_streak ${l10n.days}',
                  label: l10n.streak,
                  color: AppColors.warning,
                ),
                _buildStatItem(
                  context,
                  icon: PhosphorIcons.target(PhosphorIconsStyle.fill),
                  value: '${(_averageAccuracy * 100).round()}%',
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
