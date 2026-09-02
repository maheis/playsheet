import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'models.dart';
import 'settings.dart';
import 'app.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.controller,
    required this.settingsController,
  });
  final AppController controller;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            toolbarHeight: 95,
            leadingWidth: 100,
            leading: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                top: 16,
                right: 4,
                bottom: 4,
              ),
              child: Image.asset(
                'assets/icons/color_transparent_icon.png',
                width: 75,
                height: 75,
              ),
            ),
            title: const Text('PlaySheet'),
            actions: [
              IconButton(
                tooltip: 'Einstellungen',
                icon: const Icon(Icons.settings_rounded),
                onPressed: () => pushPage(
                    context, SettingsPage(controller: settingsController)),
              ),
            ],
          ),
          body: ListView(
            children: [
              LayoutBuilder(
                builder: (context, _) => _TileGrid(
                  children: [
                    _ActionTile(
                      icon: Icons.people_alt_rounded,
                      title: 'Spieler',
                      detail: '${controller.players.length} angelegt',
                      onTap: () => pushPage(
                          context, PlayersPage(controller: controller)),
                    ),
                    _ActionTile(
                      icon: Icons.looks_3_rounded,
                      iconLabel: gameBlockFor('one_plus_two').iconLabel,
                      title: '1 + 2 = 3',
                      detail:
                          '${_gameCount(controller, 'one_plus_two')} Spiele',
                      onTap: () => pushPage(
                        context,
                        GameSessionsPage(
                          controller: controller,
                          block: gameBlockFor('one_plus_two'),
                        ),
                      ),
                    ),
                    _ActionTile(
                      icon: Icons.exposure_plus_1_rounded,
                      iconLabel: gameBlockFor('three_plus_minus_two').iconLabel,
                      title: '3 +- 2 = 1',
                      detail:
                          '${_gameCount(controller, 'three_plus_minus_two')} '
                          'Spiele',
                      onTap: () => pushPage(
                        context,
                        GameSessionsPage(
                          controller: controller,
                          block: gameBlockFor('three_plus_minus_two'),
                        ),
                      ),
                    ),
                    _ActionTile(
                      icon: Icons.casino_rounded,
                      title: '10Tausend',
                      detail:
                          '${_gameCount(controller, 'ten_thousand')} Spiele',
                      onTap: () => pushPage(
                        context,
                        GameSessionsPage(
                          controller: controller,
                          block: gameBlockFor('ten_thousand'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  int _gameCount(AppController controller, String blockId) =>
      controller.gameSessions
          .where((session) => session.gameBlockId == blockId)
          .length;
}

class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          children[index],
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    this.iconLabel,
    required this.title,
    required this.detail,
    required this.onTap,
  });
  final IconData icon;
  final String? iconLabel;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                iconLabel == null
                    ? Icon(
                        icon,
                        size: 32,
                        color: Theme.of(context).colorScheme.secondary,
                      )
                    : Text(
                        iconLabel!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(detail,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      );
}

class GameSessionsPage extends StatefulWidget {
  const GameSessionsPage({
    super.key,
    required this.controller,
    required this.block,
  });
  final AppController controller;
  final GameBlockDefinition block;

  @override
  State<GameSessionsPage> createState() => _GameSessionsPageState();
}

class _GameSessionsPageState extends State<GameSessionsPage> {
  Future<void> _createGame() async {
    await pushPage(
      context,
      GameSessionConfigPage(
        controller: widget.controller,
        block: widget.block,
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openGame(GameSession session) async {
    await pushPage(
      context,
      GameRoundsPage(controller: widget.controller, session: session),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sessions = widget.controller.gameSessions
        .where((session) => session.gameBlockId == widget.block.id)
        .toList()
      ..sort((first, second) {
        final lastPlayedComparison =
            _lastPlayedAt(second).compareTo(_lastPlayedAt(first));
        return lastPlayedComparison != 0
            ? lastPlayedComparison
            : second.createdAt.compareTo(first.createdAt);
      });
    return Scaffold(
      appBar: AppBar(title: Text(widget.block.name)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _ActionTile(
            icon: Icons.add_rounded,
            title: 'Spiel anlegen',
            detail: 'Name, Gewinnart und Spieler festlegen',
            onTap: _createGame,
          ),
          const SizedBox(height: 12),
          ...sessions.map(
            (session) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: widget.block.iconLabel == null
                      ? Icon(
                          widget.block.icon,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : Text(
                          widget.block.iconLabel!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                title: Text(session.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _playerNames(session),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${session.highWins ? 'Hoch' : 'Tief'} • '
                      '${_roundCount(session)} Runden',
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Spiel löschen',
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => _confirmDeleteGame(context, session),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
                onTap: () => _openGame(session),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _lastPlayedAt(GameSession session) {
    final playedAt = widget.controller.games
        .where((game) => game.sessionId == session.id)
        .map((game) => game.playedAt)
        .toList();
    if (playedAt.isEmpty) return session.createdAt;
    return playedAt.reduce(
      (first, second) => first.isAfter(second) ? first : second,
    );
  }

  int _roundCount(GameSession session) => widget.controller.games
      .where((game) => game.sessionId == session.id)
      .length;

  String _playerNames(GameSession session) => session.playerIds
      .map((id) => widget.controller.playerById(id)?.name ?? 'Unbekannt')
      .join(', ');

  Future<void> _confirmDeleteGame(
    BuildContext context,
    GameSession session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Spiel löschen?'),
        content: Text(
          '„${session.name}“ und alle zugehörigen Runden wirklich löschen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.controller.deleteGameSession(session.id);
      if (mounted) setState(() {});
    }
  }
}

class GameSessionConfigPage extends StatefulWidget {
  const GameSessionConfigPage({
    super.key,
    required this.controller,
    required this.block,
  });
  final AppController controller;
  final GameBlockDefinition block;

  @override
  State<GameSessionConfigPage> createState() => _GameSessionConfigPageState();
}

class _GameSessionConfigPageState extends State<GameSessionConfigPage> {
  late final TextEditingController name;
  TextEditingController? playerNameFieldController;
  String typedPlayerName = '';
  bool highWins = true;
  final selectedPlayerIds = <String>{};
  GameSession? session;

  @override
  void initState() {
    super.initState();
    name = TextEditingController();
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('${widget.block.name} konfigurieren'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: name,
              autofocus: true,
              onChanged: (_) => _persistConfiguration(),
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'z. B. Spieleabend',
                border: OutlineInputBorder(),
              ),
            ),
            if (widget.block.id != 'ten_thousand') ...[
              const SizedBox(height: 20),
              Text('Gewinnart', style: Theme.of(context).textTheme.titleMedium),
              RadioListTile<bool>(
                value: true,
                groupValue: highWins,
                title: const Text('Hoch gewinnt'),
                onChanged: (value) {
                  setState(() => highWins = value ?? true);
                  _persistConfiguration();
                },
              ),
              RadioListTile<bool>(
                value: false,
                groupValue: highWins,
                title: const Text('Tief gewinnt'),
                onChanged: (value) {
                  setState(() => highWins = value ?? true);
                  _persistConfiguration();
                },
              ),
            ],
            const SizedBox(height: 12),
            Text('Spieler', style: Theme.of(context).textTheme.titleMedium),
            Autocomplete<Player>(
              displayStringForOption: (player) => player.name,
              optionsBuilder: (value) {
                final query = value.text.trim().toLowerCase();
                if (query.isEmpty) return const Iterable<Player>.empty();
                return widget.controller.players.where(
                  (player) =>
                      !selectedPlayerIds.contains(player.id) &&
                      player.name.toLowerCase().contains(query),
                );
              },
              optionsViewBuilder: (context, onSelected, options) => Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final player = options.elementAt(index);
                        return ListTile(
                          leading: const Icon(Icons.person_rounded),
                          title: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: player.name),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: Transform.translate(
                                    offset: const Offset(0, 3),
                                    child: Text(
                                      ' ${player.id}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () => onSelected(player),
                        );
                      },
                    ),
                  ),
                ),
              ),
              onSelected: (player) {
                _addPlayer(player);
                playerNameFieldController?.clear();
                typedPlayerName = '';
              },
              fieldViewBuilder:
                  (context, fieldController, focusNode, onSubmitted) {
                playerNameFieldController = fieldController;
                return TextField(
                  controller: fieldController,
                  focusNode: focusNode,
                  onChanged: (value) => typedPlayerName = value,
                  onSubmitted: (_) => _addTypedPlayer(fieldController),
                  decoration: const InputDecoration(
                    labelText: 'Spieler hinzufügen',
                    hintText:
                        'Vorhandenen Spieler suchen oder neuen Namen eingeben',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_search_rounded),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final id in selectedPlayerIds)
                  if (widget.controller.playerById(id) case final player?)
                    InputChip(
                      avatar: const Icon(Icons.person_rounded, size: 18),
                      label: Text(player.name),
                      onDeleted: () {
                        setState(() => selectedPlayerIds.remove(id));
                        _persistConfiguration();
                      },
                    ),
              ],
            ),
            if (selectedPlayerIds.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Noch keine Spieler hinzugefügt.'),
              ),
          ],
        ),
      );

  void _addPlayer(Player player) {
    if (selectedPlayerIds.add(player.id)) {
      setState(() {});
      _persistConfiguration();
    }
  }

  Future<void> _addTypedPlayer(TextEditingController fieldController) async {
    final playerName = fieldController.text.trim();
    if (playerName.isEmpty) return;
    final existing = widget.controller.players.where(
      (player) => player.name.toLowerCase() == playerName.toLowerCase(),
    );
    final player = existing.isNotEmpty
        ? existing.first
        : await widget.controller.addPlayer(playerName);
    if (!mounted) return;
    _addPlayer(player);
    fieldController.clear();
    typedPlayerName = '';
  }

  Future<void> _persistConfiguration() async {
    if (typedPlayerName.trim().isNotEmpty) {
      final playerName = typedPlayerName.trim();
      final existing = widget.controller.players.where(
        (player) => player.name.toLowerCase() == playerName.toLowerCase(),
      );
      final player = existing.isNotEmpty
          ? existing.first
          : await widget.controller.addPlayer(playerName);
      _addPlayer(player);
      typedPlayerName = '';
    }
    final gameName = name.text.trim();
    if (gameName.isEmpty || selectedPlayerIds.isEmpty) return;
    final updated = GameSession(
      id: session?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      gameBlockId: widget.block.id,
      name: gameName,
      highWins: widget.block.id == 'ten_thousand' ? true : highWins,
      playerIds: selectedPlayerIds.toList(),
      createdAt: session?.createdAt ?? DateTime.now(),
    );
    if (session == null) {
      session = await widget.controller.addGameSession(
        gameBlockId: updated.gameBlockId,
        name: updated.name,
        highWins: updated.highWins,
        playerIds: updated.playerIds,
      );
    } else {
      session = updated;
      await widget.controller.updateGameSession(updated);
    }
  }
}

class GameRoundsPage extends StatefulWidget {
  const GameRoundsPage({
    super.key,
    required this.controller,
    required this.session,
  });

  final AppController controller;
  final GameSession session;

  @override
  State<GameRoundsPage> createState() => _GameRoundsPageState();
}

class _GameRoundsPageState extends State<GameRoundsPage> {
  Future<void> _newRound() async {
    final round = await widget.controller.addGameRound(
      sessionId: widget.session.id,
      gameBlockId: widget.session.gameBlockId,
      playerIds: widget.session.playerIds,
    );
    if (!mounted) return;
    await pushPage(
      context,
      _SubroundTable(
        controller: widget.controller,
        session: widget.session,
        round: round,
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final rounds = widget.controller.gameRounds
        .where((round) => round.sessionId == widget.session.id)
        .toList()
      ..sort((first, second) => second.createdAt.compareTo(first.createdAt));
    return Scaffold(
      appBar: AppBar(title: Text(widget.session.name)),
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _ActionTile(
              icon: Icons.add_rounded,
              title: 'Neuer Durchgang',
              detail: 'Einen weiteren Durchgang beginnen',
              onTap: _newRound,
            ),
            const SizedBox(height: 12),
            ...rounds.asMap().entries.map((entry) {
              final roundNumber = rounds.length - entry.key;
              final round = entry.value;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('$roundNumber')),
                  title: Text('Durchgang $roundNumber'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${round.playerIds.length} Spieler • '
                        '${_subroundCount(round)} Spielrunden',
                      ),
                      Text(
                        round.completed
                            ? 'Abgeschlossen • Sieger: ${_winnerNames(round)}'
                            : 'Offen',
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    tooltip: 'Durchgang löschen',
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _confirmDeleteRound(context, round),
                  ),
                  onTap: () => pushPage(
                    context,
                    _SubroundTable(
                      controller: widget.controller,
                      session: widget.session,
                      round: round,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _winnerNames(GameRound round) => round.winnerPlayerIds.isEmpty
      ? '–'
      : round.winnerPlayerIds
          .map((id) => widget.controller.playerById(id)?.name ?? 'Unbekannt')
          .join(', ');

  int _subroundCount(GameRound round) =>
      widget.controller.games.where((game) => game.roundId == round.id).length;

  Future<void> _confirmDeleteRound(
    BuildContext context,
    GameRound round,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Durchgang löschen?'),
        content: const Text('Diesen Durchgang und seine Spielrunden löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.controller.deleteGameRound(round.id);
      if (mounted) setState(() {});
    }
  }
}

class _SubroundTable extends StatefulWidget {
  const _SubroundTable({
    required this.controller,
    required this.session,
    required this.round,
  });
  final AppController controller;
  final GameSession session;
  final GameRound round;

  @override
  State<_SubroundTable> createState() => _SubroundTableState();
}

class _SubroundTableState extends State<_SubroundTable> {
  final draftControllers = <String, TextEditingController>{};
  final roundControllers = <String, TextEditingController>{};
  final verticalScrollController = ScrollController();
  final horizontalScrollController = ScrollController();
  bool editingLatest = false;

  @override
  void dispose() {
    for (final controller in draftControllers.values) {
      controller.dispose();
    }
    for (final controller in roundControllers.values) {
      controller.dispose();
    }
    verticalScrollController.dispose();
    horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rounds = widget.controller.games
        .where((game) => game.roundId == widget.round.id)
        .toList()
      ..sort((first, second) => second.playedAt.compareTo(first.playedAt));
    final totals = {
      for (final player in widget.round.playerIds)
        player: rounds.fold<int>(
          0,
          (sum, round) => sum + (round.scores[player] ?? 0),
        ),
    };
    final winningValue = rounds.isEmpty
        ? null
        : widget.session.highWins
            ? totals.values
                .reduce((first, second) => first > second ? first : second)
            : totals.values
                .reduce((first, second) => first < second ? first : second);
    return Scaffold(
      appBar: AppBar(title: Text(widget.session.name)),
      body: LayoutBuilder(
        builder: (context, constraints) => Scrollbar(
          controller: verticalScrollController,
          child: SingleChildScrollView(
            controller: verticalScrollController,
            padding: const EdgeInsets.all(12),
            child: Scrollbar(
              controller: horizontalScrollController,
              notificationPredicate: (notification) => notification.depth == 1,
              child: SingleChildScrollView(
                controller: horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Table(
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: .6,
                        ),
                        verticalInside: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: .6,
                        ),
                      ),
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      columnWidths: const {0: IntrinsicColumnWidth()},
                      children: [
                        _headerRow(context),
                        _totalsRow(context, totals, winningValue),
                        _draftRow(context, rounds.length + 1),
                        ...rounds.map(
                          (round) => _roundRow(
                            context,
                            round,
                            rounds.first.id == round.id,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TableRow _headerRow(BuildContext context) => TableRow(
        children: [
          _tableCell(context, const SizedBox.shrink(), bold: true),
          ...widget.round.playerIds.map(
            (id) => _tableCell(
              context,
              Text(
                widget.controller.playerById(id)?.name ?? 'Unbekannt',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              bold: true,
            ),
          ),
        ],
      );

  TableRow _totalsRow(
    BuildContext context,
    Map<String, int> totals,
    int? winningValue,
  ) =>
      TableRow(
        children: [
          _tableCell(context, const Text('Σ'), bold: true),
          ...widget.round.playerIds.map((id) {
            final value = totals[id] ?? 0;
            final isWinner = winningValue != null && value == winningValue;
            return _tableCell(
              context,
              Text(
                '$value',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: winningValue == null
                      ? null
                      : isWinner
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ],
      );

  TableRow _draftRow(BuildContext context, int roundNumber) => TableRow(
        children: [
          _tableCell(
            context,
            IconButton(
              tooltip: 'Runde $roundNumber aufzeichnen',
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _recordRound(roundNumber),
            ),
            padding: EdgeInsets.zero,
          ),
          ...widget.round.playerIds.map(
            (id) => _tableCell(
              context,
              _scoreField(draftControllers, id),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      );

  TableRow _roundRow(BuildContext context, GameRecord round, bool isLatest) =>
      TableRow(
        children: [
          _tableCell(
            context,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: Text(_roundNumber(round))),
                if (isLatest)
                  IconButton(
                    tooltip: editingLatest
                        ? 'Bearbeiten beenden'
                        : 'Letzte Spielrunde bearbeiten',
                    icon: Icon(
                      editingLatest ? Icons.check_rounded : Icons.edit_outlined,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () =>
                        setState(() => editingLatest = !editingLatest),
                  ),
                if (isLatest)
                  IconButton(
                    tooltip: 'Spielrunde löschen',
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    padding: EdgeInsets.zero,
                    onPressed: () => _confirmDeleteRound(context, round),
                  ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
          ...widget.round.playerIds.map(
            (id) => _tableCell(
              context,
              isLatest && editingLatest
                  ? _scoreField(
                      roundControllers,
                      '${round.id}:$id',
                      value: round.scores[id],
                      onChanged: (value) => _updateRoundScore(
                        round,
                        id,
                        value,
                      ),
                    )
                  : Text(
                      round.scores.containsKey(id) ? '${round.scores[id]}' : '',
                      textAlign: TextAlign.center,
                    ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      );

  Widget _tableCell(
    BuildContext context,
    Widget child, {
    bool bold = false,
    EdgeInsetsGeometry? padding,
  }) =>
      Container(
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.center,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: DefaultTextStyle.merge(
          style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
          child: child,
        ),
      );

  Widget _scoreField(
    Map<String, TextEditingController> controllers,
    String key, {
    int? value,
    ValueChanged<String>? onChanged,
  }) {
    final controller = controllers.putIfAbsent(
      key,
      () => TextEditingController(text: value == null ? '' : '$value'),
    );
    return _CalculatorField(
      controller: controller,
      hintText: '0',
      allowNegative: widget.session.gameBlockId != 'ten_thousand',
      onChanged: onChanged,
    );
  }

  String _roundNumber(GameRecord round) {
    final rounds = widget.controller.games
        .where((game) => game.roundId == widget.round.id)
        .toList()
      ..sort((first, second) => first.playedAt.compareTo(second.playedAt));
    return '${rounds.indexOf(round) + 1}';
  }

  Future<void> _recordRound(int roundNumber) async {
    final scores = <String, int>{};
    for (final id in widget.round.playerIds) {
      final text = draftControllers[id]?.text.trim() ?? '';
      final score = int.tryParse(text);
      if (score != null && !_isValidScore(score)) {
        _showInvalidScoreError();
        return;
      }
      if (score != null) scores[id] = score;
    }
    await widget.controller.addGame(
      GameRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        roundId: widget.round.id,
        sessionId: widget.session.id,
        gameBlockId: widget.round.gameBlockId,
        playerIds: widget.round.playerIds,
        scores: scores,
        playedAt: DateTime.now(),
      ),
    );
    for (final controller in draftControllers.values) {
      controller.clear();
    }
    if (mounted) setState(() {});
  }

  Future<void> _updateRoundScore(
    GameRecord round,
    String playerId,
    String value,
  ) async {
    final scores = {...round.scores};
    if (value.trim().isEmpty) {
      scores.remove(playerId);
    } else {
      final score = int.tryParse(value);
      if (score == null) return;
      if (!_isValidScore(score)) {
        _showInvalidScoreError();
        return;
      }
      scores[playerId] = score;
    }
    await widget.controller.updateGame(
      GameRecord(
        id: round.id,
        roundId: round.roundId,
        sessionId: round.sessionId,
        gameBlockId: round.gameBlockId,
        playerIds: round.playerIds,
        scores: scores,
        playedAt: round.playedAt,
      ),
    );
    if (mounted) setState(() {});
  }

  bool get _allowsNegativeScores =>
      widget.session.gameBlockId != 'one_plus_two' &&
      widget.session.gameBlockId != 'ten_thousand';

  bool _isValidScore(int score) {
    if (!_allowsNegativeScores && score < 0) return false;
    if (widget.session.gameBlockId == 'ten_thousand') {
      return score >= 350 && score % 50 == 0;
    }
    return true;
  }

  void _showInvalidScoreError() {
    final message = widget.session.gameBlockId == 'ten_thousand'
        ? 'Bei 10Tausend sind nur Werte ab 350 in 50er-Schritten erlaubt.'
        : 'Negative Werte sind hier nicht erlaubt.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _confirmDeleteRound(
    BuildContext context,
    GameRecord round,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Spielrunde löschen?'),
        content:
            const Text('Diese Spielrunde wirklich unwiderruflich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.controller.deleteGame(round.id);
      if (mounted) setState(() {});
    }
  }
}

class NewRoundPage extends StatelessWidget {
  const NewRoundPage({
    super.key,
    required this.controller,
    required this.session,
    required this.round,
  });
  final AppController controller;
  final GameSession session;
  final GameRound round;

  @override
  Widget build(BuildContext context) => _SubroundTable(
        controller: controller,
        session: session,
        round: round,
      );
}

class NewGamePage extends StatefulWidget {
  const NewGamePage({super.key, required this.controller, this.initialBlock});
  final AppController controller;
  final GameBlockDefinition? initialBlock;
  @override
  State<NewGamePage> createState() => _NewGamePageState();
}

class _NewGamePageState extends State<NewGamePage> {
  int step = 0;
  GameBlockDefinition? block;
  final selected = <String>{};
  final targetController = TextEditingController(text: '1000');
  @override
  void initState() {
    super.initState();
    block = widget.initialBlock;
    if (block != null) step = 1;
  }

  @override
  void dispose() {
    targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            ['Spielblock wählen', 'Spieler wählen', 'Spieloptionen'][step],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LinearProgressIndicator(value: (step + 1) / 3),
            const SizedBox(height: 20),
            if (step == 0)
              ...gameBlocks.map(
                (item) => Card(
                  child: RadioListTile<GameBlockDefinition>(
                    value: item,
                    groupValue: block,
                    onChanged: (value) => setState(() => block = value),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                    secondary: item.iconLabel == null
                        ? Icon(item.icon, color: item.color)
                        : Text(
                            item.iconLabel!,
                            style: TextStyle(
                              color: item.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            if (step == 1) ...[
              if (widget.controller.players.isEmpty)
                const Text('Lege zuerst einen Spieler an.'),
              ...widget.controller.players.map(
                (player) => CheckboxListTile(
                  value: selected.contains(player.id),
                  onChanged: (value) => setState(
                    () => value == true
                        ? selected.add(player.id)
                        : selected.remove(player.id),
                  ),
                  title: Text(player.name),
                  secondary: const Icon(Icons.person_rounded),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => pushPage(
                    context, AddPlayerPage(controller: widget.controller)),
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Neuen Spieler anlegen'),
              ),
            ],
            if (step == 2) ...[
              Text(
                'Optionen für ${block?.name ?? ''}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Zielpunktzahl',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const ListTile(
                leading: Icon(Icons.cloud_queue_rounded),
                title: Text('Cloud-Sync vorbereitet'),
                subtitle: Text(
                  'Spiele werden später geräteübergreifend synchronisiert.',
                ),
              ),
            ],
            const SizedBox(height: 28),
            Row(
              children: [
                if (step > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => step--),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Zurück'),
                    ),
                  ),
                if (step > 0) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _next,
                    icon: Icon(
                      step == 2
                          ? Icons.play_arrow_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                    label: Text(step == 2 ? 'Spiel starten' : 'Weiter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  void _next() {
    if (step == 0 && block == null || step == 1 && selected.isEmpty) return;
    if (step < 2) {
      setState(() => step++);
      return;
    }
    pushPage(
      context,
      ScoreboardPage(
        controller: widget.controller,
        block: block!,
        playerIds: selected.toList(),
      ),
    );
  }
}

class AddPlayerPage extends StatefulWidget {
  const AddPlayerPage({super.key, required this.controller, this.player});
  final AppController controller;
  final Player? player;
  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  late final TextEditingController name;
  late int? primaryColorValue;
  late int? secondaryColorValue;

  bool get isEditing => widget.player != null;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.player?.name ?? '');
    primaryColorValue = widget.player?.primaryColorValue;
    secondaryColorValue = widget.player?.secondaryColorValue;
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(name.text.isEmpty ? 'Spieler' : name.text)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: name,
              autofocus: true,
              onChanged: (_) {
                setState(() {});
                _saveChanges();
              },
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _PlayerColorPicker(
              label: 'Primärfarbe',
              selectedValue: primaryColorValue,
              onSelected: (value) {
                setState(() => primaryColorValue = value);
                _saveChanges();
              },
            ),
            const SizedBox(height: 12),
            _PlayerColorPicker(
              label: 'Sekundärfarbe',
              selectedValue: secondaryColorValue,
              onSelected: (value) {
                setState(() => secondaryColorValue = value);
                _saveChanges();
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: _PlayerIcon(
                primaryColorValue: primaryColorValue,
                secondaryColorValue: secondaryColorValue,
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 28),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Spieler löschen'),
                subtitle: const Text('Spieler unwiderruflich entfernen'),
                onTap: _delete,
              ),
            ],
          ],
        ),
      );

  Future<void> _saveChanges() {
    final player = widget.player;
    if (player == null) return Future.value();
    return widget.controller.updatePlayer(
      player.id,
      name: name.text.trim(),
      primaryColorValue: primaryColorValue,
      secondaryColorValue: secondaryColorValue,
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Spieler löschen?'),
        content: Text('„${name.text.trim()}“ wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.controller.deletePlayer(widget.player!.id);
      if (mounted) Navigator.pop(context);
    }
  }
}

class _CalculatorField extends StatefulWidget {
  const _CalculatorField({
    required this.controller,
    this.onChanged,
    this.hintText,
    this.allowNegative = true,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final bool allowNegative;

  @override
  State<_CalculatorField> createState() => _CalculatorFieldState();
}

class _CalculatorFieldState extends State<_CalculatorField> {
  Future<void> _openCalculator() async {
    var expression = widget.controller.text;
    final mediaQuery = MediaQuery.of(context);
    final availableHeight = math.max(0.0, mediaQuery.size.height - 133.0);
    final availableWidth = mediaQuery.size.width;
    const calculatorFixedHeight = 80.0;
    const gridVerticalSpacing = 8.0;
    const gridHorizontalPadding = 10.0;
    final maxButtonSize = math.max(
      0,
      (availableHeight - calculatorFixedHeight - gridVerticalSpacing) / 5,
    );
    final calculatorWidth = math
        .min(
          availableWidth,
          maxButtonSize * 4 + gridHorizontalPadding,
        )
        .toDouble();
    final buttonSize = math.max(
      0,
      (calculatorWidth - gridHorizontalPadding) / 4,
    );
    final calculatorHeight = math
        .min(
          availableHeight,
          calculatorFixedHeight + buttonSize * 5 + gridVerticalSpacing,
        )
        .toDouble();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: availableWidth,
        maxHeight: availableHeight,
      ),
      builder: (context) => SizedBox(
        width: calculatorWidth,
        height: calculatorHeight,
        child: _CalculatorPad(
          initialExpression: expression,
          allowNegative: widget.allowNegative,
          onExpressionChanged: (value) {
            expression = value;
            final result = _calculateExpression(value);
            if (value.isEmpty) {
              widget.controller.clear();
              widget.onChanged?.call('');
            } else if (result != null) {
              final text = _formatCalculatorValue(result);
              widget.controller.value = TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
              widget.onChanged?.call(text);
            }
          },
        ),
      ),
    );
    if (!mounted || result == null) return;
    widget.controller.value = TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
    widget.onChanged?.call(result);
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: widget.controller,
        readOnly: true,
        showCursor: false,
        textAlign: TextAlign.center,
        onTap: _openCalculator,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ).copyWith(hintText: widget.hintText),
      );
}

class _CalculatorPad extends StatefulWidget {
  const _CalculatorPad({
    required this.initialExpression,
    required this.allowNegative,
    required this.onExpressionChanged,
  });

  final String initialExpression;
  final bool allowNegative;
  final ValueChanged<String> onExpressionChanged;

  @override
  State<_CalculatorPad> createState() => _CalculatorPadState();
}

class _CalculatorPadState extends State<_CalculatorPad> {
  late String expression = widget.initialExpression;

  void _press(String value) {
    if (value == '−' && !widget.allowNegative) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Negative Werte sind hier nicht erlaubt.')),
      );
      return;
    }
    setState(() {
      if (value == 'AC') {
        expression = '';
      } else if (value == '⌫') {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
        }
      } else if (value == '()') {
        final opening = '('.allMatches(expression).length;
        final closing = ')'.allMatches(expression).length;
        expression += opening > closing ? ')' : '(';
      } else {
        expression += value;
      }
      widget.onExpressionChanged(expression);
    });
  }

  void _calculate() {
    final result = _calculateExpression(expression);
    if (result == null) return;
    Navigator.pop(context, _formatCalculatorValue(result));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final buttons = [
      ('AC', colors.secondaryContainer, colors.onSecondaryContainer),
      ('()', colors.secondaryContainer, colors.onSecondaryContainer),
      ('^', colors.secondaryContainer, colors.onSecondaryContainer),
      ('÷', colors.tertiaryContainer, colors.onTertiaryContainer),
      ('7', colors.surfaceContainerHighest, colors.onSurface),
      ('8', colors.surfaceContainerHighest, colors.onSurface),
      ('9', colors.surfaceContainerHighest, colors.onSurface),
      ('×', colors.tertiaryContainer, colors.onTertiaryContainer),
      ('4', colors.surfaceContainerHighest, colors.onSurface),
      ('5', colors.surfaceContainerHighest, colors.onSurface),
      ('6', colors.surfaceContainerHighest, colors.onSurface),
      ('−', colors.tertiaryContainer, colors.onTertiaryContainer),
      ('1', colors.surfaceContainerHighest, colors.onSurface),
      ('2', colors.surfaceContainerHighest, colors.onSurface),
      ('3', colors.surfaceContainerHighest, colors.onSurface),
      ('+', colors.tertiaryContainer, colors.onTertiaryContainer),
      ('0', colors.surfaceContainerHighest, colors.onSurface),
      (',', colors.surfaceContainerHighest, colors.onSurface),
      ('⌫', colors.surfaceContainerHighest, colors.onSurface),
      ('↵', colors.primary, colors.onPrimary),
    ];
    return SafeArea(
      top: false,
      left: false,
      right: false,
      minimum: const EdgeInsets.only(bottom: 2),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 12,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  expression.isEmpty ? '0' : expression,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            const SizedBox(height: 2),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                final button = buttons[index];
                return _CalculatorButton(
                  label: button.$1,
                  backgroundColor: button.$2,
                  foregroundColor: button.$3,
                  onPressed:
                      button.$1 == '↵' ? _calculate : () => _press(button.$1),
                  child: button.$1 == '↵'
                      ? const Icon(Icons.keyboard_return_rounded, size: 22)
                      : Text(
                          button.$1,
                          style: const TextStyle(fontSize: 18),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    required this.child,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: child,
      );
}

num? _calculateExpression(String input) {
  try {
    final parser = _ExpressionParser(input);
    final value = parser.parse();
    return parser.atEnd ? value : null;
  } on FormatException {
    return null;
  }
}

String _formatCalculatorValue(num value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toString();
}

class _ExpressionParser {
  _ExpressionParser(String input) : source = input.replaceAll(',', '.');

  final String source;
  var position = 0;

  bool get atEnd => position == source.length;

  num parse() {
    _skipSpaces();
    if (atEnd) throw const FormatException();
    final value = _parseExpression();
    _skipSpaces();
    if (!atEnd || !value.isFinite) throw const FormatException();
    return value;
  }

  num _parseExpression() {
    var value = _parseTerm();
    while (true) {
      _skipSpaces();
      if (_match('+')) {
        value += _parseTerm();
      } else if (_match('-') || _match('−')) {
        value -= _parseTerm();
      } else {
        return value;
      }
    }
  }

  num _parseTerm() {
    var value = _parsePower();
    while (true) {
      _skipSpaces();
      if (_match('*') || _match('×')) {
        value *= _parsePower();
      } else if (_match('/') || _match('÷')) {
        final divisor = _parsePower();
        if (divisor == 0) throw const FormatException();
        value /= divisor;
      } else {
        return value;
      }
    }
  }

  num _parsePower() {
    final value = _parseFactor();
    if (!_match('^')) return value;
    return math.pow(value, _parsePower());
  }

  num _parseFactor() {
    _skipSpaces();
    if (_match('+')) return _parseFactor();
    if (_match('-') || _match('−')) return -_parseFactor();
    if (_match('(')) {
      final value = _parseExpression();
      if (!_match(')')) throw const FormatException();
      return value;
    }
    final start = position;
    while (position < source.length &&
        RegExp(r'[0-9.]').hasMatch(source[position])) {
      position++;
    }
    if (start == position) throw const FormatException();
    final value = double.tryParse(source.substring(start, position));
    if (value == null) throw const FormatException();
    return value;
  }

  bool _match(String character) {
    if (source.startsWith(character, position)) {
      position += character.length;
      return true;
    }
    return false;
  }

  void _skipSpaces() {
    while (position < source.length && source[position] == ' ') {
      position++;
    }
  }
}

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({
    super.key,
    required this.controller,
    required this.block,
    required this.playerIds,
  });
  final AppController controller;
  final GameBlockDefinition block;
  final List<String> playerIds;
  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  final scores = <String, int>{};
  final scoreControllers = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final controller in scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.block.name)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Runde 1',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Punkte eintragen und anschließend eine neue Runde starten.',
            ),
            const SizedBox(height: 20),
            ...widget.playerIds.map((id) {
              final player = widget.controller.playerById(id)!;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          player.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: _CalculatorField(
                          controller: scoreControllers.putIfAbsent(
                            id,
                            TextEditingController.new,
                          ),
                          onChanged: (value) =>
                              scores[id] = int.tryParse(value) ?? 0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded),
              label: const Text('Neue Runde'),
            ),
          ],
        ),
      );
}

class _PlayerColorPicker extends StatelessWidget {
  const _PlayerColorPicker({
    required this.label,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final int? selectedValue;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppSettings.playerColors.map((color) {
            final isSelected = selectedValue == color.toARGB32();
            return Semantics(
              button: true,
              label: '$label ${color.toARGB32()}',
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onSelected(color.toARGB32()),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: color,
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 18,
                          color: color.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      );
}

class _PlayerIcon extends StatelessWidget {
  const _PlayerIcon({this.primaryColorValue, this.secondaryColorValue});

  final int? primaryColorValue;
  final int? secondaryColorValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 30,
      backgroundColor: primaryColorValue == null
          ? colorScheme.primary
          : Color(primaryColorValue!),
      child: Icon(
        Icons.person_rounded,
        size: 34,
        color: secondaryColorValue == null
            ? colorScheme.surfaceContainerHighest
            : Color(secondaryColorValue!),
      ),
    );
  }
}

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  Future<void> _openNewPlayer() async {
    final player = await widget.controller.addPlayer('');
    if (!mounted) return;
    await pushPage(
      context,
      AddPlayerPage(controller: widget.controller, player: player),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openPlayer(Player player) async {
    await pushPage(
      context,
      AddPlayerPage(controller: widget.controller, player: player),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = [...widget.controller.players]..sort((first, second) {
        final firstGames = _gameCount(first);
        final secondGames = _gameCount(second);
        final gamesComparison = secondGames.compareTo(firstGames);
        return gamesComparison != 0
            ? gamesComparison
            : first.createdAt.compareTo(second.createdAt);
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Spieler')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _ActionTile(
            icon: Icons.add_rounded,
            title: 'Spieler hinzufügen',
            detail: 'Neuen Spieler anlegen',
            onTap: _openNewPlayer,
          ),
          const SizedBox(height: 12),
          ...sortedPlayers.map(
            (player) => Card(
              child: ListTile(
                leading: _PlayerIcon(
                  primaryColorValue: player.primaryColorValue,
                  secondaryColorValue: player.secondaryColorValue,
                ),
                title: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: player.name.isEmpty
                            ? 'Unbenannter Spieler'
                            : player.name,
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: Transform.translate(
                          offset: const Offset(0, 4),
                          child: Text(
                            ' ${player.id}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                subtitle: Text('${_gameCount(player)} Spiele'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _openPlayer(player),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _gameCount(Player player) => widget.controller.games
      .where((game) => game.playerIds.contains(player.id))
      .length;
}

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key, required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) {
    final totals = {
      for (final player in controller.players)
        player.id: controller.games.fold<int>(
          0,
          (sum, game) => sum + (game.scores[player.id] ?? 0),
        ),
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Gesamtstatistik')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Alle Spieler',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Gesammelte Punkte über alle gespeicherten Spiele.'),
          const SizedBox(height: 16),
          ...controller.players.map(
            (player) => Card(
              child: ListTile(
                leading: const Icon(Icons.insights_rounded),
                title: Text(player.name),
                trailing: Text(
                  '${totals[player.id]} Punkte',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
          if (controller.players.isEmpty)
            const Text('Noch keine Spieler vorhanden.'),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.controller});
  final SettingsController controller;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AppSettings draft;

  @override
  void initState() {
    super.initState();
    draft = widget.controller.settings;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Einstellungen'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Darstellung',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: draft.fontFamily,
              decoration: const InputDecoration(
                labelText: 'Schriftart',
                border: OutlineInputBorder(),
              ),
              items: [
                'Ubuntu',
                'OpenDyslexic',
                'NotoSans',
                'CourierPrime',
                'Ubuntu Mono',
              ]
                  .map(
                    (font) => DropdownMenuItem(value: font, child: Text(font)),
                  )
                  .toList(),
              onChanged: (value) =>
                  _updateDraft(draft.copyWith(fontFamily: value)),
            ),
            const SizedBox(height: 12),
            Text('Schriftgröße: ${(draft.textScaleFactor * 100).round()} %'),
            Slider(
              value: draft.textScaleFactor,
              min: .5,
              max: 1.6,
              divisions: 22,
              label: '${(draft.textScaleFactor * 100).round()} %',
              onChanged: (value) =>
                  _updateDraft(draft.copyWith(textScaleFactor: value)),
            ),
            SwitchListTile(
              title: const Text('Helles Theme'),
              value: draft.useLightTheme,
              onChanged: (value) =>
                  _updateDraft(draft.copyWith(useLightTheme: value)),
            ),
            _ColorDropdown(
              label: 'Akzentfarbe',
              value: draft.accentColorValue,
              onChanged: (value) =>
                  _updateDraft(draft.copyWith(accentColorValue: value)),
            ),
            _ColorDropdown(
              label: 'Highlight-Farbe',
              value: draft.highlightColorValue,
              onChanged: (value) =>
                  _updateDraft(draft.copyWith(highlightColorValue: value)),
            ),
          ],
        ),
      );

  Future<void> _updateDraft(AppSettings value) async {
    setState(() => draft = value);
    await widget.controller.update(value);
  }
}

class _ColorDropdown extends StatelessWidget {
  const _ColorDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: DropdownButtonFormField<int>(
          initialValue: value,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (var index = 0;
                index < AppSettings.availableColors.length;
                index++)
              DropdownMenuItem(
                value: AppSettings.availableColors[index].toARGB32(),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: AppSettings.availableColors[index],
                    ),
                    const SizedBox(width: 10),
                    Text(AppSettings.colorNames[index]),
                  ],
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      );
}
