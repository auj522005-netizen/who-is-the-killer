import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../entities/game_room.dart';
import '../entities/player.dart';
import '../entities/clue.dart';
import '../entities/vote.dart';
import '../entities/game_case.dart';

/// ────────────────────────────────────────────────────────────────
/// GameRepository — Clean data-contract interface for game operations
///
/// Defines the abstract contract that the data layer must implement.
/// All methods return Either<Failure, T> to enforce explicit
/// error handling at the domain level. This interface decouples
/// the domain from any specific data source implementation
/// (Supabase, Firebase, mock, etc.).
/// ────────────────────────────────────────────────────────────────
abstract class GameRepository {
  // ── Room Operations ──────────────────────────────────────────

  /// Creates a new game room with the given configuration.
  Future<Either<Failure, GameRoom>> createRoom({
    required String name,
    required String hostPlayerId,
    required String caseId,
    int maxPlayers = 10,
  });

  /// Joins an existing room using its room code.
  Future<Either<Failure, GameRoom>> joinRoom({
    required String code,
    required String playerId,
  });

  /// Retrieves a room by its ID.
  Future<Either<Failure, GameRoom>> getRoom(String roomId);

  /// Leaves a room, removing the player from the participant list.
  Future<Either<Failure, void>> leaveRoom({
    required String roomId,
    required String playerId,
  });

  // ── Game Lifecycle ───────────────────────────────────────────

  /// Starts the game: assigns roles, computes rounds, transitions to first phase.
  Future<Either<Failure, void>> startGame(String roomId);

  /// Retrieves the current game state for a room.
  Future<Either<Failure, Map<String, dynamic>>> getGameState(String roomId);

  /// Updates the game state (phase, round, etc.) in the data source.
  Future<Either<Failure, void>> updateGameState({
    required String roomId,
    required Map<String, dynamic> state,
  });

  // ── Player Operations ────────────────────────────────────────

  /// Retrieves all players in a room.
  Future<Either<Failure, List<Player>>> getPlayers(String roomId);

  /// Retrieves a specific player by ID.
  Future<Either<Failure, Player>> getPlayer(String playerId);

  /// Eliminates a player (marks as Ghost).
  Future<Either<Failure, Player>> eliminatePlayer({
    required String playerId,
    required int roundNumber,
  });

  // ── Clue Operations ──────────────────────────────────────────

  /// Retrieves the clue for a specific round of a case.
  /// Returns EXACTLY ONE clue per round.
  Future<Either<Failure, Clue>> getClueForRound({
    required String caseId,
    required int roundNumber,
  });

  /// Retrieves all clues for a case (used for preloading).
  Future<Either<Failure, List<Clue>>> getAllClues(String caseId);

  // ── Voting Operations ────────────────────────────────────────

  /// Casts a vote from one player against another.
  Future<Either<Failure, Vote>> castVote({
    required String voterId,
    required String targetId,
    required int roundNumber,
    bool isGhostVote = false,
  });

  /// Retrieves all votes for a specific round.
  Future<Either<Failure, List<Vote>>> getVotesForRound({
    required String roomId,
    required int roundNumber,
  });

  /// Retrieves the final ghost votes from the showdown.
  Future<Either<Failure, List<Vote>>> getGhostVotes(String roomId);

  // ── Case Operations ──────────────────────────────────────────

  /// Retrieves a specific murder case by ID.
  Future<Either<Failure, GameCase>> getCase(String caseId);

  /// Retrieves all available murder cases.
  Future<Either<Failure, List<GameCase>>> getAllCases();

  // ── Real-time Listeners ──────────────────────────────────────

  /// Stream of real-time room state updates.
  Stream<Either<Failure, Map<String, dynamic>>> watchRoomState(String roomId);

  /// Stream of real-time player list updates.
  Stream<Either<Failure, List<Player>>> watchPlayers(String roomId);

  /// Stream of real-time vote updates.
  Stream<Either<Failure, List<Vote>>> watchVotes(String roomId);
}
