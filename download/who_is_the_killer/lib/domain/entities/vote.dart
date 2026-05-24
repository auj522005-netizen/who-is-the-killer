import 'package:equatable/equatable.dart';

/// ────────────────────────────────────────────────────────────────
/// Vote — Domain entity representing a single vote cast by a player
///
/// Records who voted, whom they voted for, and in which round.
/// Votes are immutable once cast and form the voting log.
/// ────────────────────────────────────────────────────────────────
class Vote extends Equatable {
  /// Unique identifier for this vote
  final String id;

  /// The ID of the player who cast this vote
  final String voterId;

  /// The ID of the player being voted against
  final String targetId;

  /// The round number in which this vote was cast (1-based)
  final int roundNumber;

  /// Whether this is a Ghost vote (cast in the final showdown)
  final bool isGhostVote;

  /// Timestamp when the vote was cast
  final DateTime createdAt;

  const Vote({
    required this.id,
    required this.voterId,
    required this.targetId,
    required this.roundNumber,
    this.isGhostVote = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, voterId, targetId, roundNumber, isGhostVote, createdAt];
}
