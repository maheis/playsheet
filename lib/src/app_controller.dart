import 'package:flutter/foundation.dart';

import 'data/app_repository.dart';
import 'models.dart';

class AppController extends ChangeNotifier {
  AppController(this._repository);
  final AppRepository _repository;
  List<Player> players = const [];
  List<GameRecord> games = const [];
  bool isLoaded = false;

  Future<void> load() async {
    players = await _repository.loadPlayers();
    games = await _repository.loadGames();
    isLoaded = true;
    notifyListeners();
  }

  Future<void> addPlayer(String name) async {
    players = [
      ...players,
      Player(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name),
    ];
    await _repository.savePlayers(players);
    notifyListeners();
  }

  Future<void> addGame(GameRecord game) async {
    games = [...games, game];
    await _repository.saveGames(games);
    notifyListeners();
  }

  Player? playerById(String id) =>
      players.where((player) => player.id == id).firstOrNull;
}
