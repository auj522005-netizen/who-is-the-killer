import 'package:equatable/equatable.dart';

/// ────────────────────────────────────────────────────────────────
/// GameCase — Domain entity representing a complete murder case
///
/// Contains the full narrative, all character profiles (with
/// secret roles), progressive clues, and the verdict text.
/// Each case is a self-contained mystery scenario.
/// ────────────────────────────────────────────────────────────────
class GameCase extends Equatable {
  /// Unique identifier for this case
  final String id;

  /// Display title of the case
  final String title;

  /// Brief narrative subtitle / tagline
  final String subtitle;

  /// Full narrative description of the crime scene
  final String description;

  /// Ordered list of clue IDs associated with this case
  final List<String> clueIds;

  /// The verdict / solution text revealed at game end
  final String verdictText;

  /// Number of players this case supports
  final int supportedPlayerCount;

  /// Timestamp when the case was created
  final DateTime createdAt;

  const GameCase({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    this.clueIds = const [],
    required this.verdictText,
    required this.supportedPlayerCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, title, subtitle, description, clueIds,
        verdictText, supportedPlayerCount, createdAt,
      ];
}
