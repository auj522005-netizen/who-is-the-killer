import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../entities/clue.dart';
import '../repositories/game_repository.dart';

/// ────────────────────────────────────────────────────────────────
/// GetClue — Use case for retrieving a clue for a specific round
///
/// Enforces the rule that EXACTLY ONE clue is retrieved per round.
/// ────────────────────────────────────────────────────────────────
class GetClue {
  final GameRepository _repository;

  GetClue(this._repository);

  Future<Either<Failure, Clue>> call({
    required String caseId,
    required int roundNumber,
  }) async {
    try {
      return await _repository.getClueForRound(
        caseId: caseId,
        roundNumber: roundNumber,
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
