import 'package:flutter/material.dart';

class Player {
  const Player({
    required this.id,
    required this.name,
    required this.createdAt,
    this.primaryColorValue,
    this.secondaryColorValue,
  });
  final String id;
  final String name;
  final DateTime createdAt;
  final int? primaryColorValue;
  final int? secondaryColorValue;
}

class GameBlockDefinition {
  const GameBlockDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.iconLabel,
  });
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String? iconLabel;
}

class GameRecord {
  const GameRecord({
    required this.id,
    this.roundId,
    this.sessionId,
    required this.gameBlockId,
    required this.playerIds,
    required this.scores,
    required this.playedAt,
  });
  final String id;
  final String? roundId;
  final String? sessionId;
  final String gameBlockId;
  final List<String> playerIds;
  final Map<String, int> scores;
  final DateTime playedAt;
}

class GameRound {
  const GameRound({
    required this.id,
    required this.sessionId,
    required this.gameBlockId,
    required this.playerIds,
    required this.createdAt,
    this.dealerPlayerId,
    this.completed = false,
    this.winnerPlayerIds = const [],
  });

  final String id;
  final String sessionId;
  final String gameBlockId;
  final List<String> playerIds;
  final DateTime createdAt;
  final String? dealerPlayerId;
  final bool completed;
  final List<String> winnerPlayerIds;
}

class GameSession {
  const GameSession({
    required this.id,
    required this.gameBlockId,
    required this.name,
    required this.highWins,
    required this.playerIds,
    required this.createdAt,
  });

  final String id;
  final String gameBlockId;
  final String name;
  final bool highWins;
  final List<String> playerIds;
  final DateTime createdAt;
}

const gameBlocks = <GameBlockDefinition>[
  GameBlockDefinition(
    id: 'one_plus_two',
    name: '1 + 2 = 3',
    description: 'Spielrunden mit Hoch- oder Tiefwertung.',
    icon: Icons.looks_3_rounded,
    color: Color(0xFFE57373),
    iconLabel: '++',
  ),
  GameBlockDefinition(
    id: 'three_plus_minus_two',
    name: '3 +- 2 = 1',
    description: 'Spielrunden mit positiven und negativen Werten.',
    icon: Icons.exposure_plus_1_rounded,
    color: Color(0xFFBA68C8),
    iconLabel: '+-',
  ),
  GameBlockDefinition(
    id: 'damjagen',
    name: "Dam'jagen",
    description: 'Punkte und Runden schnell auf dem Spielblock erfassen.',
    icon: Icons.track_changes_rounded,
    color: Color(0xFF64B5F6),
  ),
  GameBlockDefinition(
    id: 'ten_thousand',
    name: '10Tausend',
    description: 'Würfelrunden mit Zielpunktzahl und persönlichem Verlauf.',
    icon: Icons.casino_rounded,
    color: Color(0xFFFFB74D),
  ),
  GameBlockDefinition(
    id: 'tally',
    name: 'Strichliste',
    description: 'Ein flexibler Zähler für Spiele, Aufgaben und Ereignisse.',
    icon: Icons.format_list_numbered_rounded,
    color: Color(0xFFAED581),
  ),
  GameBlockDefinition(
    id: 'kingdomino',
    name: 'Kingdomino',
    description: 'Ein vorbereiteter Platz für Königreiche und Punkte.',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF8FDCBE),
  ),
];

GameBlockDefinition gameBlockFor(String id) => gameBlocks.firstWhere(
      (block) => block.id == id,
      orElse: () => gameBlocks.first,
    );
