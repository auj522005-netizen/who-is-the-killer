import 'package:equatable/equatable.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/clue.dart';
import '../../domain/entities/vote.dart';
import '../../domain/entities/game_room.dart';
import '../../core/constants/game_constants.dart';
import '../../core/utils/game_utils.dart';

/// ────────────────────────────────────────────────────────────────
/// GameState — Core State Machine for the Multiplayer Mystery Game
///
/// This is the central immutable state model that tracks all game
/// data: alive players, ghosts, voting logs, current round index,
/// revealed clues, and the current game phase.
///
/// State transitions are enforced through the [copyWith] method and
/// validated by the [GameController] which manages progression logic.
///
/// Key invariants:
/// - Total Elimination Rounds = Total Players - 2
/// - Exactly ONE clue per round (enforced at controller level)
/// - Eliminated players become Ghosts (isEliminated = true)
/// - Final Showdown triggers when exactly 2 players remain alive
/// - Ghost Votes are cast in the final round only
/// ────────────────────────────────────────────────────────────────
class GameState extends Equatable {
  // ── Room Information ─────────────────────────────────────────
  /// The current game room reference
  final GameRoom? room;

  /// The murder case ID being played
  final String caseId;

  // ── Player Tracking ──────────────────────────────────────────
  /// All players in the game (alive + eliminated)
  final List<Player> players;

  // ── Round Management ─────────────────────────────────────────
  /// Current round index (0-based, 0 = first round)
  final int currentRoundIndex;

  /// Total number of elimination rounds (computed: Players - 2)
  final int totalRounds;

  // ── Phase Management ─────────────────────────────────────────
  /// Current game phase
  final GamePhase currentPhase;

  /// Phase-specific countdown timer (in seconds)
  final int phaseTimerSeconds;

  // ── Clue Tracking ────────────────────────────────────────────
  /// Clues that have been revealed so far (ordered by round)
  final List<Clue> revealedClues;

  /// The clue for the current round (null if not yet revealed)
  final Clue? currentRoundClue;

  // ── Voting Logs ──────────────────────────────────────────────
  /// All votes cast across all rounds
  final List<Vote> votingLog;

  /// Votes for the current round only
  final List<Vote> currentRoundVotes;

  /// Ghost votes cast in the final showdown
  final List<Vote> ghostVotes;

  // ── Elimination Tracking ─────────────────────────────────────
  /// The player eliminated in the current round (null if not yet)
  final Player? eliminatedThisRound;

  // ── Final Showdown ───────────────────────────────────────────
  /// Whether the Final Showdown phase is active
  final bool isFinalShowdownActive;

  /// Defense tokens remaining for survivors (seconds)
  final int defenseTokenSecondsRemaining;

  /// The player currently holding the defense token
  final Player? currentDefender;

  // ── Game Result ──────────────────────────────────────────────
  /// Whether the Mafioso were correctly identified
  final bool? mafiosoIdentified;

  /// The verdict text revealed at game end
  final String? verdictText;

  // ── Error State ──────────────────────────────────────────────
  /// Last error message (for UI display)
  final String? errorMessage;

  const GameState({
    this.room,
    this.caseId = '',
    this.players = const [],
    this.currentRoundIndex = 0,
    this.totalRounds = 0,
    this.currentPhase = GamePhase.lobby,
    this.phaseTimerSeconds = 0,
    this.revealedClues = const [],
    this.currentRoundClue,
    this.votingLog = const [],
    this.currentRoundVotes = const [],
    this.ghostVotes = const [],
    this.eliminatedThisRound,
    this.isFinalShowdownActive = false,
    this.defenseTokenSecondsRemaining = 0,
    this.currentDefender,
    this.mafiosoIdentified,
    this.verdictText,
    this.errorMessage,
  });

  // ── Computed Properties ──────────────────────────────────────

  /// List of alive players
  List<Player> get alivePlayers =>
      players.where((p) => p.isAlive).toList();

  /// List of Ghost players (eliminated)
  List<Player> get ghostPlayers =>
      players.where((p) => p.isGhost).toList();

  /// Number of alive players
  int get aliveCount => alivePlayers.length;

  /// Number of ghost players
  int get ghostCount => ghostPlayers.length;

  /// Whether we are in the final round (last round index)
  bool get isLastRound => currentRoundIndex == totalRounds - 1;

  /// Whether we should trigger the Final Showdown
  /// (exactly 2 players remain alive)
  bool get shouldTriggerFinalShowdown =>
      aliveCount == GameConstants.finalShowdownThreshold;

  /// Current round number (1-based for display)
  int get currentRoundNumber => currentRoundIndex + 1;

  /// Whether voting is currently allowed
  bool get canVote =>
      currentPhase == GamePhase.voting ||
      currentPhase == GamePhase.ghostVoting;

  /// Whether the game has concluded
  bool get isGameOver =>
      currentPhase == GamePhase.verdict ||
      currentPhase == GamePhase.gameComplete;

  /// Whether chat is locked (Final Showdown rule)
  bool get isChatLocked =>
      currentPhase == GamePhase.finalShowdown ||
      currentPhase == GamePhase.ghostVoting;

  /// Get a specific player by ID
  Player? getPlayerById(String playerId) {
    try {
      return players.firstWhere((p) => p.id == playerId);
    } catch (_) {
      return null;
    }
  }

  /// Get the vote target with the highest vote count this round
  Player? getMostVotedPlayerThisRound {
    if (currentRoundVotes.isEmpty) return null;

    final voteCounts = <String, int>{};
    for (final vote in currentRoundVotes) {
      voteCounts[vote.targetId] = (voteCounts[vote.targetId] ?? 0) + 1;
    }

    if (voteCounts.isEmpty) return null;

    final maxVotes = voteCounts.values.reduce((a, b) => a > b ? a : b);
    final targetIds = voteCounts.entries
        .where((e) => e.value == maxVotes)
        .map((e) => e.key)
        .toList();

    // If there's a tie, return null (no elimination on tie)
    if (targetIds.length > 1) return null;

    return getPlayerById(targetIds.first);
  }

  /// Get the final ghost vote result (the accused player)
  Player? getGhostVoteResult {
    if (ghostVotes.isEmpty) return null;

    final voteCounts = <String, int>{};
    for (final vote in ghostVotes) {
      voteCounts[vote.targetId] = (voteCounts[vote.targetId] ?? 0) + 1;
    }

    if (voteCounts.isEmpty) return null;

    final maxVotes = voteCounts.values.reduce((a, b) => a > b ? a : b);
    final targetIds = voteCounts.entries
        .where((e) => e.value == maxVotes)
        .map((e) => e.key)
        .toList();

    if (targetIds.length > 1) return null;

    return getPlayerById(targetIds.first);
  }

  // ── State Copy With ──────────────────────────────────────────

  GameState copyWith({
    GameRoom? room,
    String? caseId,
    List<Player>? players,
    int? currentRoundIndex,
    int? totalRounds,
    GamePhase? currentPhase,
    int? phaseTimerSeconds,
    List<Clue>? revealedClues,
    Clue? currentRoundClue,
    List<Vote>? votingLog,
    List<Vote>? currentRoundVotes,
    List<Vote>? ghostVotes,
    Player? eliminatedThisRound,
    bool? isFinalShowdownActive,
    int? defenseTokenSecondsRemaining,
    Player? currentDefender,
    bool? mafiosoIdentified,
    String? verdictText,
    String? errorMessage,
    bool clearEliminatedThisRound = false,
    bool clearCurrentRoundClue = false,
    bool clearCurrentDefender = false,
    bool clearErrorMessage = false,
    bool clearVerdictText = false,
  }) {
    return GameState(
      room: room ?? this.room,
      caseId: caseId ?? this.caseId,
      players: players ?? this.players,
      currentRoundIndex: currentRoundIndex ?? this.currentRoundIndex,
      totalRounds: totalRounds ?? this.totalRounds,
      currentPhase: currentPhase ?? this.currentPhase,
      phaseTimerSeconds: phaseTimerSeconds ?? this.phaseTimerSeconds,
      revealedClues: revealedClues ?? this.revealedClues,
      currentRoundClue:
          clearCurrentRoundClue ? null : (currentRoundClue ?? this.currentRoundClue),
      votingLog: votingLog ?? this.votingLog,
      currentRoundVotes: currentRoundVotes ?? this.currentRoundVotes,
      ghostVotes: ghostVotes ?? this.ghostVotes,
      eliminatedThisRound:
          clearEliminatedThisRound ? null : (eliminatedThisRound ?? this.eliminatedThisRound),
      isFinalShowdownActive: isFinalShowdownActive ?? this.isFinalShowdownActive,
      defenseTokenSecondsRemaining:
          defenseTokenSecondsRemaining ?? this.defenseTokenSecondsRemaining,
      currentDefender:
          clearCurrentDefender ? null : (currentDefender ?? this.currentDefender),
      mafiosoIdentified: mafiosoIdentified ?? this.mafiosoIdentified,
      verdictText: clearVerdictText ? null : (verdictText ?? this.verdictText),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        room, caseId, players, currentRoundIndex, totalRounds,
        currentPhase, phaseTimerSeconds, revealedClues, currentRoundClue,
        votingLog, currentRoundVotes, ghostVotes, eliminatedThisRound,
        isFinalShowdownActive, defenseTokenSecondsRemaining, currentDefender,
        mafiosoIdentified, verdictText, errorMessage,
      ];
}
