import '../../domain/entities/game_room.dart';

/// ────────────────────────────────────────────────────────────────
/// GameRoomModel — Data layer representation of a GameRoom
/// ────────────────────────────────────────────────────────────────
class GameRoomModel extends GameRoom {
  const GameRoomModel({
    required super.id,
    required super.code,
    required super.name,
    required super.hostPlayerId,
    required super.caseId,
    super.status,
    super.playerIds,
    super.maxPlayers,
    required super.createdAt,
    super.startedAt,
    super.endedAt,
  });

  factory GameRoomModel.fromJson(Map<String, dynamic> json) {
    return GameRoomModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      hostPlayerId: json['host_player_id'] as String,
      caseId: json['case_id'] as String,
      status: GameRoomStatus.fromValue(json['status'] as String),
      playerIds: (json['player_ids'] as List<dynamic>).cast<String>(),
      maxPlayers: json['max_players'] as int? ?? 10,
      createdAt: DateTime.parse(json['created_at'] as String),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'host_player_id': hostPlayerId,
      'case_id': caseId,
      'status': status.value,
      'player_ids': playerIds,
      'max_players': maxPlayers,
      'created_at': createdAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
    };
  }

  factory GameRoomModel.fromEntity(GameRoom room) {
    return GameRoomModel(
      id: room.id,
      code: room.code,
      name: room.name,
      hostPlayerId: room.hostPlayerId,
      caseId: room.caseId,
      status: room.status,
      playerIds: room.playerIds,
      maxPlayers: room.maxPlayers,
      createdAt: room.createdAt,
      startedAt: room.startedAt,
      endedAt: room.endedAt,
    );
  }
}
