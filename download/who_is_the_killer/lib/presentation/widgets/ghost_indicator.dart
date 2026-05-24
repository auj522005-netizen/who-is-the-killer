import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// ────────────────────────────────────────────────────────────────
/// GhostIndicator — Visual indicator for Ghost (eliminated) players
///
/// Displays a ghost icon with muted cyan styling to indicate
/// that the current player has been eliminated and is now
/// observing the game as a Ghost.
/// ────────────────────────────────────────────────────────────────
class GhostIndicator extends StatelessWidget {
  const GhostIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.ghostCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.ghostCyan.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.visibility_off,
            color: AppColors.ghostCyan,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'أنت شبح — تراقب اللعبة',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.ghostCyan,
                ),
          ),
        ],
      ),
    );
  }
}
