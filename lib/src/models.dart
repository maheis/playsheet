import 'package:flutter/material.dart';

const tallyIconLabel = '||||/';

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
    this.categoryId,
    this.crossedOut = false,
  });
  final String id;
  final String? roundId;
  final String? sessionId;
  final String gameBlockId;
  final List<String> playerIds;
  final Map<String, int> scores;
  final DateTime playedAt;
  final String? categoryId;
  final bool crossedOut;
}

class GameRound {
  const GameRound({
    required this.id,
    required this.sessionId,
    required this.gameBlockId,
    required this.playerIds,
    required this.createdAt,
    this.maxPoints = 16,
    this.dealerPlayerId,
    this.completed = false,
    this.winnerPlayerIds = const [],
  });

  final String id;
  final String sessionId;
  final String gameBlockId;
  final List<String> playerIds;
  final DateTime createdAt;
  final int maxPoints;
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
    this.maxPoints = 16,
  });

  final String id;
  final String gameBlockId;
  final String name;
  final bool highWins;
  final List<String> playerIds;
  final DateTime createdAt;
  final int maxPoints;
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
    icon: Icons.style_rounded,
    color: Color(0xFF64B5F6),
    iconLabel: '♠',
  ),
  GameBlockDefinition(
    id: 'ten_thousand',
    name: '10Tausend',
    description: 'Würfelrunden mit Zielpunktzahl und persönlichem Verlauf.',
    icon: Icons.casino_rounded,
    color: Color(0xFFFFB74D),
    iconLabel: '⚄⚀',
  ),
  GameBlockDefinition(
    id: 'tally',
    name: 'Strichliste',
    description: 'Ein flexibler Zähler für Spiele, Aufgaben und Ereignisse.',
    icon: Icons.format_list_numbered_rounded,
    color: Color(0xFFAED581),
    iconLabel: tallyIconLabel,
  ),
  GameBlockDefinition(
    id: 'dice_block',
    name: 'Würfelblock',
    description: 'Würfelblock mit Würfelkategorien und 5er Pasch.',
    icon: Icons.casino_rounded,
    color: Color(0xFF81C784),
  ),
  GameBlockDefinition(
    id: 'kingdomino',
    name: 'Kingdomino',
    description: 'Ein vorbereiteter Platz für Königreiche und Punkte.',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF8FDCBE),
  ),
];

const diceBlockCategories = <String>[
  'Einser',
  'Zweier',
  'Dreier',
  'Vierer',
  'Fünfer',
  'Sechser',
  'Dreierpasch',
  'Viererpasch',
  'Full House',
  'Kleine Straße',
  'Große Straße',
  '5er Pasch',
  'Chance',
];

const diceBlockCategoryIcons = <String, IconData>{
  'Einser': Icons.looks_one_rounded,
  'Zweier': Icons.looks_two_rounded,
  'Dreier': Icons.looks_3_rounded,
  'Vierer': Icons.looks_4_rounded,
  'Fünfer': Icons.looks_5_rounded,
  'Sechser': Icons.looks_6_rounded,
  'Dreierpasch': Icons.filter_3_rounded,
  'Viererpasch': Icons.filter_4_rounded,
  'Full House': Icons.home_rounded,
  'Kleine Straße': Icons.stairs_rounded,
  'Große Straße': Icons.stairs_rounded,
  '5er Pasch': Icons.casino_rounded,
  'Chance': Icons.shuffle_rounded,
};

GameBlockDefinition gameBlockFor(String id) => gameBlocks.firstWhere(
      (block) => block.id == id,
      orElse: () => gameBlocks.first,
    );
