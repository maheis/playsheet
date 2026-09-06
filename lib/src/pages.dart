import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              child: SvgPicture.asset(
                'assets/icons/color_transparent_icon.svg',
                width: 75,
                height: 75,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            title: const Text('PlaySheet'),
            actions: [
              IconButton(
                tooltip: 'Spieler',
                icon: const Icon(Icons.people_alt_rounded),
                onPressed: () =>
                    pushPage(context, PlayersPage(controller: controller)),
              ),
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
                      icon: gameBlockFor('ten_thousand').icon,
                      iconLabel: gameBlockFor('ten_thousand').iconLabel,
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
                    _ActionTile(
                      icon: gameBlockFor('damjagen').icon,
                      iconLabel: gameBlockFor('damjagen').iconLabel,
                      title: "Dam'jagen",
                      detail: '${_gameCount(controller, 'damjagen')} Spiele',
                      onTap: () => pushPage(
                        context,
                        GameSessionsPage(
                          controller: controller,
                          block: gameBlockFor('damjagen'),
                        ),
                      ),
                    ),
                    _ActionTile(
                      icon: gameBlockFor('tally').icon,
                      iconLabel: gameBlockFor('tally').iconLabel,
                      title: 'Strichliste',
                      detail: '${_gameCount(controller, 'tally')} Spiele',
                      onTap: () => pushPage(
                        context,
                        GameSessionsPage(
                          controller: controller,
                          block: gameBlockFor('tally'),
                        ),
                      ),
                    ),
                    _ActionTile(
                      icon: gameBlockFor('dice_block').icon,
                      title: 'Würfelblock',
                      detail: '${_gameCount(controller, 'dice_block')} Spiele',
                      onTap: () => pushPage(
                        context,
                        GameSessionsPage(
                          controller: controller,
                          block: gameBlockFor('dice_block'),
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
                SizedBox(
                  width: 79,
                  child: Center(
                    child: iconLabel == null
                        ? Icon(
                            icon,
                            size: 32,
                            color: Theme.of(context).iconTheme.color,
                          )
                        : iconLabel == tallyIconLabel
                            ? _TallyIcon(
                                color: Theme.of(context).iconTheme.color!,
                              )
                            : Text(
                                iconLabel!,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
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

class _TallyIcon extends StatelessWidget {
  const _TallyIcon({required this.color, this.size = 24});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size * 1.8,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var index = 0; index < 4; index++)
                  Container(width: size / 10, height: size, color: color),
              ],
            ),
            Transform.rotate(
              angle: -0.35,
              child: Container(height: size / 10, color: color),
            ),
          ],
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
    final session = await pushPage<GameSession>(
      context,
      GameSessionConfigPage(
        controller: widget.controller,
        block: widget.block,
      ),
    );
    if (session != null && mounted) {
      final hasRound = widget.controller.gameRounds.any(
        (round) => round.sessionId == session.id,
      );
      GameRound? firstRound;
      if (!hasRound) {
        firstRound = await widget.controller.addGameRound(
          sessionId: session.id,
          gameBlockId: session.gameBlockId,
          playerIds: session.playerIds,
        );
      }
      await _openGame(session, initialRound: firstRound);
    }
    if (mounted) setState(() {});
  }

  Future<void> _openGame(GameSession session, {GameRound? initialRound}) async {
    await pushPage(
      context,
      GameRoundsPage(
        controller: widget.controller,
        session: session,
        initialRound: initialRound,
      ),
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
            detail: widget.block.id == 'damjagen'
                ? 'Name, Maximalpunkte und Spieler festlegen'
                : 'Name, Gewinnart und Spieler festlegen',
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
                      : widget.block.iconLabel == tallyIconLabel
                          ? _TallyIcon(
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 18,
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
                    Row(
                      children: [
                        const Icon(Icons.event_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(session.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.play_arrow_rounded, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _lastPlayedLabel(session),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
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

  String _lastPlayedLabel(GameSession session) {
    final games = widget.controller.games
        .where((game) => game.sessionId == session.id)
        .toList();
    return games.isEmpty ? '–' : _formatDate(_lastPlayedAt(session));
  }

  String _formatDate(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(value.day)}.${twoDigits(value.month)}.'
        '${value.year} ${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }

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
  late final TextEditingController maxPoints;
  final selectedPlayerIds = <String>{};
  GameSession? session;
  bool closing = false;

  @override
  void initState() {
    super.initState();
    name = TextEditingController();
    maxPoints = TextEditingController(text: '16');
  }

  @override
  void dispose() {
    name.dispose();
    maxPoints.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope<GameSession?>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _closeConfiguration();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('${widget.block.name} konfigurieren'),
            leading: IconButton(
              tooltip: 'Zurück',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: _closeConfiguration,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Autocomplete<String>(
                initialValue: TextEditingValue(text: name.text),
                optionsBuilder: (value) {
                  final query = value.text.trim().toLowerCase();
                  final names = widget.controller.gameSessions
                      .map((session) => session.name.trim())
                      .where((value) => value.isNotEmpty)
                      .toSet()
                      .toList()
                    ..sort();
                  if (query.isEmpty) return names;
                  return names.where(
                    (gameName) => gameName.toLowerCase().contains(query),
                  );
                },
                onSelected: (value) {
                  name.text = value;
                  name.selection =
                      TextSelection.collapsed(offset: name.text.length);
                  _persistConfiguration();
                },
                fieldViewBuilder:
                    (context, fieldController, focusNode, onSubmitted) {
                  return TextField(
                    controller: fieldController,
                    focusNode: focusNode,
                    autofocus: true,
                    onChanged: (value) {
                      name.text = value;
                      _persistConfiguration();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Name des physischen Spiels',
                      hintText: 'z. B. Wizard',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),
              if (widget.block.id == 'damjagen') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: maxPoints,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _persistConfiguration(),
                  decoration: const InputDecoration(
                    labelText: 'Maximalpunkte',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              if (widget.block.id != 'ten_thousand' &&
                  widget.block.id != 'damjagen' &&
                  widget.block.id != 'dice_block') ...[
                const SizedBox(height: 20),
                Text('Gewinnart',
                    style: Theme.of(context).textTheme.titleMedium),
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
                  playerNameFieldController?.clear();
                  typedPlayerName = '';
                  _addPlayer(player);
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
        ),
      );

  Future<void> _closeConfiguration() async {
    if (closing) return;
    closing = true;
    await _persistConfiguration();
    if (!mounted) return;
    Navigator.pop(context, session);
  }

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
    if (selectedPlayerIds.isEmpty) return;
    final gameName = name.text.trim().isEmpty
        ? '${widget.block.name} ${widget.controller.gameSessions.length + 1}'
        : name.text.trim();
    final updated = GameSession(
      id: session?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      gameBlockId: widget.block.id,
      name: gameName,
      highWins:
          widget.block.id == 'ten_thousand' || widget.block.id == 'dice_block'
              ? true
              : widget.block.id == 'damjagen'
                  ? false
                  : highWins,
      playerIds: selectedPlayerIds.toList(),
      createdAt: session?.createdAt ?? DateTime.now(),
      maxPoints: int.tryParse(maxPoints.text.trim()) ?? 16,
    );
    if (session == null) {
      session = await widget.controller.addGameSession(
        gameBlockId: updated.gameBlockId,
        name: updated.name,
        highWins: updated.highWins,
        playerIds: updated.playerIds,
        maxPoints: updated.maxPoints,
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
    this.initialRound,
  });

  final AppController controller;
  final GameSession session;
  final GameRound? initialRound;

  @override
  State<GameRoundsPage> createState() => _GameRoundsPageState();
}

class _GameRoundsPageState extends State<GameRoundsPage> {
  @override
  void initState() {
    super.initState();
    if (widget.initialRound != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openRound(widget.initialRound!);
      });
    }
  }

  Future<void> _openRound(GameRound round) async {
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

  Future<void> _newRound() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Neue Runde starten?'),
        content: const Text('Soll eine neue Runde gestartet werden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Starten'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
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
              icon: Icons.add_circle_outline_rounded,
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
                      Row(
                        children: [
                          const Icon(Icons.event_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Angelegt: ${_formatDate(round.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Zuletzt gespielt: ${_lastPlayedLabel(round)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Text(
                        round.completed
                            ? 'Abgeschlossen • Sieger: ${_winnerNames(round)}'
                            : 'Offen • Aktueller Sieger: '
                                '${_currentWinnerNames(round)}',
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

  String _currentWinnerNames(GameRound round) {
    final games = widget.controller.games
        .where((game) => game.roundId == round.id)
        .toList();
    if (games.isEmpty) return '–';
    final totals = {
      for (final playerId in round.playerIds)
        playerId: games.fold<int>(
          0,
          (sum, game) => sum + (game.scores[playerId] ?? 0),
        ),
    };
    final winningValue = widget.session.highWins
        ? totals.values.reduce(
            (first, second) => first > second ? first : second,
          )
        : totals.values.reduce(
            (first, second) => first < second ? first : second,
          );
    final winnerIds = totals.entries
        .where((entry) => entry.value == winningValue)
        .map((entry) => entry.key);
    return winnerIds
        .map((id) => widget.controller.playerById(id)?.name ?? 'Unbekannt')
        .join(', ');
  }

  int _subroundCount(GameRound round) =>
      widget.controller.games.where((game) => game.roundId == round.id).length;

  String _lastPlayedLabel(GameRound round) {
    final playedAt = widget.controller.games
        .where((game) => game.roundId == round.id)
        .map((game) => game.playedAt)
        .toList();
    if (playedAt.isEmpty) return '–';
    final lastPlayed = playedAt.reduce(
      (first, second) => first.isAfter(second) ? first : second,
    );
    return _formatDate(lastPlayed);
  }

  String _formatDate(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(value.day)}.${twoDigits(value.month)}.'
        '${value.year} ${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }

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
  final calculatorFocusNodes = <String, FocusNode>{};
  final calculatorOpeners = <String, VoidCallback>{};
  final verticalScrollController = ScrollController();
  final horizontalScrollController = ScrollController();
  final diceControllers = <String, TextEditingController>{};
  final committedDraftPlayerIds = <String>{};
  final virginPlayers = <String>{};
  String? dealerAfterDraft;
  String? throughMarchPlayer;
  bool editingLatest = false;
  bool selectingDealer = false;

  @override
  void dispose() {
    for (final controller in draftControllers.values) {
      controller.dispose();
    }
    for (final controller in roundControllers.values) {
      controller.dispose();
    }
    for (final controller in diceControllers.values) {
      controller.dispose();
    }
    for (final focusNode in calculatorFocusNodes.values) {
      focusNode.dispose();
    }
    verticalScrollController.dispose();
    horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!widget.round.completed &&
        widget.round.dealerPlayerId == null &&
        widget.round.gameBlockId != 'dice_block') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _selectDealer());
    }
  }

  Future<void> _selectDealer() async {
    if (selectingDealer || !mounted) return;
    selectingDealer = true;
    final previousRounds = widget.controller.gameRounds
        .where((round) =>
            round.sessionId == widget.round.sessionId &&
            round.id != widget.round.id &&
            round.dealerPlayerId != null)
        .toList()
      ..sort((first, second) => first.createdAt.compareTo(second.createdAt));
    final currentDealerId = previousRounds.isEmpty
        ? null
        : _dealerAtEndOfRound(previousRounds.last);
    final currentDealerIndex = currentDealerId == null
        ? -1
        : widget.round.playerIds.indexOf(currentDealerId);
    final suggestedDealerId = currentDealerIndex < 0
        ? null
        : widget.round.playerIds[
            (currentDealerIndex + 1) % widget.round.playerIds.length];
    final dealerSelection =
        await showDialog<({String? dealerId, bool advance})>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        var selectedDealerId = suggestedDealerId ??
            (widget.round.playerIds.isEmpty
                ? null
                : widget.round.playerIds.first);
        var advanceDealerOnScore = widget.session.dealerAdvancesOnScore ||
            _currentRound.dealerAdvancesOnScore;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Wer ist dran?'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final playerId in widget.round.playerIds)
                    ListTile(
                      selected: selectedDealerId == playerId,
                      selectedTileColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      leading: Icon(
                        playerId == currentDealerId
                            ? Icons.person_pin_circle_rounded
                            : Icons.person_outline_rounded,
                        color: playerId == currentDealerId
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(_playerName(playerId)),
                      subtitle: playerId == currentDealerId
                          ? const Text('aktuell dran')
                          : playerId == suggestedDealerId
                              ? const Text('Vorschlag für diesen Durchgang')
                              : null,
                      onTap: () =>
                          setDialogState(() => selectedDealerId = playerId),
                    ),
                  ListTile(
                    selected: selectedDealerId == '',
                    leading: const Icon(Icons.remove_circle_outline_rounded),
                    title: const Text('Niemand / egal'),
                    onTap: () => setDialogState(() => selectedDealerId = ''),
                  ),
                  CheckboxListTile(
                    value: advanceDealerOnScore,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Nach Punkteingabe weitergeben'),
                    subtitle: const Text(
                      'Dran wechselt, sobald der aktuelle\n'
                      'Spieler Punkte erhält.',
                    ),
                    onChanged: (value) => setDialogState(
                      () => advanceDealerOnScore = value ?? false,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  (dealerId: selectedDealerId, advance: advanceDealerOnScore),
                ),
                child: const Text('Übernehmen'),
              ),
            ],
          ),
        );
      },
    );
    selectingDealer = false;
    if (dealerSelection == null || !mounted) return;
    await widget.controller.updateGameRoundDealer(
      widget.round.id,
      dealerSelection.dealerId ?? '',
    );
    await widget.controller.updateGameRoundDealerAdvance(
      widget.round.id,
      dealerSelection.advance,
    );
    await widget.controller.updateGameSessionDealerAdvance(
      widget.session.id,
      dealerSelection.advance,
    );
    if (mounted) setState(() {});
  }

  Future<void> _reorderPlayers() async {
    final orderedPlayerIds = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) {
        var playerIds = [...widget.round.playerIds];
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Spielerreihenfolge'),
            content: SizedBox(
              width: double.maxFinite,
              child: ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                itemCount: playerIds.length,
                onReorderItem: (oldIndex, newIndex) {
                  setDialogState(() {
                    final playerId = playerIds.removeAt(oldIndex);
                    playerIds.insert(newIndex, playerId);
                  });
                },
                itemBuilder: (context, index) {
                  final playerId = playerIds[index];
                  return ListTile(
                    key: ValueKey(playerId),
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle_rounded),
                    ),
                    title: Text(_playerName(playerId)),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Abbrechen'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, playerIds),
                child: const Text('Übernehmen'),
              ),
            ],
          ),
        );
      },
    );
    if (orderedPlayerIds == null || !mounted) return;
    widget.round.playerIds
      ..clear()
      ..addAll(orderedPlayerIds);
    await widget.controller.updateGameRoundPlayerOrder(
      widget.round.id,
      orderedPlayerIds,
    );
    if (mounted) setState(() {});
  }

  String _playerName(String id) =>
      widget.controller.playerById(id)?.name.isNotEmpty == true
          ? widget.controller.playerById(id)!.name
          : 'Unbekannt';

  String? get _firstDealer => widget.controller.gameRounds
      .firstWhere(
        (round) => round.id == widget.round.id,
        orElse: () => widget.round,
      )
      .dealerPlayerId;

  String? _dealerAtEndOfRound(GameRound round) {
    final initialDealerId = round.dealerPlayerId;
    if (!round.dealerAdvancesOnScore || initialDealerId == null) {
      return initialDealerId;
    }
    var dealerId = initialDealerId;
    final games = widget.controller.games
        .where((game) => game.roundId == round.id)
        .toList()
      ..sort((first, second) => first.playedAt.compareTo(second.playedAt));
    for (final game in games) {
      for (var index = 0; index < round.playerIds.length; index++) {
        if (!game.scores.containsKey(dealerId)) break;
        dealerId = _nextPlayerId(dealerId);
      }
    }
    return dealerId;
  }

  GameRound get _currentRound => widget.controller.gameRounds.firstWhere(
        (round) => round.id == widget.round.id,
        orElse: () => widget.round,
      );

  String? _dealerForGame(GameRecord game, List<GameRecord> rounds) {
    final firstDealer = _firstDealer;
    if (firstDealer == null || widget.round.playerIds.isEmpty) return null;
    if (_currentRound.dealerAdvancesOnScore) {
      final chronologicalRounds = [...rounds]
        ..sort((first, second) => first.playedAt.compareTo(second.playedAt));
      var dealerId = firstDealer;
      for (final round in chronologicalRounds) {
        if (round == game) break;
        if (round.scores.containsKey(dealerId)) {
          dealerId = _nextPlayerId(dealerId);
        }
      }
      return dealerId;
    }
    final chronologicalIndex = rounds.length - 1 - rounds.indexOf(game);
    final firstIndex = widget.round.playerIds.indexOf(firstDealer);
    if (firstIndex < 0) return null;
    return widget.round.playerIds[
        (firstIndex + chronologicalIndex) % widget.round.playerIds.length];
  }

  String? _dealerForDraft(List<GameRecord> rounds) {
    final firstDealer = _firstDealer;
    if (firstDealer == null || widget.round.playerIds.isEmpty) return null;
    if (_currentRound.dealerAdvancesOnScore) {
      final chronologicalRounds = [...rounds]
        ..sort((first, second) => first.playedAt.compareTo(second.playedAt));
      var dealerId = dealerAfterDraft ?? firstDealer;
      if (dealerAfterDraft == null) {
        for (final round in chronologicalRounds) {
          for (var index = 0; index < widget.round.playerIds.length; index++) {
            if (!round.scores.containsKey(dealerId)) break;
            dealerId = _nextPlayerId(dealerId);
          }
        }
      }
      for (final playerId in committedDraftPlayerIds) {
        if (playerId == dealerId) {
          dealerId = _nextPlayerId(dealerId);
        }
      }
      return dealerId;
    }
    final firstIndex = widget.round.playerIds.indexOf(firstDealer);
    if (firstIndex < 0) return null;
    return widget.round.playerIds[
        (firstIndex + rounds.length) % widget.round.playerIds.length];
  }

  String _nextPlayerId(String playerId) {
    final currentIndex = widget.round.playerIds.indexOf(playerId);
    if (currentIndex < 0) return playerId;
    return widget
        .round.playerIds[(currentIndex + 1) % widget.round.playerIds.length];
  }

  Future<void> _newRound() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Neue Runde starten?'),
        content: const Text('Soll eine neue Runde gestartet werden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Starten'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final round = await widget.controller.addGameRound(
      sessionId: widget.session.id,
      gameBlockId: widget.session.gameBlockId,
      playerIds: widget.session.playerIds,
    );
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => _SubroundTable(
          controller: widget.controller,
          session: widget.session,
          round: round,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rounds = widget.controller.games
        .where((game) => game.roundId == widget.round.id)
        .toList()
      ..sort((first, second) => second.playedAt.compareTo(first.playedAt));
    final draftScores = {
      for (final entry in draftControllers.entries)
        if (int.tryParse(entry.value.text.trim()) != null)
          entry.key: int.parse(entry.value.text.trim()),
    };
    final effectiveDraftScores = widget.round.gameBlockId == 'damjagen'
        ? _damjagenScoresForDisplay(draftScores)
        : draftScores;
    final totals = {
      for (final player in widget.round.playerIds)
        player: rounds.fold<int>(
              0,
              (sum, round) => sum + (round.scores[player] ?? 0),
            ) +
            (effectiveDraftScores[player] ?? 0),
    };
    final winningValue = rounds.isEmpty && draftScores.isEmpty
        ? null
        : widget.session.highWins
            ? totals.values
                .reduce((first, second) => first > second ? first : second)
            : totals.values
                .reduce((first, second) => first < second ? first : second);
    if (widget.round.gameBlockId == 'tally') {
      return _buildTallyPage(context);
    }
    if (widget.round.gameBlockId == 'dice_block') {
      return _buildDiceBlockPage(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.name),
        actions: [
          if (!widget.round.completed)
            IconButton(
              tooltip: 'Neue Runde',
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: _newRound,
            ),
          IconButton(
            tooltip: 'Spielerreihenfolge ändern',
            icon: const Icon(Icons.swap_vert_rounded),
            onPressed: _reorderPlayers,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: verticalScrollController,
                child: SingleChildScrollView(
                  controller: verticalScrollController,
                  padding: const EdgeInsets.all(12),
                  child: Scrollbar(
                    controller: horizontalScrollController,
                    notificationPredicate: (notification) =>
                        notification.depth == 1,
                    child: SingleChildScrollView(
                      controller: horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: constraints.maxWidth),
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
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            defaultColumnWidth: const IntrinsicColumnWidth(),
                            columnWidths: const {0: IntrinsicColumnWidth()},
                            children: [
                              _headerRow(context, rounds),
                              _totalsRow(context, totals, winningValue),
                              if (!widget.round.completed)
                                widget.round.gameBlockId == 'damjagen'
                                    ? _damjagenDraftRow(
                                        context, rounds.length + 1)
                                    : _draftRow(context, rounds.length + 1),
                              ...rounds.map(
                                (round) => _roundRow(
                                  context,
                                  round,
                                  !widget.round.completed &&
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
          ],
        ),
      ),
    );
  }

  Widget _buildTallyPage(BuildContext context) {
    final tallyGames = widget.controller.games
        .where((game) => game.roundId == widget.round.id)
        .toList()
      ..sort((first, second) => second.playedAt.compareTo(first.playedAt));
    final counts = {
      for (final playerId in widget.round.playerIds)
        playerId: tallyGames.fold<int>(
            0, (sum, game) => sum + (game.scores[playerId] ?? 0)),
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.name),
        actions: [
          if (!widget.round.completed)
            IconButton(
              tooltip: 'Neue Runde',
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: _newRound,
            ),
          IconButton(
            tooltip: 'Spielerreihenfolge ändern',
            icon: const Icon(Icons.swap_vert_rounded),
            onPressed: _reorderPlayers,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth - 24),
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
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    TableRow(
                      children: [
                        _tableCell(context, const SizedBox.shrink()),
                        ...widget.round.playerIds.map(
                          (id) => _tableCell(
                            context,
                            _playerHeader(
                              context,
                              id,
                              widget.round.completed
                                  ? tallyGames.isEmpty
                                      ? null
                                      : _dealerForGame(
                                          tallyGames.first,
                                          tallyGames,
                                        )
                                  : _dealerForDraft(tallyGames),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        _tableCell(context, const Text('Σ'), bold: true),
                        ...widget.round.playerIds.map(
                          (id) => _tableCell(
                            context,
                            Text(
                              '${counts[id] ?? 0}',
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        _tableCell(context, const SizedBox.shrink()),
                        ...widget.round.playerIds.map(
                          (id) => _tableCell(
                            context,
                            IconButton(
                              tooltip: 'Strich hinzufügen',
                              icon: const Icon(
                                Icons.add_rounded,
                                color: Colors.orange,
                              ),
                              onPressed: widget.round.completed
                                  ? null
                                  : () => _addTallyMark(id),
                              onLongPress: widget.round.completed
                                  ? null
                                  : () => _removeTallyMark(id),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiceBlockPage(BuildContext context) {
    final categoryGames = widget.controller.games
        .where(
          (game) => game.roundId == widget.round.id && game.categoryId != null,
        )
        .toList();
    final completedScores = <String, Map<String, int>>{
      for (final category in diceBlockCategories)
        category: {
          for (final game in categoryGames)
            if (game.categoryId == category && !game.crossedOut) ...game.scores,
        },
    };
    final crossedOutScores = <String, Set<String>>{
      for (final category in diceBlockCategories)
        category: {
          for (final game in categoryGames)
            if (game.categoryId == category && game.crossedOut)
              ...game.scores.keys,
        },
    };
    int upperTotalFor(String playerId) => _diceUpperCategories.fold<int>(
          0,
          (sum, category) =>
              sum +
              (completedScores[category]?[playerId] ??
                  int.tryParse(
                    diceControllers['$category:$playerId']?.text.trim() ?? '',
                  ) ??
                  0),
        );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.name),
        actions: [
          if (!widget.round.completed)
            IconButton(
              tooltip: 'Neue Runde',
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: _newRound,
            ),
          IconButton(
            tooltip: 'Spielerreihenfolge ändern',
            icon: const Icon(Icons.swap_vert_rounded),
            onPressed: _reorderPlayers,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth - 24),
              child: Align(
                alignment: Alignment.topCenter,
                child: Table(
                  border: TableBorder.all(
                    color: Theme.of(context).dividerColor,
                    width: .6,
                  ),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    TableRow(
                      children: [
                        _tableCell(context, const SizedBox.shrink()),
                        ...widget.round.playerIds.map(
                          (id) => _tableCell(
                              context, _playerHeader(context, id, null)),
                        ),
                      ],
                    ),
                    for (final category in diceBlockCategories) ...[
                      if (category == 'Dreierpasch')
                        TableRow(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                              bottom: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 3,
                              ),
                            ),
                          ),
                          children: [
                            _tableCell(
                              context,
                              const Text(
                                'Bonus (über 63)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ...widget.round.playerIds.map((playerId) {
                              final bonus =
                                  upperTotalFor(playerId) > 63 ? 35 : 0;
                              return _tableCell(
                                context,
                                Text(
                                  bonus == 0 ? '' : '$bonus',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      TableRow(
                        children: [
                          _tableCell(
                            context,
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(diceBlockCategoryIcons[category],
                                    size: 20),
                                const SizedBox(width: 6),
                                Text(category),
                              ],
                            ),
                          ),
                          ...widget.round.playerIds.map((playerId) {
                            final value = completedScores[category]?[playerId];
                            final crossedOut = crossedOutScores[category]
                                    ?.contains(playerId) ??
                                false;
                            return _tableCell(
                              context,
                              GestureDetector(
                                onTap: crossedOut || value != null
                                    ? () => _removeDiceScore(
                                          category,
                                          playerId,
                                        )
                                    : null,
                                onLongPress: crossedOut
                                    ? null
                                    : () => _crossOutDiceField(
                                          category,
                                          playerId,
                                        ),
                                child: crossedOut
                                    ? const Text(
                                        '---',
                                        style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      )
                                    : value != null
                                        ? _diceFixedScore(category) != null
                                            ? const Checkbox(
                                                value: true,
                                                onChanged: null,
                                              )
                                            : Text(
                                                value.toString(),
                                                textAlign: TextAlign.center,
                                              )
                                        : _diceFixedScore(category) != null
                                            ? Checkbox(
                                                value: false,
                                                onChanged: (checked) {
                                                  if (checked == true) {
                                                    _recordDiceFixedScore(
                                                      category,
                                                      playerId,
                                                    );
                                                  }
                                                },
                                              )
                                            : _scoreField(
                                                diceControllers,
                                                '$category:$playerId',
                                                onChanged: (value) =>
                                                    _handleDiceInputChanged(
                                                  category,
                                                  playerId,
                                                  value,
                                                ),
                                                onComplete: () =>
                                                    _recordDiceScore(
                                                  category,
                                                  playerId,
                                                ),
                                              ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                    TableRow(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                        ),
                      ),
                      children: [
                        _tableCell(context, const Text('Summe'), bold: true),
                        ...widget.round.playerIds.map((playerId) {
                          final savedTotal = categoryGames.fold<int>(
                            0,
                            (sum, game) => sum + (game.scores[playerId] ?? 0),
                          );
                          final draftTotal = diceBlockCategories.fold<int>(
                            0,
                            (sum, category) =>
                                sum +
                                (int.tryParse(
                                      diceControllers['$category:$playerId']
                                              ?.text
                                              .trim() ??
                                          '',
                                    ) ??
                                    0),
                          );
                          final bonus = upperTotalFor(playerId) > 63 ? 35 : 0;
                          return _tableCell(
                            context,
                            Text(
                              '${savedTotal + draftTotal + bonus}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _recordDiceScore(String category, String playerId) async {
    final controller = diceControllers['$category:$playerId'];
    final value = int.tryParse(controller?.text.trim() ?? '');
    if (value == null || value < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte eine Punktzahl ab 0 eingeben.')),
      );
      return;
    }
    final maximum = _diceCategoryMaximum(category);
    if (!_isValidDiceScore(category, value)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Für $category sind maximal $maximum Punkte möglich.'),
        ),
      );
      return;
    }
    await widget.controller.addGame(
      GameRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        roundId: widget.round.id,
        sessionId: widget.session.id,
        gameBlockId: widget.round.gameBlockId,
        playerIds: widget.round.playerIds,
        scores: {playerId: value},
        playedAt: DateTime.now(),
        categoryId: category,
      ),
    );
    controller?.clear();
    if (mounted) setState(() {});
  }

  Future<void> _recordDiceFixedScore(String category, String playerId) async {
    final value = _diceFixedScore(category);
    if (value == null) return;
    await widget.controller.addGame(
      GameRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        roundId: widget.round.id,
        sessionId: widget.session.id,
        gameBlockId: widget.round.gameBlockId,
        playerIds: widget.round.playerIds,
        scores: {playerId: value},
        playedAt: DateTime.now(),
        categoryId: category,
      ),
    );
    if (mounted) setState(() {});
  }

  GameRecord? _diceGameFor(String category, String playerId) {
    for (final game in widget.controller.games) {
      if (game.roundId == widget.round.id &&
          game.categoryId == category &&
          game.scores.containsKey(playerId)) {
        return game;
      }
    }
    return null;
  }

  Future<void> _removeDiceScore(String category, String playerId) async {
    final game = _diceGameFor(category, playerId);
    if (game == null) return;
    await widget.controller.deleteGame(game.id);
    if (mounted) setState(() {});
  }

  Future<void> _crossOutDiceField(String category, String playerId) async {
    if (_diceGameFor(category, playerId) != null) {
      await _removeDiceScore(category, playerId);
    }
    diceControllers['$category:$playerId']?.clear();
    await widget.controller.addGame(
      GameRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        roundId: widget.round.id,
        sessionId: widget.session.id,
        gameBlockId: widget.round.gameBlockId,
        playerIds: widget.round.playerIds,
        scores: {playerId: 0},
        playedAt: DateTime.now(),
        categoryId: category,
        crossedOut: true,
      ),
    );
    if (mounted) setState(() {});
  }

  void _handleDiceInputChanged(
    String category,
    String playerId,
    String value,
  ) {
    final score = int.tryParse(value.trim());
    if (score == null) return;
    final maximum = _diceCategoryMaximum(category);
    if (!_isValidDiceScore(category, score)) {
      diceControllers['$category:$playerId']?.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Für $category sind maximal $maximum Punkte möglich.'),
        ),
      );
    }
    setState(() {});
  }

  static const _diceUpperCategories = [
    'Einser',
    'Zweier',
    'Dreier',
    'Vierer',
    'Fünfer',
    'Sechser',
  ];

  int _diceCategoryMaximum(String category) {
    final upperIndex = _diceUpperCategories.indexOf(category);
    if (upperIndex >= 0) return (upperIndex + 1) * 5;
    if (category == 'Full House') return 25;
    if (category == 'Kleine Straße') return 30;
    if (category == 'Große Straße') return 40;
    if (category == '5er Pasch') return 50;
    return 30;
  }

  int? _diceFixedScore(String category) {
    if (category == 'Full House') return 25;
    if (category == 'Kleine Straße') return 30;
    if (category == 'Große Straße') return 40;
    if (category == '5er Pasch') return 50;
    return null;
  }

  bool _isValidDiceScore(String category, int score) {
    final upperIndex = _diceUpperCategories.indexOf(category);
    if (upperIndex >= 0 && score % (upperIndex + 1) != 0) return false;
    final fixedScore = _diceFixedScore(category);
    return score <= _diceCategoryMaximum(category) &&
        (fixedScore == null || score == fixedScore);
  }

  Future<void> _addTallyMark(String playerId) async {
    await widget.controller.addGame(
      GameRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        roundId: widget.round.id,
        sessionId: widget.session.id,
        gameBlockId: widget.round.gameBlockId,
        playerIds: widget.round.playerIds,
        scores: {playerId: 1},
        playedAt: DateTime.now(),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _removeTallyMark(String playerId) async {
    final lastMark = widget.controller.games
        .where(
      (game) =>
          game.roundId == widget.round.id &&
          game.gameBlockId == 'tally' &&
          game.scores[playerId] == 1,
    )
        .fold<GameRecord?>(null, (latest, game) {
      if (latest == null || game.playedAt.isAfter(latest.playedAt)) {
        return game;
      }
      return latest;
    });
    if (lastMark == null) return;
    await widget.controller.deleteGame(lastMark.id);
    if (mounted) setState(() {});
  }

  TableRow _headerRow(
    BuildContext context,
    List<GameRecord> rounds,
  ) =>
      TableRow(
        children: [
          _tableCell(context, const SizedBox.shrink(), bold: true),
          ...widget.round.playerIds.map((id) => _tableCell(
                context,
                _playerHeader(
                  context,
                  id,
                  widget.round.completed
                      ? rounds.isEmpty
                          ? null
                          : _dealerForGame(rounds.first, rounds)
                      : _dealerForDraft(rounds),
                ),
              )),
        ],
      );

  Widget _playerHeader(BuildContext context, String id, String? dealerId) {
    final player = widget.controller.playerById(id);
    final name = player?.name.isNotEmpty == true ? player!.name : 'Unbekannt';
    final primary = player?.primaryColorValue == null
        ? Theme.of(context).colorScheme.primary
        : Color(player!.primaryColorValue!);
    final secondary = player?.secondaryColorValue == null
        ? (primary.computeLuminance() > .5 ? Colors.black : Colors.white)
        : Color(player!.secondaryColorValue!);
    final isDealer = id == dealerId;
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isDealer
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    )
                  : null,
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: primary,
              child: Text(
                name.characters.first.toUpperCase(),
                style: TextStyle(
                  color: secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          if (isDealer)
            Text(
              'Dran',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
            ),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                ),
          ),
        ],
      ),
    );
  }

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
              _scoreField(
                draftControllers,
                id,
                onChanged: (_) => setState(() {}),
                onCommit: () => setState(
                  () => committedDraftPlayerIds.add(id),
                ),
                onComplete: () => _recordRound(roundNumber),
                onNextEmpty: () => _advanceAfterEnter(id, roundNumber),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      );

  TableRow _roundRow(
    BuildContext context,
    GameRecord round,
    bool isLatest,
  ) =>
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
    bool enabled = true,
    ValueChanged<String>? onChanged,
    VoidCallback? onCommit,
    VoidCallback? onComplete,
    VoidCallback? onNextEmpty,
  }) {
    final controller = controllers.putIfAbsent(
      key,
      () => TextEditingController(text: value == null ? '' : '$value'),
    );
    final focusNode = calculatorFocusNodes.putIfAbsent(key, FocusNode.new);
    return _CalculatorField(
      controller: controller,
      focusNode: focusNode,
      onOpenChanged: (open) => calculatorOpeners[key] = open,
      allowNegative: widget.session.gameBlockId != 'ten_thousand',
      enabled: enabled,
      onChanged: onChanged,
      onCommit: onCommit,
      onComplete: onComplete,
      onNextEmpty: onNextEmpty,
    );
  }

  void _focusNextField(String currentId) {
    final currentIndex = widget.round.playerIds.indexOf(currentId);
    final nextIndex = (currentIndex + 1) % widget.round.playerIds.length;
    final nextId = widget.round.playerIds[nextIndex];
    FocusScope.of(context).requestFocus(calculatorFocusNodes[nextId]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) calculatorOpeners[nextId]?.call();
    });
  }

  Future<void> _advanceAfterEnter(String currentId, int roundNumber) async {
    final currentIndex = widget.round.playerIds.indexOf(currentId);
    if (currentIndex == widget.round.playerIds.length - 1) {
      await _recordRound(roundNumber);
      if (!mounted || widget.round.playerIds.isEmpty) return;
      final firstPlayerId = widget.round.playerIds.first;
      FocusScope.of(context).requestFocus(
        calculatorFocusNodes[firstPlayerId],
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) calculatorOpeners[firstPlayerId]?.call();
      });
      return;
    }
    _focusNextField(currentId);
  }

  String _roundNumber(GameRecord round) {
    final rounds = widget.controller.games
        .where((game) => game.roundId == widget.round.id)
        .toList()
      ..sort((first, second) => first.playedAt.compareTo(second.playedAt));
    return '${rounds.indexOf(round) + 1}';
  }

  Future<void> _recordRound(int roundNumber) async {
    final rounds = widget.controller.games
        .where((game) => game.roundId == widget.round.id)
        .toList();
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
    if (_currentRound.dealerAdvancesOnScore) {
      dealerAfterDraft = _dealerForDraft(rounds);
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
    committedDraftPlayerIds.clear();
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

  Map<String, int> _damjagenScoresForDisplay(Map<String, int> baseScores) {
    final maxPoints = widget.session.maxPoints;
    final hasCompleteValidSum =
        baseScores.length == widget.round.playerIds.length &&
            baseScores.values.fold<int>(0, (sum, score) => sum + score) ==
                maxPoints;
    if (!hasCompleteValidSum) return baseScores;
    final multiplier = math.pow(2, virginPlayers.length).toInt();
    return {
      for (final id in widget.round.playerIds)
        id: throughMarchPlayer != null && id != throughMarchPlayer
            ? maxPoints
            : virginPlayers.contains(id)
                ? 0
                : baseScores[id]! * multiplier,
    };
  }

  TableRow _damjagenDraftRow(BuildContext context, int roundNumber) => TableRow(
        children: [
          _tableCell(
            context,
            IconButton(
              tooltip: 'Runde $roundNumber aufzeichnen',
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _recordDamjagenRound(roundNumber),
            ),
            padding: EdgeInsets.zero,
          ),
          ...widget.round.playerIds.map(
            (id) => _tableCell(
              context,
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _specialButton(
                        context,
                        label: 'J',
                        selected: virginPlayers.contains(id),
                        onPressed: () => _toggleVirgin(id),
                      ),
                      _specialButton(
                        context,
                        label: 'D',
                        selected: throughMarchPlayer == id,
                        onPressed: () => _toggleThroughMarch(id),
                      ),
                    ],
                  ),
                  _scoreField(
                    draftControllers,
                    id,
                    enabled: !virginPlayers.contains(id) &&
                        throughMarchPlayer == null,
                    onChanged: (_) => setState(() {}),
                    onComplete: () => _recordDamjagenRound(roundNumber),
                    onNextEmpty: () => _focusNextField(id),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      );

  Widget _specialButton(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) =>
      TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          foregroundColor: selected ? Colors.red : Colors.orange,
          backgroundColor: Colors.transparent,
        ),
        child: Text(label),
      );

  void _toggleVirgin(String playerId) {
    if (virginPlayers.contains(playerId)) {
      setState(() => virginPlayers.remove(playerId));
      return;
    }
    if (virginPlayers.length >= widget.round.playerIds.length - 2) {
      _showDamjagenError(
          'Es sind höchstens Spieleranzahl minus 2 Jungfrauen erlaubt.');
      return;
    }
    if (throughMarchPlayer == playerId) {
      throughMarchPlayer = null;
    }
    draftControllers[playerId]?.clear();
    setState(() => virginPlayers.add(playerId));
  }

  void _toggleThroughMarch(String playerId) {
    setState(() {
      if (throughMarchPlayer == playerId) {
        throughMarchPlayer = null;
        return;
      }
      throughMarchPlayer = playerId;
      virginPlayers.clear();
      for (final controller in draftControllers.values) {
        controller.clear();
      }
    });
  }

  Future<void> _recordDamjagenRound(int roundNumber) async {
    final maxPoints = widget.session.maxPoints;
    if (maxPoints < 1) {
      _showDamjagenError('Bitte eine gültige Maximalpunktzahl angeben.');
      return;
    }
    final baseScores = <String, int>{};
    for (final id in widget.round.playerIds) {
      final score = int.tryParse(draftControllers[id]?.text.trim() ?? '') ?? 0;
      if (score < 0) {
        _showDamjagenError('Bitte nur Werte ab 0 eingeben.');
        return;
      }
      baseScores[id] = score;
    }
    if (throughMarchPlayer == null &&
        baseScores.values.fold<int>(0, (sum, score) => sum + score) !=
            maxPoints) {
      _showDamjagenError(
        'Die eingegebenen Werte müssen zusammen $maxPoints ergeben.',
      );
      return;
    }
    final multiplier = math.pow(2, virginPlayers.length).toInt();
    final scores = {
      for (final id in widget.round.playerIds)
        id: throughMarchPlayer != null && id != throughMarchPlayer
            ? maxPoints
            : virginPlayers.contains(id)
                ? 0
                : (baseScores[id]! * multiplier),
    };
    await widget.controller.updateGameRoundMaxPoints(
      widget.round.id,
      maxPoints,
    );
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
    setState(() {
      virginPlayers.clear();
      throughMarchPlayer = null;
    });
  }

  void _showDamjagenError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
  DateTime? statisticsDate;

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
              _statistics(context),
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

  Widget _statistics(BuildContext context) {
    final playerId = widget.player!.id;
    final allRounds = widget.controller.gameRounds
        .where((round) => round.playerIds.contains(playerId))
        .toList();
    final rounds = statisticsDate == null
        ? allRounds
        : allRounds
            .where(
                (round) => _isSameDate(_lastPlayedAt(round), statisticsDate!))
            .toList();
    final completedRounds = rounds.where((round) => round.completed).toList();
    final wins = completedRounds
        .where((round) =>
            round.winnerPlayerIds.length == 1 &&
            round.winnerPlayerIds.contains(playerId))
        .length;
    final draws = completedRounds
        .where((round) =>
            round.winnerPlayerIds.length > 1 &&
            round.winnerPlayerIds.contains(playerId))
        .length;
    final losses = completedRounds
        .where(
          (round) =>
              !round.winnerPlayerIds.contains(playerId) &&
              round.winnerPlayerIds.isNotEmpty,
        )
        .length;
    final opponentIds = <String>{
      for (final round in rounds)
        ...round.playerIds.where((id) => id != playerId),
    }.toList();
    opponentIds.sort((first, second) => _playerName(first).compareTo(
          _playerName(second),
        ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today_outlined),
          title: Text(
            statisticsDate == null
                ? 'Alle Tage'
                : 'Tag: ${_formatDate(statisticsDate!)}',
          ),
          subtitle: const Text('Statistikdatum auswählen'),
          trailing: statisticsDate == null
              ? null
              : IconButton(
                  tooltip: 'Datum zurücksetzen',
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () => setState(() => statisticsDate = null),
                ),
          onTap: _selectStatisticsDate,
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.emoji_events_outlined),
          title: Text(statisticsDate == null ? 'Gesamt' : 'Ausgewählter Tag'),
          subtitle: Text(
            '${rounds.length} Spiele • '
            '${rounds.where((round) => !round.completed).length} offen • '
            '$wins Siege • $draws Unentschieden • $losses Niederlagen',
          ),
        ),
        if (opponentIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Gegen Gegenspieler'),
          ...opponentIds.map(
            (opponentId) => _opponentStatistics(
              opponentId,
              rounds,
            ),
          ),
        ],
        if (rounds.isEmpty) const Text('Noch keine Spiele.'),
      ],
    );
  }

  Future<void> _selectStatisticsDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: statisticsDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selected != null && mounted) {
      setState(() => statisticsDate = selected);
    }
  }

  DateTime _lastPlayedAt(GameRound round) {
    final playedAt = widget.controller.games
        .where((game) => game.roundId == round.id)
        .map((game) => game.playedAt)
        .toList();
    if (playedAt.isEmpty) return round.createdAt;
    return playedAt.reduce(
      (first, second) => first.isAfter(second) ? first : second,
    );
  }

  bool _isSameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  String _formatDate(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(value.day)}.${twoDigits(value.month)}.${value.year}';
  }

  Widget _opponentStatistics(
    String opponentId,
    List<GameRound> rounds,
  ) {
    var wins = 0;
    var losses = 0;
    var draws = 0;
    final opponentRounds = rounds
        .where(
          (round) => round.playerIds.contains(opponentId),
        )
        .toList();
    for (final round in opponentRounds.where((round) => round.completed)) {
      final playerWon = round.winnerPlayerIds.contains(widget.player!.id);
      final opponentWon = round.winnerPlayerIds.contains(opponentId);
      if (playerWon && !opponentWon && round.winnerPlayerIds.length == 1) {
        wins++;
      }
      if (opponentWon && !playerWon && round.winnerPlayerIds.length == 1) {
        losses++;
      }
      if (playerWon && opponentWon) draws++;
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.person_outline_rounded),
      title: Text(_playerName(opponentId)),
      subtitle: Text(
        '${opponentRounds.length} Spiele • '
        '${opponentRounds.where((round) => !round.completed).length} offen • '
        '$wins Siege • $draws Unentschieden • $losses Niederlagen',
      ),
    );
  }

  String _playerName(String id) =>
      widget.controller.playerById(id)?.name.isNotEmpty == true
          ? widget.controller.playerById(id)!.name
          : 'Unbekannt';

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
    this.focusNode,
    this.onOpenChanged,
    this.onChanged,
    this.onCommit,
    this.onComplete,
    this.onNextEmpty,
    this.allowNegative = true,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<VoidCallback>? onOpenChanged;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCommit;
  final VoidCallback? onComplete;
  final VoidCallback? onNextEmpty;
  final bool allowNegative;
  final bool enabled;

  @override
  State<_CalculatorField> createState() => _CalculatorFieldState();
}

class _CalculatorFieldState extends State<_CalculatorField> {
  bool calculatorOpen = false;

  @override
  void initState() {
    super.initState();
    widget.onOpenChanged?.call(_openCalculator);
  }

  @override
  void didUpdateWidget(covariant _CalculatorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.onOpenChanged?.call(_openCalculator);
  }

  Future<void> _openCalculator() async {
    if (mounted) setState(() => calculatorOpen = true);
    var expression = widget.controller.text;
    var expressionChanged = false;
    var completeAfterClose = false;
    var nextEmptyAfterClose = false;
    final mediaQuery = MediaQuery.of(context);
    final availableHeight = math.max(0.0, mediaQuery.size.height - 200.0);
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
            expressionChanged = true;
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
          onComplete: () => completeAfterClose = true,
          onNextEmpty: () => nextEmptyAfterClose = true,
        ),
      ),
    );
    if (mounted) setState(() => calculatorOpen = false);
    if (result == null) {
      if (expressionChanged && _calculateExpression(expression) != null) {
        widget.onCommit?.call();
      }
      return;
    }
    widget.controller.value = TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
    widget.onChanged?.call(result);
    if (expressionChanged) widget.onCommit?.call();
    if (completeAfterClose) widget.onComplete?.call();
    if (nextEmptyAfterClose) widget.onNextEmpty?.call();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        readOnly: true,
        showCursor: false,
        textAlign: TextAlign.center,
        onTap: widget.enabled ? _openCalculator : null,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          filled: calculatorOpen,
          fillColor: Theme.of(context).colorScheme.secondaryContainer,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      );
}

class _CalculatorPad extends StatefulWidget {
  const _CalculatorPad({
    required this.initialExpression,
    required this.allowNegative,
    required this.onExpressionChanged,
    this.onComplete,
    this.onNextEmpty,
  });

  final String initialExpression;
  final bool allowNegative;
  final ValueChanged<String> onExpressionChanged;
  final VoidCallback? onComplete;
  final VoidCallback? onNextEmpty;

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
      } else if (value == '( )') {
        final opening = '('.allMatches(expression).length;
        final closing = ')'.allMatches(expression).length;
        expression += opening > closing ? ')' : '(';
      } else {
        expression += value;
      }
      widget.onExpressionChanged(expression);
    });
  }

  void _calculate({bool complete = false, bool nextEmpty = false}) {
    final result = _calculateExpression(expression);
    if (result == null) return;
    if (complete) widget.onComplete?.call();
    if (nextEmpty) widget.onNextEmpty?.call();
    Navigator.pop(context, _formatCalculatorValue(result));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final highlight = Theme.of(context).iconTheme.color ?? colors.secondary;
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
      ('⌫', colors.surfaceContainerHighest, colors.onSurface),
      ('0', colors.surfaceContainerHighest, colors.onSurface),
      ('+', colors.secondary, colors.onSecondary),
      ('↵', highlight, Colors.black),
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
              itemCount: 16,
              itemBuilder: (context, index) =>
                  _buildButton(buttons[index], isComplete: false),
            ),
            const SizedBox(height: 2),
            LayoutBuilder(
              builder: (context, constraints) {
                final buttonSize =
                    math.max(0.0, (constraints.maxWidth - 6) / 4);
                return SizedBox(
                  height: buttonSize,
                  child: Row(
                    children: [
                      SizedBox(
                        width: buttonSize / 2,
                        height: buttonSize / 2,
                        child: _buildButton(buttons[16], isComplete: false),
                      ),
                      const SizedBox(width: 2),
                      SizedBox(
                        width: buttonSize * 2,
                        height: buttonSize,
                        child: _buildButton(
                          buttons[17],
                          isComplete: false,
                          shape: const StadiumBorder(),
                        ),
                      ),
                      const SizedBox(width: 2),
                      SizedBox(
                        width: buttonSize / 2,
                        height: buttonSize / 2,
                        child: _buildButton(buttons[18], isComplete: true),
                      ),
                      const SizedBox(width: 2),
                      SizedBox(
                        width: buttonSize,
                        height: buttonSize,
                        child: _buildButton(buttons[19], isComplete: false),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    (String, Color, Color) button, {
    required bool isComplete,
    OutlinedBorder shape = const CircleBorder(),
  }) {
    return _CalculatorButton(
      label: button.$1,
      backgroundColor: button.$2,
      foregroundColor: button.$3,
      shape: shape,
      onPressed: button.$1 == '↵'
          ? () => _calculate(nextEmpty: true)
          : isComplete
              ? () => _calculate(complete: true)
              : () => _press(button.$1),
      child: button.$1 == '↵'
          ? const Icon(Icons.keyboard_return_rounded, size: 22)
          : isComplete
              ? const Icon(Icons.add_circle_outline_rounded, size: 22)
              : button.$1 == '⌫'
                  ? const Icon(Icons.backspace_outlined, size: 18)
                  : Text(button.$1, style: const TextStyle(fontSize: 18)),
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
    required this.shape,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final Widget child;
  final OutlinedBorder shape;

  @override
  Widget build(BuildContext context) => FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: shape,
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

  int _gameCount(Player player) => widget.controller.gameRounds
      .where((round) => round.playerIds.contains(player.id))
      .length;
}

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String selectedSessionId = '';

  @override
  Widget build(BuildContext context) {
    final sessions = widget.controller.gameSessions.toList()
      ..sort((first, second) => first.name.compareTo(second.name));
    final filteredGames = selectedSessionId.isEmpty
        ? widget.controller.games
        : widget.controller.games.where(
            (game) => game.sessionId == selectedSessionId,
          );
    final totals = {
      for (final player in widget.controller.players)
        player.id: filteredGames.fold<int>(
          0,
          (sum, game) => sum + (game.scores[player.id] ?? 0),
        ),
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedSessionId,
            decoration: const InputDecoration(
              labelText: 'Spiel filtern',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: '',
                child: Text('Alle Spiele'),
              ),
              ...sessions.map(
                (session) => DropdownMenuItem(
                  value: session.id,
                  child: Text(session.name),
                ),
              ),
            ],
            onChanged: (value) =>
                setState(() => selectedSessionId = value ?? ''),
          ),
          const SizedBox(height: 16),
          Text(
            selectedSessionId.isEmpty
                ? 'Alle Spieler'
                : sessions
                        .where((session) => session.id == selectedSessionId)
                        .map((session) => session.name)
                        .firstOrNull ??
                    'Spielstatistik',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Gesammelte Punkte für die gewählte Spielauswahl.'),
          const SizedBox(height: 16),
          ...widget.controller.players.map(
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
          if (widget.controller.players.isEmpty)
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
