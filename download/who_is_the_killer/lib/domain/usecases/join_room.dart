import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../entities/game_room.dart';
import '../repositories/game_repository.dart';

/// ────────────────────────────────────────────────────────────────
/// JoinRoom — Use case for joining an existing game room
/// ────────────────────────────────────────────────────────────────
class JoinRoom {
  final GameRepository _repository;

  JoinRoom(this._repository);

  Future<Either<Failure, GameRoom>> call({
    required String code,
    required String playerId,
  }) async {
    try {
      return await _repository.joinRoom(code: code, playerId: playerId);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
