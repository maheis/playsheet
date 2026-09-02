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
            onPressed: () =>
                pushPage(context, SettingsPage(controller: settingsController)),
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
                  onTap: () =>
                      pushPage(context, PlayersPage(controller: controller)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 1,
      mainAxisSpacing: 12,
      mainAxisExtent: 72,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });
  final IconData icon;
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
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                secondary: Icon(item.icon, color: item.color),
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
            onPressed: () =>
                pushPage(context, AddPlayerPage(controller: widget.controller)),
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

  bool get isEditing => widget.player != null;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.player?.name ?? '');
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(isEditing ? 'Spieler bearbeiten' : 'Spieler anlegen'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Spieler können in jedem Spiel wiederverwendet werden.'),
          const SizedBox(height: 20),
          TextField(
            controller: name,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_rounded),
            label: Text(
              isEditing ? 'Änderungen speichern' : 'Spieler speichern',
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _save() async {
    final playerName = name.text.trim();
    if (playerName.isEmpty) return;
    if (isEditing) {
      await widget.controller.updatePlayer(widget.player!.id, playerName);
    } else {
      await widget.controller.addPlayer(playerName);
    }
    if (mounted) Navigator.pop(context);
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
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.block.name),
      actions: [
        IconButton(
          tooltip: 'Runde speichern',
          icon: const Icon(Icons.save_rounded),
          onPressed: _save,
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Runde 1',
          style: Theme.of(context).textTheme.headlineSmall
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
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Punkte'),
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
  void _save() async {
    await widget.controller.addGame(
      GameRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        gameBlockId: widget.block.id,
        playerIds: widget.playerIds,
        scores: scores,
        playedAt: DateTime.now(),
      ),
    );
    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }
}

class PlayersPage extends StatelessWidget {
  const PlayersPage({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = [...controller.players]
      ..sort((first, second) {
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
            onTap: () =>
                pushPage(context, AddPlayerPage(controller: controller)),
          ),
          const SizedBox(height: 12),
          ...sortedPlayers.map(
            (player) => Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(player.id)),
                title: Text(player.name),
                subtitle: Text('${_gameCount(player)} Spiele'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Spieler bearbeiten',
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () => pushPage(
                        context,
                        AddPlayerPage(controller: controller, player: player),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Spieler löschen',
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => _confirmDelete(context, player),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _gameCount(Player player) => controller.games
      .where((game) => game.playerIds.contains(player.id))
      .length;

  Future<void> _confirmDelete(BuildContext context, Player player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Spieler löschen?'),
        content: Text('„${player.name}“ wirklich löschen?'),
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
    if (confirmed == true) await controller.deletePlayer(player.id);
  }
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
            style: Theme.of(context).textTheme.headlineSmall
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

  bool get _hasChanges {
    final current = widget.controller.settings;
    return draft.fontFamily != current.fontFamily ||
        draft.textScaleFactor != current.textScaleFactor ||
        draft.useLightTheme != current.useLightTheme ||
        draft.accentColorValue != current.accentColorValue ||
        draft.highlightColorValue != current.highlightColorValue;
  }

  @override
  void initState() {
    super.initState();
    draft = widget.controller.settings;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Einstellungen'),
      actions: [
        TextButton(
          onPressed: _save,
          child: Text(
            'Speichern',
            style: TextStyle(
              color: _hasChanges
                  ? Theme.of(context).colorScheme.secondary
                  : null,
              fontWeight: _hasChanges ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Darstellung',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: draft.fontFamily,
          decoration: const InputDecoration(
            labelText: 'Schriftart',
            border: OutlineInputBorder(),
          ),
          items:
              [
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
              setState(() => draft = draft.copyWith(fontFamily: value)),
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
              setState(() => draft = draft.copyWith(textScaleFactor: value)),
        ),
        SwitchListTile(
          title: const Text('Helles Theme'),
          value: draft.useLightTheme,
          onChanged: (value) =>
              setState(() => draft = draft.copyWith(useLightTheme: value)),
        ),
        _ColorDropdown(
          label: 'Akzentfarbe',
          value: draft.accentColorValue,
          onChanged: (value) =>
              setState(() => draft = draft.copyWith(accentColorValue: value)),
        ),
        _ColorDropdown(
          label: 'Highlight-Farbe',
          value: draft.highlightColorValue,
          onChanged: (value) => setState(
            () => draft = draft.copyWith(highlightColorValue: value),
          ),
        ),
      ],
    ),
  );

  Future<void> _save() async {
    await widget.controller.update(draft);
    if (mounted) Navigator.pop(context);
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
        for (var index = 0; index < AppSettings.availableColors.length; index++)
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
