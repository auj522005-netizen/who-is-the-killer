import '../../domain/entities/clue.dart';

/// ────────────────────────────────────────────────────────────────
/// ClueModel — Data layer representation of a Clue
/// ────────────────────────────────────────────────────────────────
class ClueModel extends Clue {
  const ClueModel({
    required super.id,
    required super.caseId,
    required super.roundNumber,
    required super.title,
    required super.description,
    super.isDecisive,
    required super.createdAt,
  });

  factory ClueModel.fromJson(Map<String, dynamic> json) {
    return ClueModel(
      id: json['id'] as String,
      caseId: json['case_id'] as String,
      roundNumber: json['round_number'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      isDecisive: json['is_decisive'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'case_id': caseId,
      'round_number': roundNumber,
      'title': title,
      'description': description,
      'is_decisive': isDecisive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ClueModel.fromEntity(Clue clue) {
    return ClueModel(
      id: clue.id,
      caseId: clue.caseId,
      roundNumber: clue.roundNumber,
      title: clue.title,
      description: clue.description,
      isDecisive: clue.isDecisive,
      createdAt: clue.createdAt,
    );
  }
}
