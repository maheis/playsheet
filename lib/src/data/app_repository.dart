import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

abstract interface class AppRepository {
  Future<List<Player>> loadPlayers();
  Future<List<GameRecord>> loadGames();
  Future<void> savePlayers(List<Player> players);
  Future<void> saveGames(List<GameRecord> games);
}

class LocalAppRepository implements AppRepository {
  LocalAppRepository(this._preferences);
  final SharedPreferences _preferences;

  @override
  Future<List<Player>> loadPlayers() async =>
      (_preferences.getStringList('players') ?? const []).indexed.map((entry) {
        final data = jsonDecode(entry.$2) as Map<String, dynamic>;
        return Player(
          id: data['id'] as String,
          name: data['name'] as String,
          createdAt: data['createdAt'] == null
              ? DateTime.fromMillisecondsSinceEpoch(entry.$1)
              : DateTime.parse(data['createdAt'] as String),
          primaryColorValue: (data['primaryColorValue'] as num?)?.toInt(),
          secondaryColorValue: (data['secondaryColorValue'] as num?)?.toInt(),
        );
      }).toList();

  @override
  Future<List<GameRecord>> loadGames() async =>
      (_preferences.getStringList('games') ?? const []).map((value) {
        final data = jsonDecode(value) as Map<String, dynamic>;
        return GameRecord(
          id: data['id'] as String,
          gameBlockId: data['gameBlockId'] as String,
          playerIds: List<String>.from(data['playerIds'] as List<dynamic>),
          scores: Map<String, int>.from(
            (data['scores'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, value as int),
            ),
          ),
          playedAt: DateTime.parse(data['playedAt'] as String),
        );
      }).toList();

  @override
  Future<void> savePlayers(List<Player> players) => _preferences.setStringList(
    'players',
    players
        .map(
          (player) => jsonEncode({
            'id': player.id,
            'name': player.name,
            'createdAt': player.createdAt.toIso8601String(),
            'primaryColorValue': player.primaryColorValue,
            'secondaryColorValue': player.secondaryColorValue,
          }),
        )
        .toList(),
  );

  @override
  Future<void> saveGames(List<GameRecord> games) => _preferences.setStringList(
    'games',
    games
        .map(
          (game) => jsonEncode({
            'id': game.id,
            'gameBlockId': game.gameBlockId,
            'playerIds': game.playerIds,
            'scores': game.scores,
            'playedAt': game.playedAt.toIso8601String(),
          }),
        )
        .toList(),
  );
}
