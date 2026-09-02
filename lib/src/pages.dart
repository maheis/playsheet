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
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Dein Spielblock',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ergebnisse festhalten. Spieler wiederverwenden. Statistiken entdecken.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () =>
                pushPage(context, NewGamePage(controller: controller)),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Neues Spiel starten'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Summary(
                  label: 'Spieler',
                  value: '${controller.players.length}',
                  icon: Icons.people_alt_rounded,
                  onTap: () =>
                      pushPage(context, PlayersPage(controller: controller)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Summary(
                  label: 'Spiele',
                  value: '${controller.games.length}',
                  icon: Icons.sports_score_rounded,
                  onTap: () =>
                      pushPage(context, StatisticsPage(controller: controller)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const _SectionTitle('Spielblöcke'),
          ...gameBlocks.map(
            (block) => _GameBlockTile(
              block: block,
              onTap: () => pushPage(
                context,
                NewGamePage(controller: controller, initialBlock: block),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Auswertung'),
          ListTile(
            leading: const Icon(Icons.insights_rounded),
            title: const Text('Gesamtstatistik'),
            subtitle: const Text('Vergleiche Spieler und Spielverläufe'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () =>
                pushPage(context, StatisticsPage(controller: controller)),
          ),
        ],
      ),
    ),
  );
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });
  final String label, value;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(label),
          ],
        ),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}

class _GameBlockTile extends StatelessWidget {
  const _GameBlockTile({required this.block, required this.onTap});
  final GameBlockDefinition block;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: block.color,
        foregroundColor: Colors.black,
        child: Icon(block.icon),
      ),
      title: Text(block.name),
      subtitle: Text(block.description),
      trailing: const Icon(Icons.chevron_right_rounded),
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
  const AddPlayerPage({super.key, required this.controller});
  final AppController controller;
  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  final name = TextEditingController();
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Spieler anlegen')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ein Spieler bleibt eindeutig und kann in jedem Spiel wiederverwendet werden.',
          ),
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
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              await widget.controller.addPlayer(name.text.trim());
              if (mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.save_rounded),
            label: const Text('Spieler speichern'),
          ),
        ],
      ),
    ),
  );
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Spieler')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => pushPage(context, AddPlayerPage(controller: controller)),
      icon: const Icon(Icons.person_add_rounded),
      label: const Text('Spieler'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(12),
      children: controller.players
          .map(
            (player) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
              title: Text(player.name),
              subtitle: Text(
                '${controller.games.where((game) => game.playerIds.contains(player.id)).length} Spiele',
              ),
            ),
          )
          .toList(),
    ),
  );
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

  @override
  void initState() {
    super.initState();
    draft = widget.controller.settings;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Einstellungen')),
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
        SwitchListTile(
          title: const Text('Helles Theme'),
          value: draft.useLightTheme,
          onChanged: (value) =>
              setState(() => draft = draft.copyWith(useLightTheme: value)),
        ),
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
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () async {
            await widget.controller.update(draft);
            if (mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.save_rounded),
          label: const Text('Speichern'),
        ),
      ],
    ),
  );
}
