import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../entities/vote.dart';
import '../repositories/game_repository.dart';

/// ────────────────────────────────────────────────────────────────
/// CastVote — Use case for casting an elimination vote
///
/// Validates that voting is allowed in the current game phase
/// before persisting the vote.
/// ────────────────────────────────────────────────────────────────
class CastVote {
  final GameRepository _repository;

  CastVote(this._repository);

  Future<Either<Failure, Vote>> call({
    required String voterId,
    required String targetId,
    required int roundNumber,
    bool isGhostVote = false,
  }) async {
    try {
      return await _repository.castVote(
        voterId: voterId,
        targetId: targetId,
        roundNumber: roundNumber,
        isGhostVote: isGhostVote,
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
