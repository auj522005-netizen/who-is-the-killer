import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/player.dart';

/// ────────────────────────────────────────────────────────────────
/// PlayerCard — Reusable widget for displaying a player in the game
///
/// Adapts its appearance based on the player's state:
/// - Alive: Neon green accent, full opacity
/// - Eliminated/Ghost: Muted cyan, reduced opacity, strikethrough
/// - Mafioso (revealed): Red accent with skull icon
/// ────────────────────────────────────────────────────────────────
class PlayerCard extends StatelessWidget {
  final Player player;
  final bool showRole;
  final bool isCurrentDefender;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const PlayerCard({
    required this.player,
    this.showRole = false,
    this.isCurrentDefender = false,
    this.isCurrentUser = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isAlive = player.isAlive;
    final isGhost = player.isGhost;
    final isMafioso = player.isMafioso && showRole;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrentDefender
              ? AppColors.neonOrange.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isCurrentDefender
                ? AppColors.neonOrange
                : isMafioso
                    ? AppColors.mafiosoRed
                    : isGhost
                        ? AppColors.ghostCyan.withOpacity(0.3)
                        : AppColors.border,
            width: isCurrentDefender ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: isGhost ? 0.6 : 1.0,
          child: Row(
            children: [
              // Status indicator dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMafioso
                      ? AppColors.mafiosoRed
                      : isAlive
                          ? AppColors.neonGreen
                          : AppColors.ghostCyan,
                  boxShadow: isAlive
                      ? [
                          BoxShadow(
                            color: AppColors.neonGreen.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),

              const SizedBox(width: 12),

              // Player info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            player.characterName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: isMafioso
                                      ? AppColors.neonRed
                                      : isGhost
                                          ? AppColors.ghostCyan
                                          : AppColors.textPrimary,
                                  decoration: isGhost
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neonOrange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              'أنت',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppColors.neonOrange),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      player.alibi,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Role badge (if revealed)
              if (isMafioso)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mafiosoRed,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Icon(
                    Icons.dangerous,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                )
              else if (isGhost)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.ghostCyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Icon(
                    Icons.visibility_off,
                    size: 16,
                    color: AppColors.ghostCyan,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
