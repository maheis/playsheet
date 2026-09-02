import 'package:flutter/foundation.dart';

import 'data/app_repository.dart';
import 'models.dart';

class AppController extends ChangeNotifier {
  AppController(this._repository);
  final AppRepository _repository;
  List<Player> players = const [];
  List<GameRecord> games = const [];
  List<GameSession> gameSessions = const [];
  bool isLoaded = false;

  Future<void> load() async {
    players = await _repository.loadPlayers();
    games = await _repository.loadGames();
    gameSessions = await _repository.loadGameSessions();
    final usedIds = <String>{};
    final idMapping = <String, String>{};
    var nextId = 1;
    players = [
      for (final player in players)
        () {
          final oldId = player.id;
          var newId = int.tryParse(oldId);
          if (newId == null || newId < 1 || usedIds.contains(oldId)) {
            while (usedIds.contains('$nextId')) {
              nextId++;
            }
            newId = nextId++;
          }
          final normalizedId = '$newId';
          usedIds.add(normalizedId);
          idMapping.putIfAbsent(oldId, () => normalizedId);
          return Player(
            id: normalizedId,
            name: player.name,
            createdAt: player.createdAt,
            primaryColorValue: player.primaryColorValue,
            secondaryColorValue: player.secondaryColorValue,
          );
        }(),
    ];
    if (idMapping.entries.any((entry) => entry.key != entry.value)) {
      games = games
          .map(
            (game) => GameRecord(
              id: game.id,
              sessionId: game.sessionId,
              gameBlockId: game.gameBlockId,
              playerIds:
                  game.playerIds.map((id) => idMapping[id] ?? id).toList(),
              scores: {
                for (final entry in game.scores.entries)
                  idMapping[entry.key] ?? entry.key: entry.value,
              },
              playedAt: game.playedAt,
            ),
          )
          .toList();
      await _repository.savePlayers(players);
      await _repository.saveGames(games);
    }
    isLoaded = true;
    notifyListeners();
  }

  Future<Player> addPlayer(String name) async {
    final nextId = players.fold<int>(0, (highest, player) {
          final id = int.tryParse(player.id) ?? 0;
          return id > highest ? id : highest;
        }) +
        1;
    final player = Player(id: '$nextId', name: name, createdAt: DateTime.now());
    players = [...players, player];
    await _repository.savePlayers(players);
    notifyListeners();
    return player;
  }

  Future<void> updatePlayer(
    String id, {
    String? name,
    int? primaryColorValue,
    int? secondaryColorValue,
  }) async {
    players = [
      for (final player in players)
        if (player.id == id)
          Player(
            id: id,
            name: name ?? player.name,
            createdAt: player.createdAt,
            primaryColorValue: primaryColorValue ?? player.primaryColorValue,
            secondaryColorValue:
                secondaryColorValue ?? player.secondaryColorValue,
          )
        else
          player,
    ];
    await _repository.savePlayers(players);
    notifyListeners();
  }

  Future<void> deletePlayer(String id) async {
    players = players.where((player) => player.id != id).toList();
    await _repository.savePlayers(players);
    notifyListeners();
  }

  Future<void> addGame(GameRecord game) async {
    games = [...games, game];
    await _repository.saveGames(games);
    notifyListeners();
  }

  Future<void> deleteGameSession(String id) async {
    gameSessions = gameSessions.where((session) => session.id != id).toList();
    games = games.where((game) => game.sessionId != id).toList();
    await _repository.saveGameSessions(gameSessions);
    await _repository.saveGames(games);
    notifyListeners();
  }

  Future<void> deleteGameRound(String id) async {
    games = games.where((game) => game.id != id).toList();
    await _repository.saveGames(games);
    notifyListeners();
  }

  Future<GameSession> addGameSession({
    required String gameBlockId,
    required String name,
    required bool highWins,
    required List<String> playerIds,
  }) async {
    final session = GameSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      gameBlockId: gameBlockId,
      name: name,
      highWins: highWins,
      playerIds: playerIds,
      createdAt: DateTime.now(),
    );
    gameSessions = [...gameSessions, session];
    await _repository.saveGameSessions(gameSessions);
    notifyListeners();
    return session;
  }

  Future<void> updateGameSession(GameSession session) async {
    gameSessions = [
      for (final current in gameSessions)
        if (current.id == session.id) session else current,
    ];
    await _repository.saveGameSessions(gameSessions);
    notifyListeners();
  }

  Player? playerById(String id) =>
      players.where((player) => player.id == id).firstOrNull;
}
