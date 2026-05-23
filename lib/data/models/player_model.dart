import '../../domain/entities/player.dart';

/// ────────────────────────────────────────────────────────────────
/// PlayerModel — Data layer representation of a Player
///
/// Extends the domain entity with serialization capabilities.
/// Handles JSON ↔ Domain conversion for network and local storage.
/// ────────────────────────────────────────────────────────────────
class PlayerModel extends Player {
  const PlayerModel({
    required super.id,
    required super.name,
    required super.role,
    required super.alibi,
    required super.secrets,
    required super.characterName,
    super.isEliminated,
    super.eliminatedRound,
    super.avatarUrl,
    super.connectionState,
  });

  /// Creates a PlayerModel from a JSON map (from server/local storage)
  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: PlayerRole.fromValue(json['role'] as String),
      alibi: json['alibi'] as String,
      secrets: json['secrets'] as String,
      characterName: json['character_name'] as String,
      isEliminated: json['is_eliminated'] as bool? ?? false,
      eliminatedRound: json['eliminated_round'] as int?,
      avatarUrl: json['avatar_url'] as String?,
      connectionState: PlayerState.fromValue(
        json['connection_state'] as String? ?? 'alive',
      ),
    );
  }

  /// Converts this model to a JSON map for network/local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.value,
      'alibi': alibi,
      'secrets': secrets,
      'character_name': characterName,
      'is_eliminated': isEliminated,
      'eliminated_round': eliminatedRound,
      'avatar_url': avatarUrl,
      'connection_state': connectionState.value,
    };
  }

  /// Creates a PlayerModel from a domain Player entity
  factory PlayerModel.fromEntity(Player player) {
    return PlayerModel(
      id: player.id,
      name: player.name,
      role: player.role,
      alibi: player.alibi,
      secrets: player.secrets,
      characterName: player.characterName,
      isEliminated: player.isEliminated,
      eliminatedRound: player.eliminatedRound,
      avatarUrl: player.avatarUrl,
      connectionState: player.connectionState,
    );
  }
}
