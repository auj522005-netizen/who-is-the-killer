import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/game_utils.dart';

/// ────────────────────────────────────────────────────────────────
/// TimerDisplay — Countdown timer widget for phase durations
///
/// Displays a large, monospaced countdown timer with a label
/// indicating the current phase. Uses neon orange accent styling.
/// ────────────────────────────────────────────────────────────────
class TimerDisplay extends StatelessWidget {
  final int seconds;
  final String label;

  const TimerDisplay({
    required this.seconds,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = seconds <= 10;
    final color = isLow ? AppColors.neonRed : AppColors.neonOrange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLow ? Icons.timer_off : Icons.timer,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                ),
          ),
          Text(
            GameUtils.formatDuration(seconds),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: color,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
          ),
        ],
      ),
    );
  }
}
