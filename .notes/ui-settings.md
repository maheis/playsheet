# UI-Settings-Dokumentation: PlaySheet

Diese Dokumentation beschreibt die globalen Einstellungen von PlaySheet, ihre Speicherung und ihre Laufzeitwirkung.

## Umfang

PlaySheet konzentriert die globalen Einstellungen auf Darstellung und Lesbarkeit:

- Schriftfamilie
- globale Textskalierung
- Light-/Dark-Theme
- Akzentfarbe
- Highlight-Farbe

Spielregeln, Spielarten, Spielerfarben und spielbezogene Werte bleiben in den jeweiligen Spiel- und Spielerbereichen. Dadurch bleibt die globale Settings-Seite uebersichtlich.

## Settings-Modell

Das Modell `AppSettings` liegt in `lib/src/settings.dart`. Es ist unveraenderlich und besitzt zentrale Defaults:

| Feld | Typ | Default | Bedeutung |
|---|---|---|---|
| `fontFamily` | `String` | `Ubuntu` | Global verwendete Schriftfamilie |
| `textScaleFactor` | `double` | `1.0` | Globale Textskalierung, begrenzt auf 0.5 bis 1.6 |
| `useLightTheme` | `bool` | `false` | Light-Theme aktivieren; Dark ist Standard |
| `accentColorValue` | `int` | `0xFFE57373` | Primaer-/Seed-Farbe |
| `highlightColorValue` | `int` | `0xFFFFB74D` | Farbe fuer Controls und Hervorhebungen |

Verfuegbare Fonts:

- Ubuntu
- OpenDyslexic
- NotoSans
- CourierPrime
- Ubuntu Mono

Verfuegbare Farben: Rot, Orange, Gruen, Gelb, Blau, Mint und Lila. Fuer Spielerfarben sind zusaetzlich Schwarz und Weiss erlaubt.

## Settings-Seite

Die `SettingsPage` in `lib/src/pages.dart` ist eine scrollbare `ListView` in einem `Scaffold` mit `AppBar`.

Aktuelle Reihenfolge:

1. Schriftart
2. Schriftgroesse
3. Helles Theme
4. Akzentfarbe
5. Highlight-Farbe

| Einstellung | Control | Verhalten |
|---|---|---|
| Schriftart | `DropdownButtonFormField<String>` | Auswahl aus den eingebundenen Fonts |
| Schriftgroesse | `Slider` | 50 % bis 160 %, 22 Schritte |
| Helles Theme | `SwitchListTile` | Light-/Dark-Theme umschalten |
| Akzentfarbe | `DropdownButtonFormField<int>` | Farbswatch und Farbname aus der erlaubten Palette |
| Highlight-Farbe | `DropdownButtonFormField<int>` | Farbswatch und Farbname aus der erlaubten Palette |

Aenderungen werden direkt uebernommen und gespeichert. Die Seite besitzt aktuell keinen separaten Speichern- oder Verwerfen-Schritt.

## Architektur und Aenderungsfluss

```text
SettingsPage
    -> AppSettings.copyWith(...)
    -> SettingsController.update(value)
    -> notifyListeners()
    -> AppSettings im App-Root anwenden
    -> playsheet_settings.json speichern
```

`SettingsController` liegt ebenfalls in `lib/src/settings.dart`:

- `load()` liest zuerst die JSON-Datei.
- Falls sie nicht vorhanden oder leer ist, werden Legacy-Werte aus `SharedPreferences` verwendet.
- `update(...)` veroeffentlicht den neuen Wert sofort und schreibt anschliessend JSON.
- Ungueltige Farbwerte fallen auf den jeweiligen Default zurueck.
- Die Textskalierung wird beim Laden auf den Bereich 0.5 bis 1.6 begrenzt.

Die Settings-Seite greift nicht direkt auf das Dateiformat zu.

## Speicherung und Migration

- Dateiname: `playsheet_settings.json`
- Speicherort: `getApplicationDocumentsDirectory()`
- Format: eingeruecktes JSON-Objekt
- Legacy-Quelle: `SharedPreferences`
- Persistierte Schluessel: `fontFamily`, `textScaleFactor`, `useLightTheme`, `accentColorValue`, `highlightColorValue`

Das Laden ist fehlertolerant: Defekte oder fehlende JSON-Werte verhindern den Start nicht, sondern werden durch Defaults ersetzt. Die Legacy-Werte werden nur als Rueckfall verwendet, wenn die JSON-Datei keine Daten liefert.

## Laufzeitwirkung

`PlaySheetApp` in `lib/src/app.dart` beobachtet den `SettingsController` mit `AnimatedBuilder` und erstellt bei Aenderungen die Themes neu:

- `theme` und `darkTheme` verwenden `ColorScheme.fromSeed`.
- `themeMode` folgt `useLightTheme`.
- `fontFamily` wird global auf `ThemeData` gesetzt.
- `MediaQuery.textScaler` verwendet `textScaleFactor`.
- Akzentfarbe wird als primaere Theme-Farbe verwendet.
- Highlight-Farbe wird auf Icons, Buttons, Slider, Checkboxen, Radios, Switches und Eingabefokus angewendet.
- Snackbars erhalten eine aus Surface und Akzentfarbe berechnete Hintergrundfarbe mit kontrastierender Schrift.

## UX-Regeln

- Jede Einstellung zeigt ihren aktuellen Wert direkt.
- Farbauswahl kombiniert Farbswatch und Name.
- Der Slider zeigt Prozentwert, Minimum und Maximum.
- Themewechsel muss ohne Neustart sichtbar werden.
- Sensible oder destruktive Datenfunktionen gehoeren nicht in diese globale Seite.
- Bei wachsendem Umfang sollten Einstellungen nach Darstellung, Eingabe und Daten getrennt werden.

## Offene Qualitaetspruefungen

- Tastatur- und Screenreader-Bedienung der gesamten Settings-Seite.
- Kontrastpruefung aller Farbpaare in Dark und Light.
- Tests fuer defekte JSON-Dateien, fehlende Werte und Legacy-Migration.
- Pruefung, dass grosse Textskalierung keine abgeschnittenen Controls erzeugt.
