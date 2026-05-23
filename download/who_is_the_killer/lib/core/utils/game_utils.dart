import '../constants/game_constants.dart';

/// ────────────────────────────────────────────────────────────────
/// GameUtils — Utility helpers for game logic computations
///
/// Pure functions that handle core game calculations such as
/// round computation, phase validation, and player state checks.
/// No side effects — suitable for unit testing.
/// ────────────────────────────────────────────────────────────────
abstract class GameUtils {
  /// Computes the total elimination rounds based on player count.
  /// Formula: Total Rounds = Total Players - 2
  ///
  /// Throws [AssertionError] if player count is out of valid range.
  static int computeTotalRounds(int playerCount) {
    assert(
      playerCount >= GameConstants.minPlayers &&
          playerCount <= GameConstants.maxPlayers,
      'Player count must be between ${GameConstants.minPlayers} '
      'and ${GameConstants.maxPlayers}. Got: $playerCount',
    );
    return playerCount - 2;
  }

  /// Validates whether the given player count can start a game.
  static bool isValidPlayerCount(int count) {
    return count >= GameConstants.minPlayers &&
        count <= GameConstants.maxPlayers;
  }

  /// Determines whether the Final Showdown should be triggered.
  /// The Final Showdown occurs when exactly 2 players remain alive.
  static bool isFinalShowdown(int alivePlayerCount) {
    return alivePlayerCount == GameConstants.finalShowdownThreshold;
  }

  /// Determines whether a player is a Ghost (eliminated).
  static bool isGhost(bool isEliminated) => isEliminated;

  /// Generates a room code of the configured length using
  /// uppercase alphanumeric characters (excludes ambiguous chars).
  static String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final buffer = StringBuffer();
    final seed = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < GameConstants.roomCodeLength; i++) {
      final index = (seed * (i + 7) + i * 31) % chars.length;
      buffer.write(chars[index]);
    }
    return buffer.toString();
  }

  /// Computes the current round index as zero-based.
  /// Validates that the round index is within valid bounds.
  static bool isValidRoundIndex(int roundIndex, int totalRounds) {
    return roundIndex >= 0 && roundIndex < totalRounds;
  }

  /// Determines if a clue should be injected for the given round.
  /// Exactly ONE clue per round is the strict rule.
  static bool shouldInjectClue(int roundIndex, int totalRounds) {
    return isValidRoundIndex(roundIndex, totalRounds);
  }

  /// Formats a duration in seconds to MM:SS display format.
  static String formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Calculates the number of Mafioso needed for a game.
  /// Always returns 2 regardless of player count (per game rules).
  static int computeMafiosoCount(int playerCount) {
    // Game rules strictly define 2 Mafioso: 1 main killer + 1 accomplice
    return GameConstants.mafiosoCount;
  }

  /// Calculates the number of Innocent Citizens for a game.
  static int computeInnocentCount(int playerCount) {
    return playerCount - GameConstants.mafiosoCount;
  }
}
