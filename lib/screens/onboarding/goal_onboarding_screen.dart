import 'package:flutter/material.dart';
import '../../models/daily_goal.dart';
import '../../services/preferences_service.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

class GoalOnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const GoalOnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<GoalOnboardingScreen> createState() => _GoalOnboardingScreenState();
}

class _GoalOnboardingScreenState extends State<GoalOnboardingScreen> {
  DailyGoalType? _selectedType;
  int _customCount = 15;

  final List<DailyGoal> _presets = [
    DailyGoal.light,
    DailyGoal.normal,
    DailyGoal.intense,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              const Spacer(),

              // 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🎯', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 제목
              Text(
                l10n.onboardingGoalTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // 옵션 목록
              ..._presets.map((goal) => _buildOptionCard(context, l10n, goal)),
              _buildCustomOptionCard(context, l10n),

              const Spacer(),

              // 시작 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedType != null ? _onStart : null,
                  child: Text(l10n.start),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 안내 텍스트
              Text(
                l10n.onboardingGoalHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
      BuildContext context, AppLocalizations l10n, DailyGoal goal) {
    final isSelected = _selectedType == goal.type;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: () => setState(() => _selectedType = goal.type),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              children: [
                Text(_getGoalIcon(goal.type),
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _getGoalName(l10n, goal.type),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (goal.type == DailyGoalType.normal) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.recommended,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _getGoalDescription(l10n, goal),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomOptionCard(BuildContext context, AppLocalizations l10n) {
    final isSelected = _selectedType == DailyGoalType.custom;

    return Card(
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.divider,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showCustomDialog(context, l10n),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              const Text('⚙️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.goalCustom,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      isSelected
                          ? '${l10n.daily} $_customCount${l10n.sentences}'
                          : l10n.goalCustomDesc,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomDialog(BuildContext context, AppLocalizations l10n) {
    int tempCount = _customCount;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.setDailyGoal),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$tempCount',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.sentences),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Slider(
                value: tempCount.toDouble(),
                min: 1,
                max: 50,
                divisions: 49,
                onChanged: (value) {
                  setDialogState(() => tempCount = value.round());
                },
              ),
              Text(
                '${l10n.estimatedTime}: ${l10n.about}${(tempCount * 0.5).ceil()}${l10n.minutes}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _customCount = tempCount;
                  _selectedType = DailyGoalType.custom;
                });
                Navigator.pop(context);
              },
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }

  String _getGoalIcon(DailyGoalType type) {
    return switch (type) {
      DailyGoalType.light => '🌱',
      DailyGoalType.normal => '🌿',
      DailyGoalType.intense => '🌳',
      DailyGoalType.custom => '⚙️',
    };
  }

  String _getGoalName(AppLocalizations l10n, DailyGoalType type) {
    return switch (type) {
      DailyGoalType.light => l10n.goalLight,
      DailyGoalType.normal => l10n.goalNormal,
      DailyGoalType.intense => l10n.goalIntense,
      DailyGoalType.custom => l10n.goalCustom,
    };
  }

  String _getGoalDescription(AppLocalizations l10n, DailyGoal goal) {
    return '${l10n.daily} ${goal.sentenceCount}${l10n.sentences} · ${l10n.about}${goal.estimatedMinutes}${l10n.minutes}';
  }

  void _onStart() async {
    final goal = switch (_selectedType!) {
      DailyGoalType.light => DailyGoal.light,
      DailyGoalType.normal => DailyGoal.normal,
      DailyGoalType.intense => DailyGoal.intense,
      DailyGoalType.custom => DailyGoal.custom(_customCount),
    };

    await PreferencesService.setDailyGoal(goal);
    await PreferencesService.setOnboardingComplete(true);

    widget.onComplete();
  }
}
