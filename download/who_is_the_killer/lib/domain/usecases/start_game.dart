import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/game_constants.dart';
import '../repositories/game_repository.dart';

/// ────────────────────────────────────────────────────────────────
/// StartGame — Use case for initiating the game
///
/// Validates that the room has the required number of players
/// before transitioning from lobby to the role reveal phase.
/// ────────────────────────────────────────────────────────────────
class StartGame {
  final GameRepository _repository;

  StartGame(this._repository);

  Future<Either<Failure, void>> call(String roomId) async {
    try {
      // Validate player count before starting
      final roomResult = await _repository.getRoom(roomId);
      return roomResult.fold(
        (failure) => Left(failure),
        (room) async {
          if (room.playerCount < GameConstants.minPlayers) {
            return Left(
              InvalidPlayerCountFailure(
                message: 'Need at least ${GameConstants.minPlayers} players. '
                    'Currently: ${room.playerCount}',
              ),
            );
          }
          return await _repository.startGame(roomId);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
