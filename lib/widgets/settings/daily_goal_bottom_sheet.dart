import 'package:flutter/material.dart';
import '../../models/daily_goal.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

class DailyGoalBottomSheet extends StatefulWidget {
  final DailyGoal currentGoal;
  final Function(DailyGoal) onChanged;

  const DailyGoalBottomSheet({
    super.key,
    required this.currentGoal,
    required this.onChanged,
  });

  @override
  State<DailyGoalBottomSheet> createState() => _DailyGoalBottomSheetState();
}

class _DailyGoalBottomSheetState extends State<DailyGoalBottomSheet> {
  late DailyGoalType _selectedType;
  late int _customCount;

  final List<DailyGoal> _presets = [
    DailyGoal.light,
    DailyGoal.normal,
    DailyGoal.intense,
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentGoal.type;
    _customCount = widget.currentGoal.type == DailyGoalType.custom
        ? widget.currentGoal.sentenceCount
        : 15;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 제목
          Text(
            l10n.dailyGoal,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 옵션 목록
          ..._presets.map((goal) => _buildOptionTile(context, l10n, goal)),
          _buildCustomTile(context, l10n),

          const SizedBox(height: AppSpacing.lg),

          // 저장 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onSave,
              child: Text(l10n.confirm),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
      BuildContext context, AppLocalizations l10n, DailyGoal goal) {
    final isSelected = _selectedType == goal.type;

    return ListTile(
      leading: Text(_getGoalIcon(goal.type),
          style: const TextStyle(fontSize: 24)),
      title: Row(
        children: [
          Text(_getGoalName(l10n, goal.type)),
          if (goal.type == DailyGoalType.normal) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
      subtitle: Text(
        '${goal.sentenceCount}${l10n.sentences} · ${l10n.approximately}${goal.estimatedMinutes}${l10n.minutes}',
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppColors.primary)
          : Icon(Icons.circle_outlined, color: AppColors.divider),
      onTap: () => setState(() => _selectedType = goal.type),
    );
  }

  Widget _buildCustomTile(BuildContext context, AppLocalizations l10n) {
    final isSelected = _selectedType == DailyGoalType.custom;

    return Column(
      children: [
        ListTile(
          leading: const Text('⚙️', style: TextStyle(fontSize: 24)),
          title: Text(l10n.goalCustom),
          subtitle: Text(isSelected
              ? '$_customCount${l10n.sentences}'
              : l10n.goalCustomDesc),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: AppColors.primary)
              : Icon(Icons.circle_outlined, color: AppColors.divider),
          onTap: () => setState(() => _selectedType = DailyGoalType.custom),
        ),
        if (isSelected)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                Slider(
                  value: _customCount.toDouble(),
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: '$_customCount',
                  onChanged: (value) {
                    setState(() => _customCount = value.round());
                  },
                ),
                Text(
                  '${l10n.estimatedTime}: ${l10n.approximately}${(_customCount * 0.5).ceil()}${l10n.minutes}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
      ],
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

  void _onSave() {
    final goal = switch (_selectedType) {
      DailyGoalType.light => DailyGoal.light,
      DailyGoalType.normal => DailyGoal.normal,
      DailyGoalType.intense => DailyGoal.intense,
      DailyGoalType.custom => DailyGoal.custom(_customCount),
    };

    widget.onChanged(goal);
  }
}
