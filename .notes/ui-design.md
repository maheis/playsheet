# UI-Design-Richtlinie: PlaySheet

Diese Dokumentation beschreibt den aktuellen visuellen Aufbau von PlaySheet und dient als verbindliche Orientierung fuer weitere UI-Arbeiten.

## Leitbild

PlaySheet ist ein digitaler Spielblock fuer Spielrunden, Punkte und Spieler. Die Oberflaeche soll beim laufenden Spiel schnell erfassbar sein: Spielart, aktueller Stand und naechste Aktion muessen ohne Umwege erreichbar sein.

## Implementierungsabgleich

| Bereich | Status | Aktueller Stand |
|---|---|---|
| Material 3 | umgesetzt | `ThemeData(useMaterial3: true)` |
| Dark/Light-Theme | umgesetzt | Dark ist Standard, Light ist in den Einstellungen aktivierbar |
| Akzent- und Highlightfarben | umgesetzt | Farben werden aus einer festen Palette gewaehlt |
| Typografie | umgesetzt | Ubuntu ist Standard; weitere Fonts sind eingebunden |
| Globale Textskalierung | umgesetzt | 50 % bis 160 % |
| Hauptnavigation | umgesetzt | Startseite, Spieler, Einstellungen, Spielarten und Spielrunden |
| Spielmodule | umgesetzt | `1 + 2 = 3`, `3 +- 2 = 1`, Dam'jagen, 10Tausend, Strichliste, Wuerfelblock, Kingdomino |
| Accessibility | teilweise | Tooltips und skalierbare Schrift vorhanden; vollstaendige Tastatur-/Screenreader-Pruefung offen |

## Theme und Farben

Das Theme wird in `lib/src/app.dart` aus `ColorScheme.fromSeed` erzeugt. Die konfigurierbare Akzentfarbe ist `colorScheme.primary`; Orange wird als sekundaere und Mint als tertiaere Farbe verwendet. Die Highlight-Farbe steuert Icons, Schaltflaechen, Auswahlzustande und Eingabefokus.

| Rolle | Quelle / Wert | Verwendung |
|---|---|---|
| Hintergrund | `colorScheme.surface` | Scaffold und Seitenflaechen |
| Primaerfarbe | `AppSettings.accentColorValue` | App-Logo, primaere Aktionen, aktive Elemente |
| Highlight | `AppSettings.highlightColorValue` | Icons, Controls, Slider, Fokus und Buttons |
| Sekundaer | `Color(0xFFFFB74D)` | sekundare Theme-Akzente |
| Tertiaer | `Color(0xFF8FDCBE)` | tertiaere Theme-Akzente |
| Fehler | Theme-/Material-Fehlerfarbe | Validierungs- und Eingabefehler |

Verfuegbare Akzent- und Highlightfarben: Rot, Orange, Gruen, Gelb, Blau, Mint und Lila. Spieler duerfen zusaetzlich Schwarz und Weiss erhalten.

Strukturfarben kommen aus dem `ColorScheme`. Spielbezogene Farben werden nur zur Unterscheidung von Spielarten, Spielern oder Kategorien eingesetzt und nicht als alleiniger Statushinweis.

## Typografie

Ubuntu ist die Standardschrift. Verfuegbar sind ausserdem OpenDyslexic, NotoSans, CourierPrime und Ubuntu Mono. Die Auswahl wird global ueber `ThemeData.fontFamily` angewendet; die Textskalierung wird am `MaterialApp` ueber `MediaQuery.textScaler` gesetzt.

| Verwendung | Richtwert |
|---|---|
| AppBar-Titel | `titleLarge` bzw. ca. 20 bis 24 px |
| Bereichsueberschrift | `titleLarge`, fett |
| Spiel- und Spielername | `titleMedium` |
| Punktwerte und Rechneranzeige | gross, kontrastreich, kontextabhaengig |
| Zusatzinformationen | `bodySmall` bzw. `onSurfaceVariant` |

Punktwerte, Eingabefelder und Rechneranzeige benoetigen klare Zahlenformen und ausreichend Platz. Textskalierung darf keine Werte, Buttons oder Tabellen abschneiden.

## Layout und Navigation

- Die Startseite verwendet eine vertikale Liste aus Karten fuer die verfuegbaren Spielarten.
- Jede Spielarten-Karte zeigt Icon oder Spielsymbol, Namen, Kurzbeschreibung bzw. Spielanzahl und einen Chevron.
- Spielrunden werden ueber `AppBar`, Listen und Karten erreicht.
- Spieler und Einstellungen sind globale Bereiche der Startseite.
- Listen verwenden einheitliche Innenabstaende von meist 12 bis 16 px.
- Spielansichten priorisieren die Eingabe von Punkten und halten sekundare Aktionen aus dem unmittelbaren Eingabebereich heraus.
- Der Taschenrechner wird als `showModalBottomSheet` geoeffnet; seine Barriere ist transparent, damit der Spielstand im Hintergrund sichtbar bleibt.

## Komponenten

### Karten und Listen

- `Card` und `ListTile` strukturieren Spielarten, Spielrunden und Spieler.
- Karten verwenden abgerundete Interaktionen mit `InkWell`.
- Leere Zustaende werden durch kurze, sichtbare Hinweise erklaert.
- Datum, Spieler und letzte Aktivitaet erscheinen als Sekundaerinformationen.

### Aktionen

- Primaere Aktionen verwenden `ElevatedButton`, `FilledButton` oder klar erkennbare Kartenaktionen.
- Sekundaere Aktionen verwenden `TextButton` oder `OutlinedButton`.
- Icon-only-Aktionen sind fuer bekannte Werkzeugaktionen zulaessig und erhalten Tooltips.
- Destruktive Aktionen werden bestaetigt und visuell eindeutig gekennzeichnet.

### Spielwert-Eingabe

- Punktfelder zeigen ihren aktuellen Wert direkt.
- Der Rechner unterstuetzt Ausdruckseingabe, negative Werte, Leeren und Abschlussaktionen.
- Eingabefehler werden erst beim Speichern bewertet, damit die laufende Eingabe nicht durch vorzeitige Snackbars gestoert wird.
- Wuerfelblock-Eingaben bleiben waehrend der Eingabe ruhig; die Validierung erfolgt beim Speichern.

### Dialoge und Overlays

- Standardmaessig werden `AlertDialog` und `showModalBottomSheet` verwendet.
- Der Rechner nutzt keine starke Hintergrundabdunklung.
- Snackbars folgen dem globalen Theme und passen sich an Dark-/Light-Mode sowie die Akzentfarbe an.

## Icons und Symbole

Es werden Material Icons sowie das vorhandene PlaySheet-SVG-Logo verwendet. Spielarten duerfen zusaetzliche Textsymbole nutzen, wenn sie fuer den jeweiligen Spielblock charakteristisch sind.

| Zweck | Beispiel |
|---|---|
| Einstellungen | `Icons.settings_rounded` |
| Spieler | `Icons.people_alt_rounded` |
| Hinzufuegen | `Icons.add_rounded` |
| Spielrunde starten | `Icons.play_arrow_rounded` |
| Wuerfel | `Icons.casino_rounded` |
| Navigation | `Icons.chevron_right_rounded` |
| Datum | `Icons.event_outlined` |

## Accessibility und Qualitaet

- Controls erhalten sichtbare Beschriftungen.
- IconButtons erhalten Tooltips.
- Farbunterschiede werden durch Text, Icons oder Zahlen ergaenzt.
- Grosse Schrift muss Karten, Punktfelder, Tabellen und Rechnerbuttons ohne Ueberlappung darstellen.
- Dark- und Light-Theme sowie alle waehlbaren Farben muessen auf Kontrast geprueft werden.
- Tastaturbedienung und Screenreader-Semantics sind noch vollstaendig zu pruefen.
