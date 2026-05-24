import 'package:equatable/equatable.dart';

/// ────────────────────────────────────────────────────────────────
/// PlayerRole — Enum representing the secret role of a player
///
/// Each player is assigned one of these roles at game start.
/// The Mafioso roles are hidden from other players.
/// ────────────────────────────────────────────────────────────────
enum PlayerRole {
  /// The primary killer — the main Mafioso
  mafiosoMain('mafioso_main', 'Mafioso Main'),

  /// The accomplice — secondary Mafioso who assists the main killer
  mafiosoAccomplice('mafioso_accomplice', 'Mafioso Accomplice'),

  /// An innocent citizen with no special investigative powers
  innocentCitizen('innocent_citizen', 'Innocent Citizen'),

  /// An innocent who is under threat from the Mafioso
  innocentThreatened('innocent_threatened', 'Innocent Threatened'),

  /// An innocent who acts as an investigator / detective
  innocentInvestigator('innocent_investigator', 'Innocent Investigator'),

  /// An innocent who is a primary suspect (red herring)
  innocentSuspect('innocent_suspect', 'Innocent Suspect'),

  /// An innocent who is a key witness
  innocentWitness('innocent_witness', 'Innocent Witness');

  const PlayerRole(this.value, this.displayName);

  /// Serialized value for persistence / network transmission
  final String value;

  /// Human-readable display name
  final String displayName;

  /// Whether this role is a Mafioso (Killer)
  bool get isMafioso =>
      this == PlayerRole.mafiosoMain || this == PlayerRole.mafiosoAccomplice;

  /// Whether this role is any Innocent variant
  bool get isInnocent => !isMafioso;

  /// Factory constructor from serialized value
  static PlayerRole fromValue(String value) {
    return PlayerRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => PlayerRole.innocentCitizen,
    );
  }
}

/// ────────────────────────────────────────────────────────────────
/// PlayerState — Enum representing the current alive/eliminated state
/// ────────────────────────────────────────────────────────────────
enum PlayerState {
  /// Player is alive and active in the game
  alive('alive'),

  /// Player has been eliminated and is now a Ghost
  eliminated('eliminated'),

  /// Player has disconnected from the room
  disconnected('disconnected');

  const PlayerState(this.value);

  final String value;

  static PlayerState fromValue(String value) {
    return PlayerState.values.firstWhere(
      (state) => state.value == value,
      orElse: () => PlayerState.disconnected,
    );
  }
}

/// ────────────────────────────────────────────────────────────────
/// Player — Core domain entity representing a game participant
///
/// Contains the player's identity, secret role, declared alibi,
/// hidden secrets, and current state within the game.
/// ────────────────────────────────────────────────────────────────
class Player extends Equatable {
  /// Unique identifier for this player
  final String id;

  /// Display name chosen by the player
  final String name;

  /// The secret role assigned to this player (hidden from others)
  final PlayerRole role;

  /// The player's declared alibi (public information)
  final String alibi;

  /// The player's hidden secrets (revealed only to the player themselves)
  final String secrets;

  /// The character name in the murder case narrative
  final String characterName;

  /// Whether this player has been eliminated
  final bool isEliminated;

  /// The round in which this player was eliminated (null if alive)
  final int? eliminatedRound;

  /// Avatar URL or asset path
  final String? avatarUrl;

  /// Connection state
  final PlayerState connectionState;

  const Player({
    required this.id,
    required this.name,
    required this.role,
    required this.alibi,
    required this.secrets,
    required this.characterName,
    this.isEliminated = false,
    this.eliminatedRound,
    this.avatarUrl,
    this.connectionState = PlayerState.alive,
  });

  /// Whether this player is currently a Ghost (eliminated)
  bool get isGhost => isEliminated;

  /// Whether this player is currently alive
  bool get isAlive => !isEliminated;

  /// Whether this player is a Mafioso
  bool get isMafioso => role.isMafioso;

  /// Whether this player is an Innocent
  bool get isInnocent => role.isInnocent;

  /// Creates a copy of this player with updated fields
  Player copyWith({
    String? id,
    String? name,
    PlayerRole? role,
    String? alibi,
    String? secrets,
    String? characterName,
    bool? isEliminated,
    int? eliminatedRound,
    String? avatarUrl,
    PlayerState? connectionState,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      alibi: alibi ?? this.alibi,
      secrets: secrets ?? this.secrets,
      characterName: characterName ?? this.characterName,
      isEliminated: isEliminated ?? this.isEliminated,
      eliminatedRound: eliminatedRound ?? this.eliminatedRound,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      connectionState: connectionState ?? this.connectionState,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        alibi,
        secrets,
        characterName,
        isEliminated,
        eliminatedRound,
        avatarUrl,
        connectionState,
      ];
}
