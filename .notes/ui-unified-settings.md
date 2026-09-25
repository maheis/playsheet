# Einheitliche UI Controls, Design und Settings

## Status

Bereits vorhanden; entspricht dem gemeinsamen Standard weitgehend.

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

## Nächster Feinschliff

Die verfügbare Schriftliste sollte explizit an den gemeinsamen Standard angeglichen werden, falls die UI-Seite nicht alle Fonts anbietet.
