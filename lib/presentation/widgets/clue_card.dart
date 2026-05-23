import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/clue.dart';

/// ────────────────────────────────────────────────────────────────
/// ClueCard — Reusable widget for displaying a game clue
///
/// Displays a clue with its title, description, and round number.
/// Supports a revealed/hidden state with neon accent styling.
/// ────────────────────────────────────────────────────────────────
class ClueCard extends StatelessWidget {
  final Clue clue;
  final bool isRevealed;

  const ClueCard({
    required this.clue,
    this.isRevealed = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: clue.isDecisive
              ? AppColors.neonRed
              : AppColors.neonOrange.withOpacity(0.5),
          width: clue.isDecisive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: round number + decisive badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'جولة ${clue.roundNumber}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.neonOrange,
                      ),
                ),
              ),
              if (clue.isDecisive) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    'حاسم',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.neonRed,
                        ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Clue title
          Text(
            clue.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.neonOrange,
                ),
          ),

          const SizedBox(height: 8),

          // Clue description
          Text(
            clue.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
