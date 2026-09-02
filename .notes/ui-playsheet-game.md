# UI-Spielvorlage: PlaySheet-Spielblock

Diese Vorlage beschreibt das Muster fuer ein neues Spiel innerhalb von PlaySheet. Sie trennt die globale App-Struktur, die Konfiguration einer Spielpartie und die einzelnen Spielrunden. Das Muster ist fuer weitere Spiele wie `Dam'jagen`, `10 Tausend`, `Kingdomino` oder eine Strichliste wiederverwendbar.

## 1. Grundidee

Ein Spiel wird in drei Ebenen aufgeteilt:

```text
GameBlockDefinition
    -> beschreibt das verfuegbare Spiel

GameSession
    -> beschreibt eine konkrete Partie mit Namen, Spielern und Regeln

GameRecord
    -> beschreibt eine gespeicherte Runde mit Punkten
```

Beispiel:

```text
Spielblock: 1 + 2 = 3
    Partie: Spieleabend
        Spieler: Anna, Ben, Chris
        Regel: Hoch gewinnt
        Runde 1: Punkte je Spieler
        Runde 2: Punkte je Spieler
```

Die Spielseite kennt nur den `AppController`. Sie greift nicht direkt auf Sembast, SharedPreferences oder andere Speicher-APIs zu.

## 2. Spielblock definieren

Jedes Spiel erhaelt einen stabilen technischen Identifier und sichtbare Metadaten:

```dart
const GameBlockDefinition(
  id: 'my_game',
  name: 'Mein Spiel',
  description: 'Kurze Beschreibung des Spielprinzips.',
  icon: Icons.sports_esports_rounded,
  color: Color(0xFF64B5F6),
)
```

Regeln fuer `GameBlockDefinition`:

- `id` bleibt nach dem ersten Release stabil.
- Der sichtbare Name darf spaeter geaendert werden.
- Beschreibung und Icon dienen der Auswahlseite und enthalten keine Spiellogik.
- Die eigentliche Spiellogik gehoert in die Konfigurations- und Rundenseiten des Spiels.
- Der neue Block wird in `gameBlocks` in `lib/src/models.dart` eingetragen.

## 3. Datenmodell

### 3.1 GameSession

`GameSession` ist die gespeicherte Konfiguration einer konkreten Partie.

| Feld | Typ | Bedeutung |
|---|---|---|
| `id` | `String` | Stabiler Identifier der Partie |
| `gameBlockId` | `String` | Verknuepfung zum Spielblock |
| `name` | `String` | Name der Partie, zum Beispiel `Spieleabend` |
| spielregeln | eigene Felder | Zum Beispiel `highWins`, Zielpunktzahl oder Modus |
| `playerIds` | `List<String>` | IDs der teilnehmenden Spieler |
| `createdAt` | `DateTime` | Zeitpunkt der Erstellung |

Spielregeln werden als typisierte Felder in `GameSession` abgelegt. Keine regelrelevanten Werte nur im Widget-State halten, wenn sie zum spaeteren Fortsetzen einer Partie benoetigt werden.

Beispiel fuer eine Regel:

```dart
final bool highWins;
```

Neue Spiele duerfen weitere, fachlich passende Felder ergaenzen, sollten aber das allgemeine Session-Muster beibehalten.

### 3.2 GameRecord

`GameRecord` repraesentiert eine einzelne gespeicherte Runde:

```dart
const GameRecord({
  required this.id,
  this.sessionId,
  required this.gameBlockId,
  required this.playerIds,
  required this.scores,
  required this.playedAt,
});
```

Bedeutung der Felder:

- `id`: eindeutige Rundennummer.
- `sessionId`: optionale Verknuepfung zur konkreten Partie; fuer neue Spiele immer setzen.
- `gameBlockId`: technische Zuordnung zum Spielblock.
- `playerIds`: Spielerreihenfolge dieser Runde.
- `scores`: Punkte je Spieler-ID.
- `playedAt`: Zeitpunkt der Runde.

Die Scores werden ueber Spieler-IDs und nicht ueber Spielernamen verknuepft. Namen koennen sich aendern, IDs bleiben stabil.

## 4. Persistenz

PlaySheet verwendet getrennte Sembast-Stores:

| Store | Inhalt |
|---|---|
| `players` | Spielerstammdaten |
| `game_sessions` | gespeicherte Partien und Konfigurationen |
| `games` | einzelne Runden und Punktstaende |

`AppRepository` bietet die Speichergrenzen:

```dart
Future<List<GameSession>> loadGameSessions();
Future<void> saveGameSessions(List<GameSession> sessions);
Future<List<GameRecord>> loadGames();
Future<void> saveGames(List<GameRecord> games);
```

Das Repository ist fuer Map-Konvertierung, Validierung und Migration zustaendig. Der Controller verwaltet den Laufzeitzustand und benachrichtigt die UI.

Beim Aendern einer Liste wird die gesamte aktuelle Liste in einer Sembast-Transaktion gespeichert. Dadurch bleiben die Stores einfach und der Speicherzustand entspricht dem Controllerzustand.

## 5. Controller-API

Neue Spielseiten verwenden diese Methoden:

```dart
Future<GameSession> addGameSession({
  required String gameBlockId,
  required String name,
  required bool highWins,
  required List<String> playerIds,
});

Future<void> updateGameSession(GameSession session);
Future<void> deleteGameSession(String id);
Future<void> addGame(GameRecord game);
Future<void> deleteGameRound(String id);
```

Verantwortlichkeiten:

- `addGameSession`: neue Partie erzeugen, speichern und an die UI melden.
- `updateGameSession`: bestehende Konfiguration sofort speichern.
- `deleteGameSession`: Partie und alle zugehoerigen Runden loeschen.
- `addGame`: eine neue Runde speichern.
- `deleteGameRound`: eine einzelne Runde loeschen.

Keine Seite darf die Listen `gameSessions` oder `games` direkt mutieren und anschliessend nur `setState` aufrufen.

## 6. Seitenfluss

Der Standardfluss fuer ein neues Spiel:

```text
Dashboard
    -> Spielblock auswaehlen

GameListPage
    -> vorhandene Partie oeffnen
    -> neue Partie ueber Plus-Aktion anlegen
    -> Partie mit Bestaetigung loeschen

GameSessionConfigPage
    -> Name, Regeln und Spieler erfassen
    -> jede gueltige Aenderung direkt speichern

GameRoundsPage
    -> gespeicherte Runden anzeigen
    -> neue Runde oeffnen
    -> einzelne Runde mit Bestaetigung loeschen

NewRoundPage
    -> Punkte erfassen
    -> Runde direkt speichern oder beim Abschluss speichern
```

Die Rundenliste filtert ueber `sessionId`:

```dart
final rounds = controller.games
    .where((game) => game.sessionId == session.id)
    .toList();
```

Beim Zurueckkehren von einer Unterseite wird die uebergeordnete Seite aktualisiert, damit neue oder geloeschte Runden sofort sichtbar sind.

## 7. Direkt-Speichern

PlaySheet verwendet fuer Spielkonfigurationen und globale Einstellungen kein separates Speichern-UI.

### Konfiguration

Jede relevante Aenderung ruft eine zentrale Methode wie `_persistConfiguration()` auf:

- Partie-Name: `TextField.onChanged`
- Regel-Auswahl: `RadioListTile.onChanged`
- Spieler hinzufuegen: nach Auswahl oder Neuanlage
- Spieler entfernen: `InputChip.onDeleted`

Gespeichert wird nur, wenn die Mindestdaten vorhanden sind:

```text
Name nicht leer
und mindestens ein Spieler ausgewaehlt
```

Vor dem ersten vollstaendigen Speichern existiert noch keine Session. Danach wird dieselbe Session mit `updateGameSession` aktualisiert. Die `createdAt`-Zeit und `id` bleiben dabei unveraendert.

Wichtig:

- Den Speichervorgang in einer Methode buendeln.
- Keine sichtbaren Speichern-Buttons fuer diese Konfiguration anbieten.
- Leere oder unvollstaendige Entwuerfe nicht als ungueltige Session persistieren.
- Asynchrone Schreibvorgaenge nach `await` nicht mehr auf `context` verwenden, ohne `mounted` zu pruefen.
- Bei vielen schnellen Eingaben kann spaeter ein Debounce ergaenzt werden; die Datenlogik bleibt unveraendert.

## 8. Spieler-Auswahl

Die Spielerkonfiguration verwendet ein Autocomplete-Feld:

- Vorhandene Spieler werden nach Namen gefiltert.
- Bereits ausgewaehlte Spieler erscheinen nicht erneut in den Vorschlaegen.
- Eine Auswahl wird als `InputChip` angezeigt.
- Nach der Auswahl wird das Eingabefeld geleert.
- Wird ein unbekannter Name abgeschickt, wird automatisch ein neuer Spieler angelegt.
- Die Spieler-ID wird intern verwendet; der sichtbare Name bleibt die UI-Darstellung.

Bei der Verwendung von Flutter `Autocomplete` muss der vom `fieldViewBuilder` gelieferte `TextEditingController` nach einer Auswahl geleert werden:

```dart
TextEditingController? playerNameFieldController;

fieldViewBuilder: (context, fieldController, focusNode, onSubmitted) {
  playerNameFieldController = fieldController;
  return TextField(
    controller: fieldController,
    focusNode: focusNode,
  );
}

onSelected: (player) {
  _addPlayer(player);
  playerNameFieldController?.clear();
}
```

## 9. Rundenerfassung

`NewRoundPage` erstellt einen `GameRecord` mit:

- der Session-ID der aktuellen Partie,
- der Spielerreihenfolge aus der Session,
- einem Score fuer jeden Spieler,
- dem aktuellen Zeitpunkt.

Vor dem Speichern pruefen:

- Ist die Session noch vorhanden?
- Gibt es fuer jeden Session-Spieler einen gueltigen Wert?
- Sind die Werte im erlaubten Bereich des Spiels?
- Ist die Rundennummer beziehungsweise Record-ID eindeutig?

Neue Rundendaten werden ueber `controller.addGame(record)` gespeichert. Die Rundenliste darf anschliessend nicht auf eine lokale Kopie als dauerhafte Quelle vertrauen, sondern liest aus `controller.games`.

## 10. Loeschen und Bestaetigungen

Destruktive Aktionen benoetigen eine klare Bestaetigung:

- Partie loeschen: Session und alle Runden mit derselben `sessionId` loeschen.
- Runde loeschen: nur den ausgewaehlten `GameRecord` loeschen.
- Spieler loeschen: bestehende Verknuepfungen und die UX-Folgen vorher festlegen.

Die Bestaetigung nennt konkret, welche Daten betroffen sind. Nach erfolgreichem Loeschen wird die betroffene Liste aus dem Controller neu gerendert.

## 11. Erweiterung fuer ein neues Spiel

1. Einen stabilen `gameBlockId` und eine `GameBlockDefinition` anlegen.
2. Die spieltypischen Session-Felder im Modell ergaenzen.
3. Die Map-Konvertierung in `AppRepository` erweitern.
4. Eine Konfigurationsseite nach dem Session-Muster erstellen.
5. Name, Regeln und Spieler direkt speichern.
6. Eine Rundenliste ueber `sessionId` erstellen.
7. Eine Rundenerfassung mit spieltypischer Validierung erstellen.
8. Session- und Rundeloeschung mit Bestaetigung anbinden.
9. Autocomplete-Auswahl und Eingabefeld-Leeren uebernehmen.
10. Tests fuer Modell, Persistenz, Autosave und Loeschkaskade ergaenzen.
11. `dart format`, `flutter test`, `flutter analyze` und `git diff --check` ausfuehren.

## 12. Qualitaetscheckliste

- [ ] Spielblock besitzt eine stabile ID.
- [ ] Session und Runde sind getrennte Modelle.
- [ ] Jede Runde referenziert ihre Session.
- [ ] Spieler werden ueber stabile IDs referenziert.
- [ ] Repository kapselt Sembast und Map-Formate.
- [ ] Controller ist die einzige Schreibschnittstelle der UI.
- [ ] Konfiguration wird direkt gespeichert.
- [ ] Unvollstaendige Konfigurationen werden nicht gespeichert.
- [ ] Autocomplete-Feld wird nach Auswahl geleert.
- [ ] Neue Spieler koennen direkt aus dem Eingabefeld angelegt werden.
- [ ] Partie-Loeschung entfernt zugehoerige Runden.
- [ ] Runde-Loeschung benoetigt eine Bestaetigung.
- [ ] Rundenliste aktualisiert sich nach Rueckkehr aus Unterseiten.
- [ ] Keine manuellen Speichern-Buttons fuer Direkt-Speichern-Bereiche.
- [ ] Tests decken Persistenz, Update und Loeschung ab.
- [ ] Accessibility und grosse Schrift erzeugen keine ueberlappenden Controls.
