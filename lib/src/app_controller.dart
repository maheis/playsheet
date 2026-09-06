import 'package:flutter/foundation.dart';

import 'data/app_repository.dart';
import 'models.dart';

class AppController extends ChangeNotifier {
  AppController(this._repository);
  final AppRepository _repository;
  List<Player> players = const [];
  List<GameRecord> games = const [];
  List<GameRound> gameRounds = const [];
  List<GameSession> gameSessions = const [];
  bool isLoaded = false;

  Future<void> load() async {
    players = await _repository.loadPlayers();
    games = await _repository.loadGames();
    gameRounds = await _repository.loadGameRounds();
    gameSessions = await _repository.loadGameSessions();
    final normalizedSessions = gameSessions
        .map(
          (session) => session.gameBlockId == 'ten_thousand'
              ? GameSession(
                  id: session.id,
                  gameBlockId: session.gameBlockId,
                  name: session.name,
                  highWins: true,
                  playerIds: session.playerIds,
                  createdAt: session.createdAt,
                  maxPoints: session.maxPoints,
                )
              : session,
        )
        .toList();
    if (normalizedSessions.any((session) {
      final current = gameSessions.firstWhere((item) => item.id == session.id);
      return current.highWins != session.highWins;
    })) {
      gameSessions = normalizedSessions;
      await _repository.saveGameSessions(gameSessions);
    } else {
      gameSessions = normalizedSessions;
    }
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
              roundId: game.roundId,
              sessionId: game.sessionId,
              gameBlockId: game.gameBlockId,
              playerIds:
                  game.playerIds.map((id) => idMapping[id] ?? id).toList(),
              scores: {
                for (final entry in game.scores.entries)
                  idMapping[entry.key] ?? entry.key: entry.value,
              },
              playedAt: game.playedAt,
              categoryId: game.categoryId,
              crossedOut: game.crossedOut,
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

  Future<void> updateGame(GameRecord game) async {
    games = [
      for (final current in games)
        if (current.id == game.id) game else current,
    ];
    await _repository.saveGames(games);
    notifyListeners();
  }

  Future<void> deleteGameSession(String id) async {
    gameSessions = gameSessions.where((session) => session.id != id).toList();
    gameRounds = gameRounds.where((round) => round.sessionId != id).toList();
    games = games.where((game) => game.sessionId != id).toList();
    await _repository.saveGameSessions(gameSessions);
    await _repository.saveGameRounds(gameRounds);
    await _repository.saveGames(games);
    notifyListeners();
  }

  Future<void> deleteGameRound(String id) async {
    final deletedRound = gameRounds.firstWhere((round) => round.id == id);
    final lastCompletedRound = !deletedRound.completed
        ? gameRounds
            .where(
            (round) =>
                round.sessionId == deletedRound.sessionId &&
                round.completed &&
                round.id != id,
          )
            .fold<GameRound?>(null, (latest, round) {
            if (latest == null || round.createdAt.isAfter(latest.createdAt)) {
              return round;
            }
            return latest;
          })
        : null;
    gameRounds = gameRounds
        .where((round) => round.id != id)
        .map(
          (round) => round.id == lastCompletedRound?.id
              ? GameRound(
                  id: round.id,
                  sessionId: round.sessionId,
                  gameBlockId: round.gameBlockId,
                  playerIds: round.playerIds,
                  createdAt: round.createdAt,
                  maxPoints: round.maxPoints,
                  dealerPlayerId: round.dealerPlayerId,
                  dealerAdvancesOnScore: round.dealerAdvancesOnScore,
                  completed: false,
                )
              : round,
        )
        .toList();
    games = games.where((game) => game.roundId != id).toList();
    await _repository.saveGameRounds(gameRounds);
    await _repository.saveGames(games);
    notifyListeners();
  }

  Future<void> deleteGame(String id) async {
    games = games.where((game) => game.id != id).toList();
    await _repository.saveGames(games);
    notifyListeners();
  }

  Future<void> updateGameRoundDealer(String id, String dealerPlayerId) async {
    gameRounds = [
      for (final round in gameRounds)
        if (round.id == id)
          GameRound(
            id: round.id,
            sessionId: round.sessionId,
            gameBlockId: round.gameBlockId,
            playerIds: round.playerIds,
            createdAt: round.createdAt,
            maxPoints: round.maxPoints,
            dealerPlayerId: dealerPlayerId,
            dealerAdvancesOnScore: round.dealerAdvancesOnScore,
            completed: round.completed,
            winnerPlayerIds: round.winnerPlayerIds,
          )
        else
          round,
    ];
    await _repository.saveGameRounds(gameRounds);
    notifyListeners();
  }

  Future<void> updateGameRoundDealerAdvance(String id, bool enabled) async {
    gameRounds = [
      for (final round in gameRounds)
        if (round.id == id)
          GameRound(
            id: round.id,
            sessionId: round.sessionId,
            gameBlockId: round.gameBlockId,
            playerIds: round.playerIds,
            createdAt: round.createdAt,
            maxPoints: round.maxPoints,
            dealerPlayerId: round.dealerPlayerId,
            dealerAdvancesOnScore: enabled,
            completed: round.completed,
            winnerPlayerIds: round.winnerPlayerIds,
          )
        else
          round,
    ];
    await _repository.saveGameRounds(gameRounds);
    notifyListeners();
  }

  Future<void> updateGameRoundPlayerOrder(
    String id,
    List<String> playerIds,
  ) async {
    gameRounds = [
      for (final round in gameRounds)
        if (round.id == id)
          GameRound(
            id: round.id,
            sessionId: round.sessionId,
            gameBlockId: round.gameBlockId,
            playerIds: [...playerIds],
            createdAt: round.createdAt,
            maxPoints: round.maxPoints,
            dealerPlayerId: round.dealerPlayerId,
            completed: round.completed,
            winnerPlayerIds: round.winnerPlayerIds,
          )
        else
          round,
    ];
    await _repository.saveGameRounds(gameRounds);
    notifyListeners();
  }

  Future<void> updateGameRoundMaxPoints(String id, int maxPoints) async {
    gameRounds = [
      for (final round in gameRounds)
        if (round.id == id)
          GameRound(
            id: round.id,
            sessionId: round.sessionId,
            gameBlockId: round.gameBlockId,
            playerIds: round.playerIds,
            createdAt: round.createdAt,
            maxPoints: maxPoints,
            dealerPlayerId: round.dealerPlayerId,
            dealerAdvancesOnScore: round.dealerAdvancesOnScore,
            completed: round.completed,
            winnerPlayerIds: round.winnerPlayerIds,
          )
        else
          round,
    ];
    await _repository.saveGameRounds(gameRounds);
    notifyListeners();
  }

  Future<GameRound> addGameRound({
    required String sessionId,
    required String gameBlockId,
    required List<String> playerIds,
  }) async {
    final session = gameSessions.firstWhere((item) => item.id == sessionId);
    final completedRounds = gameRounds.map((round) {
      if (round.sessionId != sessionId || round.completed) return round;
      final totals = {
        for (final playerId in round.playerIds)
          playerId: games
              .where((game) => game.roundId == round.id)
              .fold<int>(0, (sum, game) => sum + (game.scores[playerId] ?? 0)),
      };
      final winnerPlayerIds = totals.isEmpty
          ? const <String>[]
          : () {
              final winnerValue = session.highWins
                  ? totals.values.reduce(
                      (first, second) => first > second ? first : second)
                  : totals.values.reduce(
                      (first, second) => first < second ? first : second);
              return totals.entries
                  .where((entry) => entry.value == winnerValue)
                  .map((entry) => entry.key)
                  .toList();
            }();
      return GameRound(
        id: round.id,
        sessionId: round.sessionId,
        gameBlockId: round.gameBlockId,
        playerIds: round.playerIds,
        createdAt: round.createdAt,
        maxPoints: round.maxPoints,
        dealerPlayerId: round.dealerPlayerId,
        dealerAdvancesOnScore: round.dealerAdvancesOnScore,
        completed: true,
        winnerPlayerIds: winnerPlayerIds,
      );
    }).toList();
    final round = GameRound(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sessionId: sessionId,
      gameBlockId: gameBlockId,
      playerIds: playerIds,
      createdAt: DateTime.now(),
      maxPoints: 16,
    );
    gameRounds = [...completedRounds, round];
    await _repository.saveGameRounds(gameRounds);
    notifyListeners();
    return round;
  }

  Future<GameSession> addGameSession({
    required String gameBlockId,
    required String name,
    required bool highWins,
    required List<String> playerIds,
    int maxPoints = 16,
  }) async {
    final session = GameSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      gameBlockId: gameBlockId,
      name: name,
      highWins: gameBlockId == 'ten_thousand' || gameBlockId == 'dice_block'
          ? true
          : gameBlockId == 'damjagen'
              ? false
              : highWins,
      playerIds: playerIds,
      createdAt: DateTime.now(),
      maxPoints: maxPoints,
    );
    gameSessions = [...gameSessions, session];
    await _repository.saveGameSessions(gameSessions);
    notifyListeners();
    return session;
  }

  Future<void> updateGameSession(GameSession session) async {
    final normalizedSession = session.gameBlockId == 'ten_thousand' ||
            session.gameBlockId == 'damjagen' ||
            session.gameBlockId == 'dice_block'
        ? GameSession(
            id: session.id,
            gameBlockId: session.gameBlockId,
            name: session.name,
            highWins: session.gameBlockId == 'ten_thousand' ||
                    session.gameBlockId == 'dice_block'
                ? true
                : false,
            playerIds: session.playerIds,
            createdAt: session.createdAt,
            maxPoints: session.maxPoints,
          )
        : session;
    gameSessions = [
      for (final current in gameSessions)
        if (current.id == normalizedSession.id) normalizedSession else current,
    ];
    await _repository.saveGameSessions(gameSessions);
    notifyListeners();
  }

  Player? playerById(String id) =>
      players.where((player) => player.id == id).firstOrNull;
}
