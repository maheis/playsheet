import 'package:flutter/material.dart';

class Player {
  const Player({required this.id, required this.name, required this.createdAt});
  final String id;
  final String name;
  final DateTime createdAt;
}

class GameBlockDefinition {
  const GameBlockDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
}

class GameRecord {
  const GameRecord({
    required this.id,
    required this.gameBlockId,
    required this.playerIds,
    required this.scores,
    required this.playedAt,
  });
  final String id;
  final String gameBlockId;
  final List<String> playerIds;
  final Map<String, int> scores;
  final DateTime playedAt;
}

const gameBlocks = <GameBlockDefinition>[
  GameBlockDefinition(
    id: 'damjagen',
    name: "Dam'jagen",
    description: 'Punkte und Runden schnell auf dem Spielblock erfassen.',
    icon: Icons.track_changes_rounded,
    color: Color(0xFF64B5F6),
  ),
  GameBlockDefinition(
    id: 'ten_thousand',
    name: '10 Tausend',
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
