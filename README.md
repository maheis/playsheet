# PlaySheet

PlaySheet: Digital Scorepad
PlaySheet: Digitaler Spielblock

Ein digitaler Spielblock, der die Verwaltung von Spielständen und Statistiken für verschiedene Spiele ermöglicht. Spieler können ihre Ergebnisse speichern, neue Runden starten und verschiedene Spieloptionen anpassen.
Es soll verschiedene Arten von Spielblöcken für die verschiedensten Spiele geben.

## Neustart und Architektur

PlaySheet wird als modulare Flutter-App aufgebaut und orientiert sich bei Theme,
Typografie, Farben und Einstellungen an VolleyAce und SimplePresent. Der
Standard bleibt dunkel, Material 3 wird verwendet und die globale Darstellung
ist über Settings anpassbar.

Der aktuelle Grundumfang umfasst Spieler, Einstellungen und den ersten Spielblock
`1 + 2 = 3` bis zur Rundenübersicht:

- Dashboard mit Spieleranzahl
- eindeutige, lokal gespeicherte Spieler zur Wiederverwendung
- globale Settings für Theme, Schriftart und Textskalierung
- lokales Repository als austauschbare Basis für spätere Cloud-Synchronisierung
- gespeicherte `1 + 2 = 3`-Spiele mit Name, Gewinnart und Spielerauswahl
- Rundenübersicht mit Einstieg in eine neue Runde

Die genaue Spielanleitung sowie Punkte- und Auswertungslogik von `1 + 2 = 3` folgen
im nächsten Umsetzungsschritt. Die übrigen Spielblöcke und Statistiken bleiben
als technische Grundlage vorbereitet.

### Modularer Spielblock

Ein Spielblock wird über eine `GameBlockDefinition` registriert. Die Definition
beschreibt Identität, Name, Beschreibung, Icon und Farbe. Fachlogik und ein
spielspezifisches Scoreboard können später als eigenes Modul ergänzt werden,
ohne Dashboard, Spielerbestand oder Synchronisierung neu zu bauen.

### Datenfluss

```text
Page → AppController → AppRepository → lokale Speicherung
					↓
				Cloud-Adapter
```

Spieler und abgeschlossene Spiele besitzen stabile IDs. Dadurch können später
Konfliktauflösung, Geräte-Synchronisierung und Statistiken über mehrere Geräte
auf derselben Datenbasis aufbauen.

## Notes

- Spieler als Objekte, um Statistiken zu speichern (z.B. Anzahl Siege, Niederlagen, Punkte, etc.)
- Neues Spiel -> Spielblock auswählen -> Optionen zum Spielblock (z.B. Spieleranzahl, Spielregeln (z.B. hoch/tief), etc.) -> Spiel starten -> ... -> Neue Runde starten
- Könnte man ein lokales LLM (wichtig unter Android) einbinden um automatisch Spielregeln und neue Spielblöcke zu generieren? (z.B. für Würfelspiele, Kartenspiele, Brettspiele, etc.)
- Kleiner Taschenrechner und Eingabe in Feldern mit Rechenoperationen!

## Spielstände

- [x] 1 + 2 = 3
- [x] 3 +- 2 = 1
- [x] 10Tausend
- [ ] Strichliste
- [ ] Dam'jagen
- [ ] Würfelblock
- [ ] Cluedo
- [ ] Kingdomino

## Spiele

- [ ] 4gewinnt
- [ ] Duotär

## Ideensammlung

- [ ] Käsekästchen (Spiel)
- [ ] TicTacToe (Spiel)
- [ ] Skat
- [ ] Schafkopf
- [ ] Doppelkopf
- [ ] Virtueller Würfel

## ToDo

- [ ] Highlight-Fabe wie in VolleyAce verwenden! Aktuell ist Aktzent für Steuerelemente genutzt!
- [ ] Settings-Page angleichen mit VolleyAce (Vorschau und Speicherbutton in VolleyAce entfernen!)

