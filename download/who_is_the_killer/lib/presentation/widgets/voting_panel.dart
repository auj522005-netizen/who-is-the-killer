import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/vote.dart';

/// ────────────────────────────────────────────────────────────────
/// VotingPanel — Widget for casting and displaying votes
///
/// Shows the list of votable players and tracks current vote counts.
/// Supports both regular voting and ghost voting phases.
/// ────────────────────────────────────────────────────────────────
class VotingPanel extends StatelessWidget {
  final List<Player> players;
  final void Function(String targetId) onVote;
  final List<Vote> currentVotes;
  final bool isGhostVoting;

  const VotingPanel({
    required this.players,
    required this.onVote,
    this.currentVotes = const [],
    this.isGhostVoting = false,
    super.key,
  });

  /// Computes vote counts for each target
  Map<String, int> _computeVoteCounts() {
    final counts = <String, int>{};
    for (final vote in currentVotes) {
      counts[vote.targetId] = (counts[vote.targetId] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final voteCounts = _computeVoteCounts();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final voteCount = voteCounts[player.id] ?? 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onVote(player.id),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isGhostVoting
                        ? AppColors.ghostCyan.withOpacity(0.3)
                        : AppColors.neonRed.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    // Vote button indicator
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isGhostVoting
                            ? AppColors.ghostCyan.withOpacity(0.15)
                            : AppColors.neonRed.withOpacity(0.15),
                        border: Border.all(
                          color: isGhostVoting
                              ? AppColors.ghostCyan
                              : AppColors.neonRed,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isGhostVoting ? Icons.ghost : Icons.how_to_vote,
                        size: 16,
                        color: isGhostVoting
                            ? AppColors.ghostCyan
                            : AppColors.neonRed,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Player name
                    Expanded(
                      child: Text(
                        player.characterName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),

                    // Vote count badge
                    if (voteCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neonOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$voteCount',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
