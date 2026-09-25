# Einheitliche UI Controls, Design und Settings

## Status

Umgesetzt; entspricht dem gemeinsamen Standard.

## Gemeinsamer Standard

Alle Apps in `m.git` sollen dieselbe UI-Settings-Auswahl anbieten:

- Schriftart: `OpenDyslexic`, `NotoSans`, `CourierPrime`, `Ubuntu`, `Ubuntu Mono`
- Schriftgröße: 50 % bis 160 %
- Designmodus: hell oder dunkel
- Akzentfarbe: Rot, Orange, Grün, Gelb, Blau, Mint, Lila
- Highlight-Farbe: Rot, Orange, Grün, Gelb, Blau, Mint, Lila

## PlaySheet Umsetzung

- Settings-Datei: `lib/src/settings.dart`
- App-Theme: `lib/src/app.dart`
- Persistenz: `playsheet_settings.json` mit Legacy-Migration aus SharedPreferences
- Einstieg: bestehende Einstellungen-Seite aus `lib/src/pages.dart`

## Abgleich

PlaySheet nutzt bereits:

- `fontFamily`
- `textScaleFactor`
- `useLightTheme`
- `accentColorValue`
- `highlightColorValue`
- dieselbe Farbpalette: Rot, Orange, Grün, Gelb, Blau, Mint, Lila

## Abgleich 2026-09-25

Die Font-Auswahl ist im Settings-Modell zentralisiert und wird von der Settings-Seite verwendet. Damit entspricht PlaySheet dem gemeinsamen UI-X-Standard.
