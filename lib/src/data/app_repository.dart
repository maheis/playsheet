import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sembast/sembast.dart';

import '../models.dart';

abstract interface class AppRepository {
  Future<List<Player>> loadPlayers();
  Future<List<GameRecord>> loadGames();
  Future<List<GameSession>> loadGameSessions();
  Future<void> savePlayers(List<Player> players);
  Future<void> saveGames(List<GameRecord> games);
  Future<void> saveGameSessions(List<GameSession> sessions);
}

class LocalAppRepository implements AppRepository {
  LocalAppRepository(this._database, {SharedPreferences? legacyPreferences})
      : _legacyPreferences = legacyPreferences;
  final Database _database;
  final SharedPreferences? _legacyPreferences;
  final _playersStore = stringMapStoreFactory.store('players');
  final _gamesStore = stringMapStoreFactory.store('games');
  final _gameSessionsStore = stringMapStoreFactory.store('game_sessions');

  Map<String, dynamic> _playerData(Player player) => {
        'id': player.id,
        'name': player.name,
        'createdAt': player.createdAt.toIso8601String(),
        'primaryColorValue': player.primaryColorValue,
        'secondaryColorValue': player.secondaryColorValue,
      };

  Player _playerFromData(Map<String, dynamic> data, [int legacyIndex = 0]) =>
      Player(
        id: data['id'] as String,
        name: data['name'] as String,
        createdAt: data['createdAt'] == null
            ? DateTime.fromMillisecondsSinceEpoch(legacyIndex)
            : DateTime.parse(data['createdAt'] as String),
        primaryColorValue: (data['primaryColorValue'] as num?)?.toInt(),
        secondaryColorValue: (data['secondaryColorValue'] as num?)?.toInt(),
      );

  Map<String, dynamic> _gameData(GameRecord game) => {
        'id': game.id,
        'sessionId': game.sessionId,
        'gameBlockId': game.gameBlockId,
        'playerIds': game.playerIds,
        'scores': game.scores,
        'playedAt': game.playedAt.toIso8601String(),
      };

  GameRecord _gameFromData(Map<String, dynamic> data) => GameRecord(
        id: data['id'] as String,
        sessionId: data['sessionId'] as String?,
        gameBlockId: data['gameBlockId'] as String,
        playerIds: List<String>.from(data['playerIds'] as List<dynamic>),
        scores: Map<String, int>.from(
          (data['scores'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, value as int),
          ),
        ),
        playedAt: DateTime.parse(data['playedAt'] as String),
      );

  Map<String, dynamic> _gameSessionData(GameSession session) => {
        'id': session.id,
        'gameBlockId': session.gameBlockId,
        'name': session.name,
        'highWins': session.highWins,
        'playerIds': session.playerIds,
        'createdAt': session.createdAt.toIso8601String(),
      };

  GameSession _gameSessionFromData(Map<String, dynamic> data) => GameSession(
        id: data['id'] as String,
        gameBlockId: data['gameBlockId'] as String,
        name: data['name'] as String,
        highWins: data['highWins'] as bool,
        playerIds: List<String>.from(data['playerIds'] as List<dynamic>),
        createdAt: DateTime.parse(data['createdAt'] as String),
      );

  @override
  Future<List<Player>> loadPlayers() async {
    var players = (await _playersStore.find(_database))
        .map((record) => _playerFromData(record.value))
        .toList();
    final legacyValues = _legacyPreferences?.getStringList('players');
    if (players.isEmpty && legacyValues != null && legacyValues.isNotEmpty) {
      players = legacyValues.indexed.map((entry) {
        final data = jsonDecode(entry.$2) as Map<String, dynamic>;
        return _playerFromData(data, entry.$1);
      }).toList();
      await savePlayers(players);
    }
    return players;
  }

  @override
  Future<List<GameRecord>> loadGames() async {
    var games = (await _gamesStore.find(_database))
        .map((record) => _gameFromData(record.value))
        .toList();
    final legacyValues = _legacyPreferences?.getStringList('games');
    if (games.isEmpty && legacyValues != null && legacyValues.isNotEmpty) {
      games = legacyValues
          .map((value) =>
              _gameFromData(jsonDecode(value) as Map<String, dynamic>))
          .toList();
      await saveGames(games);
    }
    return games;
  }

  @override
  Future<void> savePlayers(List<Player> players) async {
    await _database.transaction((transaction) async {
      await _playersStore.delete(transaction);
      for (final player in players) {
        await _playersStore
            .record(player.id)
            .put(transaction, _playerData(player));
      }
    });
  }

  @override
  Future<void> saveGames(List<GameRecord> games) async {
    await _database.transaction((transaction) async {
      await _gamesStore.delete(transaction);
      for (final game in games) {
        await _gamesStore.record(game.id).put(transaction, _gameData(game));
      }
    });
  }

  @override
  Future<List<GameSession>> loadGameSessions() async =>
      (await _gameSessionsStore.find(_database))
          .map((record) => _gameSessionFromData(record.value))
          .toList();

  @override
  Future<void> saveGameSessions(List<GameSession> sessions) async {
    await _database.transaction((transaction) async {
      await _gameSessionsStore.delete(transaction);
      for (final session in sessions) {
        await _gameSessionsStore
            .record(session.id)
            .put(transaction, _gameSessionData(session));
      }
    });
  }
}
