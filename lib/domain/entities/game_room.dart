import 'package:equatable/equatable.dart';

/// ────────────────────────────────────────────────────────────────
/// GamePhase — Enum representing all phases within a single round
///
/// The game follows a strict phase progression:
/// Discussion → Voting → Elimination → (Next Round or Final Showdown)
/// ────────────────────────────────────────────────────────────────
enum GamePhase {
  /// Waiting for players in the lobby
  lobby('lobby'),

  /// Roles are being assigned and revealed privately
  roleReveal('role_reveal'),

  /// Discussion phase — players discuss and analyze clues
  discussion('discussion'),

  /// Clue reveal phase — one global clue is injected per round
  clueReveal('clue_reveal'),

  /// Voting phase — players cast their elimination votes
  voting('voting'),

  /// Elimination reveal — the player with the highest votes is revealed
  eliminationReveal('elimination_reveal'),

  /// Final Showdown — exactly 2 players remain; defense tokens active
  finalShowdown('final_showdown'),

  /// Ghost Voting — ghosts and survivors cast the definitive vote
  ghostVoting('ghost_voting'),

  /// Verdict — game over, Mafioso identities are revealed
  verdict('verdict'),

  /// Game completed
  gameComplete('game_complete');

  const GamePhase(this.value);

  /// Serialized value for persistence / network transmission
  final String value;

  /// Factory constructor from serialized value
  static GamePhase fromValue(String value) {
    return GamePhase.values.firstWhere(
      (phase) => phase.value == value,
      orElse: () => GamePhase.lobby,
    );
  }
}

/// ────────────────────────────────────────────────────────────────
/// GameRoomStatus — Enum representing the room's lifecycle
/// ────────────────────────────────────────────────────────────────
enum GameRoomStatus {
  /// Room is open and waiting for players
  waiting('waiting'),

  /// Game is in progress
  inProgress('in_progress'),

  /// Game has concluded
  completed('completed'),

  /// Room was abandoned
  abandoned('abandoned');

  const GameRoomStatus(this.value);

  final String value;

  static GameRoomStatus fromValue(String value) {
    return GameRoomStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => GameRoomStatus.waiting,
    );
  }
}

/// ────────────────────────────────────────────────────────────────
/// GameRoom — Core domain entity representing a game room
///
/// Contains all room metadata, the selected murder case,
/// active players, and the current game state references.
/// ────────────────────────────────────────────────────────────────
class GameRoom extends Equatable {
  /// Unique room identifier
  final String id;

  /// Room code for joining (e.g., "A3K7XP")
  final String code;

  /// Display name of the room
  final String name;

  /// The host player's ID
  final String hostPlayerId;

  /// The selected murder case ID
  final String caseId;

  /// Current room status
  final GameRoomStatus status;

  /// List of player IDs currently in the room
  final List<String> playerIds;

  /// Maximum allowed players
  final int maxPlayers;

  /// Timestamp when the room was created
  final DateTime createdAt;

  /// Timestamp when the game started (null if not started)
  final DateTime? startedAt;

  /// Timestamp when the game ended (null if not ended)
  final DateTime? endedAt;

  const GameRoom({
    required this.id,
    required this.code,
    required this.name,
    required this.hostPlayerId,
    required this.caseId,
    this.status = GameRoomStatus.waiting,
    this.playerIds = const [],
    this.maxPlayers = 10,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
  });

  /// Whether the room can accept more players
  bool get canJoin => playerIds.length < maxPlayers && status == GameRoomStatus.waiting;

  /// Current player count
  int get playerCount => playerIds.length;

  /// Whether the game is in progress
  bool get isInProgress => status == GameRoomStatus.inProgress;

  GameRoom copyWith({
    String? id,
    String? code,
    String? name,
    String? hostPlayerId,
    String? caseId,
    GameRoomStatus? status,
    List<String>? playerIds,
    int? maxPlayers,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return GameRoom(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      hostPlayerId: hostPlayerId ?? this.hostPlayerId,
      caseId: caseId ?? this.caseId,
      status: status ?? this.status,
      playerIds: playerIds ?? this.playerIds,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, code, name, hostPlayerId, caseId, status,
        playerIds, maxPlayers, createdAt, startedAt, endedAt,
      ];
}
