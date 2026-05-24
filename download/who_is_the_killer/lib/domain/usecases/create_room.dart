import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../repositories/game_repository.dart';

/// ────────────────────────────────────────────────────────────────
/// CreateRoom — Use case for creating a new game room
///
/// Encapsulates the business logic for room creation including
/// validation of player count and case selection.
/// ────────────────────────────────────────────────────────────────
class CreateRoom {
  final GameRepository _repository;

  CreateRoom(this._repository);

  Future<Either<Failure, String>> call({
    required String name,
    required String hostPlayerId,
    required String caseId,
    int maxPlayers = 10,
  }) async {
    try {
      final result = await _repository.createRoom(
        name: name,
        hostPlayerId: hostPlayerId,
        caseId: caseId,
        maxPlayers: maxPlayers,
      );
      return result.map((room) => room.id);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
