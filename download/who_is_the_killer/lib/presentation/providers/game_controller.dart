import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/game_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/game_utils.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/clue.dart';
import '../../domain/entities/vote.dart';
import '../../domain/entities/game_room.dart';
import '../../domain/entities/game_case.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/usecases/create_room.dart';
import '../../domain/usecases/join_room.dart';
import '../../domain/usecases/start_game.dart';
import '../../domain/usecases/cast_vote.dart';
import '../../domain/usecases/get_clue.dart';
import '../../data/datasources/local_cases_datasource.dart';
import '../../data/repositories/game_repository_impl.dart';
import 'game_state.dart' as gs;

/// ────────────────────────────────────────────────────────────────
/// GameRepository Provider
///
/// Provides the concrete implementation of GameRepository
/// using the local cases datasource and optional realtime sync.
/// ────────────────────────────────────────────────────────────────
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(
    localDatasource: LocalCasesDatasource(),
  );
});

/// ────────────────────────────────────────────────────────────────
/// Use Case Providers
/// ────────────────────────────────────────────────────────────────
final createRoomProvider = Provider<CreateRoom>((ref) {
  return CreateRoom(ref.watch(gameRepositoryProvider));
});

final joinRoomProvider = Provider<JoinRoom>((ref) {
  return JoinRoom(ref.watch(gameRepositoryProvider));
});

final startGameProvider = Provider<StartGame>((ref) {
  return StartGame(ref.watch(gameRepositoryProvider));
});

final castVoteProvider = Provider<CastVote>((ref) {
  return CastVote(ref.watch(gameRepositoryProvider));
});

final getClueProvider = Provider<GetClue>((ref) {
  return GetClue(ref.watch(gameRepositoryProvider));
});

/// ────────────────────────────────────────────────────────────────
/// Current Player ID Provider
///
/// Stores the current device player's ID. In production,
/// this would come from an auth provider.
/// ────────────────────────────────────────────────────────────────
final currentPlayerIdProvider = StateProvider<String>((ref) => '');

/// ────────────────────────────────────────────────────────────────
/// GameController — Riverpod StateNotifier
///
/// The central state management controller that handles:
/// - Dynamic round progression logic (N - 2 formula)
/// - Conditional clue distribution per round (exactly ONE)
/// - Phase transitions (Lobby → Discussion → Voting → Elimination)
/// - Final Showdown mechanics (2 survivors + defense tokens)
/// - Ghost Voting phase management
/// - Timer countdown management
///
/// All state transitions go through this controller, ensuring
/// that game rules are strictly enforced and the state machine
/// remains consistent.
/// ────────────────────────────────────────────────────────────────
class GameController extends StateNotifier<gs.GameState> {
  final GameRepository _repository;
  final CreateRoom _createRoom;
  final JoinRoom _joinRoom;
  final StartGame _startGame;
  final CastVote _castVote;
  final GetClue _getClue;
  final Ref _ref;

  /// Timer subscription for phase countdowns
  Timer? _phaseTimer;

  /// Timer subscription for defense tokens
  Timer? _defenseTimer;

  GameController({
    required GameRepository repository,
    required CreateRoom createRoom,
    required JoinRoom joinRoom,
    required StartGame startGame,
    required CastVote castVote,
    required GetClue getClue,
    required Ref ref,
  })  : _repository = repository,
        _createRoom = createRoom,
        _joinRoom = joinRoom,
        _startGame = startGame,
        _castVote = castVote,
        _getClue = getClue,
        _ref = ref,
        super(const gs.GameState());

  // ══════════════════════════════════════════════════════════════
  // ROOM LIFECYCLE
  // ══════════════════════════════════════════════════════════════

  /// Creates a new game room with the given parameters
  Future<void> createRoom({
    required String name,
    required String hostPlayerId,
    required String caseId,
    int maxPlayers = 10,
  }) async {
    final result = await _createRoom(
      name: name,
      hostPlayerId: hostPlayerId,
      caseId: caseId,
      maxPlayers: maxPlayers,
    );

    result.fold(
      (failure) => _setError(failure.message),
      (roomId) async {
        // Fetch the created room
        final roomResult = await _repository.getRoom(roomId);
        roomResult.fold(
          (failure) => _setError(failure.message),
          (room) {
            state = state.copyWith(
              room: room,
              caseId: caseId,
              currentPhase: gs.GamePhase.lobby,
            );
          },
        );
      },
    );
  }

  /// Joins an existing room using a room code
  Future<void> joinRoom({
    required String code,
    required String playerId,
  }) async {
    final result = await _joinRoom(code: code, playerId: playerId);

    result.fold(
      (failure) => _setError(failure.message),
      (room) {
        state = state.copyWith(
          room: room,
          caseId: room.caseId,
          currentPhase: gs.GamePhase.lobby,
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // GAME START & ROLE ASSIGNMENT
  // ══════════════════════════════════════════════════════════════

  /// Starts the game: assigns roles, computes rounds, transitions
  /// to role reveal phase.
  Future<void> startGame(String roomId) async {
    final result = await _startGame(roomId);

    result.fold(
      (failure) => _setError(failure.message),
      (_) async {
        // Fetch players with assigned roles
        final playersResult = await _repository.getPlayers(roomId);
        final roomResult = await _repository.getRoom(roomId);

        playersResult.fold(
          (failure) => _setError(failure.message),
          (players) {
            roomResult.fold(
              (failure) => _setError(failure.message),
              (room) {
                // Compute total elimination rounds: N - 2
                final totalRounds = GameUtils.computeTotalRounds(players.length);

                state = state.copyWith(
                  room: room,
                  players: players,
                  totalRounds: totalRounds,
                  currentRoundIndex: 0,
                  currentPhase: gs.GamePhase.roleReveal,
                  caseId: room.caseId,
                );
              },
            );
          },
        );
      },
    );
  }

  /// Transitions from role reveal to the first discussion phase
  void proceedToFirstRound() {
    _transitionToPhase(gs.GamePhase.discussion);
    _startPhaseTimer(GameConstants.discussionDurationSeconds);
  }

  // ══════════════════════════════════════════════════════════════
  // ROUND PROGRESSION LOGIC (N - 2 Formula)
  // ══════════════════════════════════════════════════════════════

  /// Advances to the next phase within the current round,
  /// or transitions to the next round if the current round is complete.
  ///
  /// Phase flow per round:
  /// Discussion → ClueReveal → Voting → EliminationReveal → (next round or Final Showdown)
  void advancePhase() {
    switch (state.currentPhase) {
      case gs.GamePhase.discussion:
        _transitionToClueReveal();
        break;

      case gs.GamePhase.clueReveal:
        _transitionToVoting();
        break;

      case gs.GamePhase.voting:
        _processElimination();
        break;

      case gs.GamePhase.eliminationReveal:
        _advanceToNextRoundOrShowdown();
        break;

      case gs.GamePhase.finalShowdown:
        _transitionToGhostVoting();
        break;

      case gs.GamePhase.ghostVoting:
        _processGhostVoteResult();
        break;

      default:
        break;
    }
  }

  /// Transitions to the clue reveal phase and injects EXACTLY ONE clue
  /// for the current round.
  Future<void> _transitionToClueReveal() async {
    _phaseTimer?.cancel();

    // Fetch the clue for the current round (EXACTLY ONE)
    final result = await _getClue(
      caseId: state.caseId,
      roundNumber: state.currentRoundNumber,
    );

    result.fold(
      (failure) => _setError('Failed to load clue: ${failure.message}'),
      (clue) {
        state = state.copyWith(
          currentPhase: gs.GamePhase.clueReveal,
          currentRoundClue: clue,
          revealedClues: [...state.revealedClues, clue],
          phaseTimerSeconds: 0,
        );

        // Auto-advance to voting after clue reveal delay
        Future.delayed(
          Duration(milliseconds: GameConstants.clueRevealDelayMs),
          () {
            if (state.currentPhase == gs.GamePhase.clueReveal) {
              _transitionToVoting();
            }
          },
        );
      },
    );
  }

  /// Transitions to the voting phase
  void _transitionToVoting() {
    _transitionToPhase(gs.GamePhase.voting);
    _startPhaseTimer(GameConstants.votingDurationSeconds);
  }

  /// Processes elimination after voting concludes
  Future<void> _processElimination() async {
    _phaseTimer?.cancel();

    final eliminated = state.getMostVotedPlayerThisRound;
    if (eliminated == null) {
      // Tie — no elimination this round
      state = state.copyWith(
        currentPhase: gs.GamePhase.eliminationReveal,
      );
      return;
    }

    // Eliminate the player
    final result = await _repository.eliminatePlayer(
      playerId: eliminated.id,
      roundNumber: state.currentRoundNumber,
    );

    result.fold(
      (failure) => _setError(failure.message),
      (updatedPlayer) {
        // Update the players list with the eliminated player
        final updatedPlayers = state.players
            .map((p) => p.id == updatedPlayer.id ? updatedPlayer : p)
            .toList();

        state = state.copyWith(
          players: updatedPlayers,
          eliminatedThisRound: updatedPlayer,
          currentPhase: gs.GamePhase.eliminationReveal,
        );
      },
    );
  }

  /// Determines whether to advance to the next round or trigger
  /// the Final Showdown (when exactly 2 players remain alive).
  void _advanceToNextRoundOrShowdown() {
    if (state.shouldTriggerFinalShowdown) {
      _triggerFinalShowdown();
    } else if (state.currentRoundIndex < state.totalRounds - 1) {
      // Advance to next round
      final nextRoundIndex = state.currentRoundIndex + 1;
      state = state.copyWith(
        currentRoundIndex: nextRoundIndex,
        currentRoundVotes: [],
        clearEliminatedThisRound: true,
        clearCurrentRoundClue: true,
      );
      _transitionToPhase(gs.GamePhase.discussion);
      _startPhaseTimer(GameConstants.discussionDurationSeconds);
    } else {
      // All rounds exhausted — force final showdown
      _triggerFinalShowdown();
    }
  }

  // ══════════════════════════════════════════════════════════════
  // FINAL SHOWDOWN MECHANICS
  // ══════════════════════════════════════════════════════════════

  /// Triggers the Final Showdown when exactly 2 players remain.
  /// Locks general chat and grants each survivor a 60-second
  /// defense token.
  void _triggerFinalShowdown() {
    final survivors = state.alivePlayers;

    state = state.copyWith(
      currentPhase: gs.GamePhase.finalShowdown,
      isFinalShowdownActive: true,
      currentDefender: survivors.isNotEmpty ? survivors.first : null,
      defenseTokenSecondsRemaining: GameConstants.defenseTokenDurationSeconds,
    );

    // Start defense token timer for first survivor
    _startDefenseTokenTimer(survivors);
  }

  /// Manages defense token rotation between the two survivors
  void _startDefenseTokenTimer(List<Player> survivors) {
    _defenseTimer?.cancel();

    _defenseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.defenseTokenSecondsRemaining <= 0) {
        // Switch to the next defender or move to ghost voting
        final currentIdx = survivors.indexOf(state.currentDefender);
        final nextIdx = currentIdx + 1;

        if (nextIdx < survivors.length) {
          // Grant defense token to next survivor
          state = state.copyWith(
            currentDefender: survivors[nextIdx],
            defenseTokenSecondsRemaining: GameConstants.defenseTokenDurationSeconds,
          );
        } else {
          // All survivors have defended — move to ghost voting
          timer.cancel();
          _transitionToGhostVoting();
        }
      } else {
        state = state.copyWith(
          defenseTokenSecondsRemaining: state.defenseTokenSecondsRemaining - 1,
        );
      }
    });
  }

  /// Transitions to the Ghost Voting phase where ghosts and
  /// survivors cast the final definitive vote.
  void _transitionToGhostVoting() {
    _defenseTimer?.cancel();

    state = state.copyWith(
      currentPhase: gs.GamePhase.ghostVoting,
      ghostVotes: [],
    );

    _startPhaseTimer(GameConstants.votingDurationSeconds);
  }

  /// Processes the result of the Ghost Vote to determine if
  /// the Mafioso was correctly identified.
  void _processGhostVoteResult() {
    _phaseTimer?.cancel();

    final accused = state.getGhostVoteResult;

    if (accused == null) {
      // Tie in ghost vote — Mafioso wins
      _resolveGame(mafiosoIdentified: false);
      return;
    }

    // Check if the accused is a Mafioso
    final isMafioso = accused.isMafioso;
    _resolveGame(mafiosoIdentified: isMafioso);
  }

  /// Resolves the game by revealing the verdict
  Future<void> _resolveGame({required bool mafiosoIdentified}) async {
    // Fetch the case verdict text
    final caseResult = await _repository.getCase(state.caseId);

    caseResult.fold(
      (failure) {
        state = state.copyWith(
          currentPhase: gs.GamePhase.verdict,
          mafiosoIdentified: mafiosoIdentified,
        );
      },
      (gameCase) {
        state = state.copyWith(
          currentPhase: gs.GamePhase.verdict,
          mafiosoIdentified: mafiosoIdentified,
          verdictText: gameCase.verdictText,
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // VOTING OPERATIONS
  // ══════════════════════════════════════════════════════════════

  /// Casts an elimination vote from the current player
  Future<void> vote(String targetId) async {
    if (!state.canVote) {
      _setError('Voting is not allowed in the current phase.');
      return;
    }

    final currentPlayerId = _ref.read(currentPlayerIdProvider);
    final isGhostVote = state.currentPhase == gs.GamePhase.ghostVoting;

    final result = await _castVote(
      voterId: currentPlayerId,
      targetId: targetId,
      roundNumber: state.currentRoundNumber,
      isGhostVote: isGhostVote,
    );

    result.fold(
      (failure) => _setError(failure.message),
      (vote) {
        if (isGhostVote) {
          state = state.copyWith(
            ghostVotes: [...state.ghostVotes, vote],
          );
        } else {
          state = state.copyWith(
            currentRoundVotes: [...state.currentRoundVotes, vote],
            votingLog: [...state.votingLog, vote],
          );
        }
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TIMER MANAGEMENT
  // ══════════════════════════════════════════════════════════════

  /// Starts a countdown timer for the current phase
  void _startPhaseTimer(int durationSeconds) {
    _phaseTimer?.cancel();

    state = state.copyWith(phaseTimerSeconds: durationSeconds);

    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.phaseTimerSeconds <= 0) {
        timer.cancel();
        advancePhase();
      } else {
        state = state.copyWith(
          phaseTimerSeconds: state.phaseTimerSeconds - 1,
        );
      }
    });
  }

  // ══════════════════════════════════════════════════════════════
  // PHASE TRANSITIONS
  // ══════════════════════════════════════════════════════════════

  /// Transitions to a new game phase
  void _transitionToPhase(gs.GamePhase phase) {
    state = state.copyWith(currentPhase: phase);
  }

  // ══════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ══════════════════════════════════════════════════════════════

  /// Sets an error message in the state
  void _setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  /// Clears the current error message
  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }

  // ══════════════════════════════════════════════════════════════
  // CLEANUP
  // ══════════════════════════════════════════════════════════════

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _defenseTimer?.cancel();
    super.dispose();
  }
}

/// ────────────────────────────────────────────────────────────────
/// GameController Provider
///
/// The main provider for game state management. All game logic
/// flows through this provider and its StateNotifier.
/// ────────────────────────────────────────────────────────────────
final gameControllerProvider =
    StateNotifierProvider<GameController, gs.GameState>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return GameController(
    repository: repository,
    createRoom: ref.watch(createRoomProvider),
    joinRoom: ref.watch(joinRoomProvider),
    startGame: ref.watch(startGameProvider),
    castVote: ref.watch(castVoteProvider),
    getClue: ref.watch(getClueProvider),
    ref: ref,
  );
});
