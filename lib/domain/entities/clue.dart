import 'package:equatable/equatable.dart';

/// ────────────────────────────────────────────────────────────────
/// Clue — Domain entity representing a single piece of evidence
///
/// Each round injects EXACTLY ONE global clue that progressively
/// narrows down the suspicion towards the killer(s). Clues are
/// ordered by round and become increasingly specific.
/// ────────────────────────────────────────────────────────────────
class Clue extends Equatable {
  /// Unique identifier for this clue
  final String id;

  /// The murder case this clue belongs to
  final String caseId;

  /// The round number this clue is revealed in (1-based)
  final int roundNumber;

  /// The headline / title of the clue
  final String title;

  /// The detailed description of the evidence
  final String description;

  /// Whether this is the final decisive clue
  final bool isDecisive;

  /// Timestamp when the clue was created in the database
  final DateTime createdAt;

  const Clue({
    required this.id,
    required this.caseId,
    required this.roundNumber,
    required this.title,
    required this.description,
    this.isDecisive = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, caseId, roundNumber, title, description, isDecisive, createdAt];
}
