import 'package:equatable/equatable.dart';

/// ────────────────────────────────────────────────────────────────
/// Failure — Base domain failure class for clean error handling
///
/// All domain-level failures extend this class, enabling
/// pattern-matching in the presentation layer. Failures are
/// immutable value objects compared by their properties.
/// ────────────────────────────────────────────────────────────────
abstract class Failure extends Equatable {
  /// Human-readable error message
  final String message;

  /// Optional error code for programmatic handling
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// ── Network Failures ──────────────────────────────────────────

/// Failure when the device cannot connect to the server
class NetworkFailure extends Failure {
  const NetworkFailure({super.code})
      : super(message: 'Unable to connect to the server. Please check your connection.');
}

/// Failure when a request times out
class TimeoutFailure extends Failure {
  const TimeoutFailure({super.code})
      : super(message: 'The request timed out. Please try again.');
}

/// Failure when the WebSocket connection is interrupted
class WebSocketFailure extends Failure {
  const WebSocketFailure({super.code})
      : super(message: 'Real-time connection lost. Reconnecting...');
}

// ── Game Logic Failures ────────────────────────────────────────

/// Failure when game rules are violated
class GameRuleViolationFailure extends Failure {
  const GameRuleViolationFailure({required super.message, super.code});
}

/// Failure when an invalid number of players is provided
class InvalidPlayerCountFailure extends Failure {
  const InvalidPlayerCountFailure({required super.message, super.code});
}

/// Failure when a player tries to perform an unauthorized action
class UnauthorizedActionFailure extends Failure {
  const UnauthorizedActionFailure({required super.message, super.code});
}

/// Failure when a room is not found
class RoomNotFoundFailure extends Failure {
  const RoomNotFoundFailure({super.code})
      : super(message: 'The specified room was not found.');
}

/// Failure when a room is already full
class RoomFullFailure extends Failure {
  const RoomFullFailure({super.code})
      : super(message: 'This room is already full.');
}

/// Failure when voting is not allowed in the current phase
class VotingNotAllowedFailure extends Failure {
  const VotingNotAllowedFailure({super.code})
      : super(message: 'Voting is not allowed at this time.');
}

// ── Data Failures ──────────────────────────────────────────────

/// Failure when local data cannot be read
class LocalDataFailure extends Failure {
  const LocalDataFailure({required super.message, super.code});
}

/// Failure when server returns an unexpected response
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Failure when data parsing/serialization fails
class DataParsingFailure extends Failure {
  const DataParsingFailure({required super.message, super.code});
}
