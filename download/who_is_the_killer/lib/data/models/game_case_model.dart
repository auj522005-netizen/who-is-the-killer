import '../../domain/entities/game_case.dart';

/// ────────────────────────────────────────────────────────────────
/// GameCaseModel — Data layer representation of a GameCase
/// ────────────────────────────────────────────────────────────────
class GameCaseModel extends GameCase {
  const GameCaseModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.description,
    super.clueIds,
    required super.verdictText,
    required super.supportedPlayerCount,
    required super.createdAt,
  });

  factory GameCaseModel.fromJson(Map<String, dynamic> json) {
    return GameCaseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      clueIds: (json['clue_ids'] as List<dynamic>).cast<String>(),
      verdictText: json['verdict_text'] as String,
      supportedPlayerCount: json['supported_player_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'clue_ids': clueIds,
      'verdict_text': verdictText,
      'supported_player_count': supportedPlayerCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
