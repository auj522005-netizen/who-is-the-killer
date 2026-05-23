/// ────────────────────────────────────────────────────────────────
/// GameConstants — Central configuration for all game mechanics
///
/// Enforces the strict game rules including player range,
/// elimination round formula, defense timers, and phase durations.
/// ────────────────────────────────────────────────────────────────
abstract class GameConstants {
  // ── Player Range ─────────────────────────────────────────────
  /// Minimum number of players required to start a game
  static const int minPlayers = 5;

  /// Maximum number of players allowed in a room
  static const int maxPlayers = 10;

  // ── Role Distribution ────────────────────────────────────────
  /// Number of Mafioso (Killers) assigned per game — always 2
  static const int mafiosoCount = 2;

  /// Number of main killers (1 primary + 1 accomplice)
  static const int mainKillerIndex = 0;
  static const int accompliceIndex = 1;

  // ── Round Formula ────────────────────────────────────────────
  /// Computes the total elimination rounds dynamically:
  /// Total Elimination Rounds = Total Present Players - 2
  ///
  /// Example: 6 players → 4 rounds; 10 players → 8 rounds
  static int computeTotalRounds(int playerCount) {
    assert(
      playerCount >= minPlayers && playerCount <= maxPlayers,
      'Player count must be between $minPlayers and $maxPlayers',
    );
    return playerCount - 2;
  }

  // ── Phase Durations (seconds) ────────────────────────────────
  /// Discussion phase duration per round
  static const int discussionDurationSeconds = 120;

  /// Voting phase duration per round
  static const int votingDurationSeconds = 60;

  /// Final Showdown defense token duration (seconds)
  static const int defenseTokenDurationSeconds = 60;

  /// Clue reveal animation delay (milliseconds)
  static const int clueRevealDelayMs = 1500;

  // ── Final Showdown ───────────────────────────────────────────
  /// The threshold of alive players that triggers the Final Showdown
  static const int finalShowdownThreshold = 2;

  // ── Ghost Mechanics ──────────────────────────────────────────
  /// Whether ghosts can participate in regular discussion chat
  static const bool ghostsCanChatInDiscussion = true;

  /// Whether ghosts are locked from general chat in final round
  static const bool ghostsLockedInFinalRound = true;

  // ── Room Configuration ───────────────────────────────────────
  /// Room code length for joining
  static const int roomCodeLength = 6;

  /// Maximum time to wait for players before auto-start (seconds)
  static const int lobbyWaitTimeoutSeconds = 300;

  // ── UI Constants ─────────────────────────────────────────────
  /// Maximum visible players in the player list before scrolling
  static const int visiblePlayersBeforeScroll = 5;

  /// Animation duration for phase transitions (milliseconds)
  static const int phaseTransitionDurationMs = 800;

  /// Pulse animation duration for active player indicator (milliseconds)
  static const int pulseAnimationDurationMs = 1500;
}
