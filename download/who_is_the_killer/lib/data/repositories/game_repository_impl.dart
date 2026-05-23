import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/game_room.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/clue.dart';
import '../../domain/entities/vote.dart';
import '../../domain/entities/game_case.dart';
import '../../domain/repositories/game_repository.dart';
import '../models/player_model.dart';
import '../models/clue_model.dart';
import '../models/vote_model.dart';
import '../models/game_room_model.dart';
import '../models/game_case_model.dart';
import '../datasources/local_cases_datasource.dart';
import '../datasources/realtime_datasource.dart';

/// ────────────────────────────────────────────────────────────────
/// GameRepositoryImpl — Concrete implementation of GameRepository
///
/// Orchestrates data operations between the local cases datasource
/// and the real-time sync datasource. All data layer operations
/// are wrapped in try-catch blocks with explicit failure mapping.
///
/// This implementation uses in-memory state for demonstration
/// purposes. In production, replace with Supabase/Firebase calls.
/// ────────────────────────────────────────────────────────────────
class GameRepositoryImpl implements GameRepository {
  final LocalCasesDatasource _localDatasource;
  final RealtimeDatasource? _realtimeDatasource;

  /// In-memory state stores (replace with remote DB in production)
  final Map<String, GameRoom> _rooms = {};
  final Map<String, Player> _players = {};
  final Map<String, Vote> _votes = {};
  final Map<String, List<Clue>> _cluesCache = {};

  GameRepositoryImpl({
    required LocalCasesDatasource localDatasource,
    RealtimeDatasource? realtimeDatasource,
  })  : _localDatasource = localDatasource,
        _realtimeDatasource = realtimeDatasource;

  // ── Room Operations ──────────────────────────────────────────

  @override
  Future<Either<Failure, GameRoom>> createRoom({
    required String name,
    required String hostPlayerId,
    required String caseId,
    int maxPlayers = 10,
  }) async {
    try {
      final now = DateTime.now();
      final code = _generateRoomCode();
      final room = GameRoom(
        id: 'room_${now.millisecondsSinceEpoch}',
        code: code,
        name: name,
        hostPlayerId: hostPlayerId,
        caseId: caseId,
        status: GameRoomStatus.waiting,
        playerIds: [hostPlayerId],
        maxPlayers: maxPlayers,
        createdAt: now,
      );
      _rooms[room.id] = room;

      // Preload clues for the selected case
      final cluesData = _localDatasource.getAllCluesForCase(caseId);
      final clues = cluesData.map((json) => ClueModel.fromJson(json)).toList();
      _cluesCache[caseId] = clues;

      // Broadcast room creation if realtime is available
      await _realtimeDatasource?.broadcastRoomState(
        GameRoomModel.fromEntity(room).toJson(),
      );

      return Right(room);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create room: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, GameRoom>> joinRoom({
    required String code,
    required String playerId,
  }) async {
    try {
      final roomEntry = _rooms.entries.firstWhere(
        (entry) => entry.value.code == code,
        orElse: () => throw Exception('Room not found'),
      );

      final room = roomEntry.value;

      if (room.playerCount >= room.maxPlayers) {
        return const Left(RoomFullFailure());
      }

      if (room.status != GameRoomStatus.waiting) {
        return const Left(GameRuleViolationFailure(
          message: 'Cannot join a game that is already in progress.',
        ));
      }

      final updatedRoom = room.copyWith(
        playerIds: [...room.playerIds, playerId],
      );
      _rooms[room.id] = updatedRoom;

      return Right(updatedRoom);
    } on StateError {
      return const Left(RoomNotFoundFailure());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to join room: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, GameRoom>> getRoom(String roomId) async {
    try {
      final room = _rooms[roomId];
      if (room == null) {
        return const Left(RoomNotFoundFailure());
      }
      return Right(room);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get room: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveRoom({
    required String roomId,
    required String playerId,
  }) async {
    try {
      final room = _rooms[roomId];
      if (room == null) {
        return const Left(RoomNotFoundFailure());
      }

      final updatedPlayerIds = room.playerIds.where((id) => id != playerId).toList();
      _rooms[roomId] = room.copyWith(playerIds: updatedPlayerIds);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to leave room: ${e.toString()}'));
    }
  }

  // ── Game Lifecycle ───────────────────────────────────────────

  @override
  Future<Either<Failure, void>> startGame(String roomId) async {
    try {
      final room = _rooms[roomId];
      if (room == null) {
        return const Left(RoomNotFoundFailure());
      }

      if (room.playerCount < 5) {
        return const Left(InvalidPlayerCountFailure(
          message: 'Need at least 5 players to start the game.',
        ));
      }

      // Assign roles from the case data
      final playersData = _localDatasource.getPlayersForCase(room.caseId);
      for (int i = 0; i < playersData.length && i < room.playerIds.length; i++) {
        final playerJson = playersData[i];
        final playerId = room.playerIds[i];
        final player = PlayerModel.fromJson({
          ...playerJson,
          'id': playerId,
          'name': playerJson['name'] as String,
        });
        _players[playerId] = player;
      }

      _rooms[roomId] = room.copyWith(
        status: GameRoomStatus.inProgress,
        startedAt: DateTime.now(),
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to start game: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGameState(String roomId) async {
    try {
      final room = _rooms[roomId];
      if (room == null) {
        return const Left(RoomNotFoundFailure());
      }
      return Right(GameRoomModel.fromEntity(room).toJson());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get game state: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateGameState({
    required String roomId,
    required Map<String, dynamic> state,
  }) async {
    try {
      final room = _rooms[roomId];
      if (room == null) {
        return const Left(RoomNotFoundFailure());
      }

      // Merge state updates into the existing room
      final updatedRoom = GameRoomModel.fromJson({
        ...GameRoomModel.fromEntity(room).toJson(),
        ...state,
      });
      _rooms[roomId] = updatedRoom;

      await _realtimeDatasource?.broadcastRoomState(state);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update game state: ${e.toString()}'));
    }
  }

  // ── Player Operations ────────────────────────────────────────

  @override
  Future<Either<Failure, List<Player>>> getPlayers(String roomId) async {
    try {
      final room = _rooms[roomId];
      if (room == null) {
        return const Left(RoomNotFoundFailure());
      }

      final players = room.playerIds
          .map((id) => _players[id])
          .where((player) => player != null)
          .cast<Player>()
          .toList();

      return Right(players);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get players: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Player>> getPlayer(String playerId) async {
    try {
      final player = _players[playerId];
      if (player == null) {
        return Left(ServerFailure(message: 'Player not found: $playerId'));
      }
      return Right(player);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get player: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Player>> eliminatePlayer({
    required String playerId,
    required int roundNumber,
  }) async {
    try {
      final player = _players[playerId];
      if (player == null) {
        return Left(ServerFailure(message: 'Player not found: $playerId'));
      }

      final eliminatedPlayer = player.copyWith(
        isEliminated: true,
        eliminatedRound: roundNumber,
        connectionState: PlayerState.eliminated,
      );
      _players[playerId] = eliminatedPlayer;

      return Right(eliminatedPlayer);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to eliminate player: ${e.toString()}'));
    }
  }

  // ── Clue Operations ──────────────────────────────────────────

  @override
  Future<Either<Failure, Clue>> getClueForRound({
    required String caseId,
    required int roundNumber,
  }) async {
    try {
      // Try cache first
      final cachedClues = _cluesCache[caseId];
      if (cachedClues != null) {
        try {
          final clue = cachedClues.firstWhere(
            (c) => c.roundNumber == roundNumber,
          );
          return Right(clue);
        } catch (_) {
          return Left(DataParsingFailure(
            message: 'No clue found for round $roundNumber in case $caseId',
          ));
        }
      }

      // Fallback to datasource
      final clueData = _localDatasource.getClueForRound(caseId, roundNumber);
      if (clueData == null) {
        return Left(DataParsingFailure(
          message: 'No clue found for round $roundNumber in case $caseId',
        ));
      }

      final clue = ClueModel.fromJson(clueData);
      return Right(clue);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get clue: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Clue>>> getAllClues(String caseId) async {
    try {
      final cachedClues = _cluesCache[caseId];
      if (cachedClues != null) {
        return Right(cachedClues);
      }

      final cluesData = _localDatasource.getAllCluesForCase(caseId);
      final clues = cluesData.map((json) => ClueModel.fromJson(json)).toList();
      _cluesCache[caseId] = clues;

      return Right(clues);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get clues: ${e.toString()}'));
    }
  }

  // ── Voting Operations ────────────────────────────────────────

  @override
  Future<Either<Failure, Vote>> castVote({
    required String voterId,
    required String targetId,
    required int roundNumber,
    bool isGhostVote = false,
  }) async {
    try {
      final vote = VoteModel(
        id: 'vote_${DateTime.now().millisecondsSinceEpoch}_$voterId',
        voterId: voterId,
        targetId: targetId,
        roundNumber: roundNumber,
        isGhostVote: isGhostVote,
        createdAt: DateTime.now(),
      );
      _votes[vote.id] = vote;

      await _realtimeDatasource?.broadcastVote(
        VoteModel.fromEntity(vote).toJson(),
      );

      return Right(vote);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to cast vote: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vote>>> getVotesForRound({
    required String roomId,
    required int roundNumber,
  }) async {
    try {
      final roundVotes = _votes.values
          .where((vote) => vote.roundNumber == roundNumber && !vote.isGhostVote)
          .toList();
      return Right(roundVotes);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get votes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vote>>> getGhostVotes(String roomId) async {
    try {
      final ghostVotes = _votes.values
          .where((vote) => vote.isGhostVote)
          .toList();
      return Right(ghostVotes);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get ghost votes: ${e.toString()}'));
    }
  }

  // ── Case Operations ──────────────────────────────────────────

  @override
  Future<Either<Failure, GameCase>> getCase(String caseId) async {
    try {
      final caseData = _localDatasource.getCaseById(caseId);
      if (caseData == null) {
        return Left(ServerFailure(message: 'Case not found: $caseId'));
      }
      return Right(GameCaseModel.fromJson(caseData));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get case: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<GameCase>>> getAllCases() async {
    try {
      final casesData = _localDatasource.getAllCases();
      final cases = casesData
          .map((json) => GameCaseModel.fromJson(json))
          .toList();
      return Right(cases);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get cases: ${e.toString()}'));
    }
  }

  // ── Real-time Listeners ──────────────────────────────────────

  @override
  Stream<Either<Failure, Map<String, dynamic>>> watchRoomState(String roomId) async* {
    if (_realtimeDatasource == null) {
      yield Left(WebSocketFailure());
      return;
    }
    try {
      await for (final state in _realtimeDatasource!.watchRoomState()) {
        yield Right(state);
      }
    } catch (e) {
      yield Left(WebSocketFailure());
    }
  }

  @override
  Stream<Either<Failure, List<Player>>> watchPlayers(String roomId) async* {
    if (_realtimeDatasource == null) {
      yield Left(WebSocketFailure());
      return;
    }
    try {
      await for (final playersData in _realtimeDatasource!.watchPlayers()) {
        final players = playersData
            .map((json) => PlayerModel.fromJson(json))
            .toList();
        yield Right(players);
      }
    } catch (e) {
      yield Left(WebSocketFailure());
    }
  }

  @override
  Stream<Either<Failure, List<Vote>>> watchVotes(String roomId) async* {
    if (_realtimeDatasource == null) {
      yield Left(WebSocketFailure());
      return;
    }
    try {
      await for (final votesData in _realtimeDatasource!.watchVotes()) {
        final votes = votesData
            .map((json) => VoteModel.fromJson(json))
            .toList();
        yield Right(votes);
      }
    } catch (e) {
      yield Left(WebSocketFailure());
    }
  }

  // ── Private Helpers ──────────────────────────────────────────

  /// Generates a unique room code
  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final buffer = StringBuffer();
    final seed = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 6; i++) {
      final index = (seed * (i + 7) + i * 31) % chars.length;
      buffer.write(chars[index]);
    }
    return buffer.toString();
  }
}
