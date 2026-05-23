import '../../domain/entities/vote.dart';

/// ────────────────────────────────────────────────────────────────
/// VoteModel — Data layer representation of a Vote
/// ────────────────────────────────────────────────────────────────
class VoteModel extends Vote {
  const VoteModel({
    required super.id,
    required super.voterId,
    required super.targetId,
    required super.roundNumber,
    super.isGhostVote,
    required super.createdAt,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      id: json['id'] as String,
      voterId: json['voter_id'] as String,
      targetId: json['target_id'] as String,
      roundNumber: json['round_number'] as int,
      isGhostVote: json['is_ghost_vote'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voter_id': voterId,
      'target_id': targetId,
      'round_number': roundNumber,
      'is_ghost_vote': isGhostVote,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VoteModel.fromEntity(Vote vote) {
    return VoteModel(
      id: vote.id,
      voterId: vote.voterId,
      targetId: vote.targetId,
      roundNumber: vote.roundNumber,
      isGhostVote: vote.isGhostVote,
      createdAt: vote.createdAt,
    );
  }
}
