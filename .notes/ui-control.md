# UI-Steuerung: PlaySheet-Grundlage

Dieses Dokument beschreibt das gemeinsame Steuerungsmodell von VolleyAce und SimplePresent und dient als verbindliche Grundlage für PlaySheet und weitere Apps.

## 1. Grundprinzip

- Der Nutzer navigiert über sichtbare Seiten, nicht über verschachtelte Dialoge.
- Ein Klick auf eine Kachel öffnet das zugehörige Modul oder den nächsten Arbeitsschritt.
- Kacheln zeigen Zweck, Status und die wichtigste Aktion direkt im Inhalt.
- Eine Seite hat eine klare Hauptaktion; sekundäre Aktionen bleiben in der AppBar oder als Icon in der betroffenen Kachel.
- `Zurück` nutzt die normale Navigation. `Weiter` öffnet den nächsten Schritt als neue Seite.
- Dialoge bleiben für kurze Bestätigungen, Warnungen und unumkehrbare Aktionen reserviert.

## 2. Navigation

```text
Startseite
  -> Modul-/Spielblock-Kachel
  -> Auswahlseite
  -> Optionen-Seite
  -> Arbeitsseite / Scoreboard
  -> Ergebnis speichern
  -> Statistik oder neuer Durchlauf
```

- Die AppBar enthält den Seitentitel und kontextbezogene Icon-Aktionen.
- Jede Unterseite kann mit der System-Zurück-Geste und dem sichtbaren Zurück-Pfeil verlassen werden.
- Mehrstufige Abläufe zeigen ihren Fortschritt, zum Beispiel mit einer Progress-Anzeige und einem eindeutigen Schritt-Titel.
- Formulare speichern erst beim expliziten Abschluss oder bei einer klar benannten Aktion.
- Ungültige oder unvollständige Eingaben blockieren `Weiter` und bleiben auf der aktuellen Seite verständlich markiert.

## 3. Kacheln statt Button-Flächen

Kacheln sind die zentrale Steuerung auf Dashboard-, Modul- und Übersichtsseiten.

Eine Kachel besteht aus:

- Icon oder Statussymbol
- kurzem Titel
- optionaler Beschreibung oder Kennzahl
- sichtbarer Tap-Fläche über die gesamte Kachel
- optionaler Aktion als IconButton innerhalb der Kachel

Verwende keine große Reihe unabhängiger Textbuttons, wenn die Aktion als Modul, Inhalt oder Status dargestellt werden kann. Ein `+` gehört als eigene Plus-Kachel in die Kachelgruppe und öffnet eine Erstellungsseite.

Beispiele für PlaySheet:

- `+ Spiel starten` öffnet den Spielblock-Workflow.
- Spielblock-Kacheln öffnen die Optionen des jeweiligen Moduls.
- Spieler-Kacheln zeigen den Namen und Kennzahlen; die Plus-Kachel legt einen Spieler an.
- Statistik-Kacheln öffnen Gesamt- oder Vergleichsansichten.

## 4. Responsive Verhalten

Die Kachelbreite wird über den verfügbaren Platz bestimmt, nicht ausschließlich über das Gerät:

- Portrait/schmal: eine Kachel pro Reihe, vertikale Scrollbarkeit.
- Breites Portrait: zwei Kacheln pro Reihe, wenn Titel und Beschreibung sicher passen.
- Landscape/breites Desktopfenster: zwei bis vier Kacheln pro Reihe mit stabiler Mindestbreite.
- Fachliche Arbeitsflächen dürfen Landscape vollständig ausnutzen; Portrait bleibt scrollbar und touch-tauglich.
- `LayoutBuilder` oder `MediaQuery` entscheidet anhand von Constraints. Die Orientierung allein ist kein ausreichendes Kriterium.
- Kachelgrößen, Abstände und Icon-Flächen bleiben stabil, damit Textskalierung und Hover-Zustände kein Layout springen verursachen.

## 5. Eingaben und Arbeitsflächen

- Datenreiche Eingaben werden auf mehrere Seiten verteilt.
- Felder erhalten klare Labels, sinnvolle Tastaturtypen und sichtbare Validierung.
- Scoreboards priorisieren große Zahlen, direkte Eingabe und schnelle Wiederholung.
- Aktionen wie Speichern, neue Runde, Zurücksetzen und Synchronisieren sind als IconButton oder klar benannte Aktion in der AppBar beziehungsweise Kachel erreichbar.
- Während einer laufenden Partie werden unnötige Navigation und modale Unterbrechungen vermieden.

## 6. Gestaltungsregeln

- Material 3, dunkles Theme als Standard, helles Theme optional.
- Globale Schriftwahl und Textskalierung gelten für alle Seiten.
- Ubuntu/OpenDyslexic, NotoSans, CourierPrime und Ubuntu Mono sind gleichwertig auswählbar; OpenDyslexic ist der PlaySheet-Default.
- Die bestehende Rot-, Orange-, Grün-, Gelb-, Blau-, Mint- und Lila-Palette bleibt konsistent.
- Karten verwenden kleine bis mittlere Radien und keine Karten-in-Karten-Strukturen.
- Icons sind Material Icons und erhalten bei Icon-only-Aktionen Tooltips.
- Farbe ist nie das einzige Statussignal; Text, Icons oder Zahlen begleiten sie.

## 7. PlaySheet-Modulvertrag

Jeder Spielblock wird als eigenständiges Modul registriert und liefert mindestens:

- stabile Modul-ID
- Name, Beschreibung und Icon
- eigene Optionen-Seite
- eigene Arbeits-/Scoreboard-Seite
- Speicherung von Runden und Ergebnissen
- Auswertungsbeitrag für Spieler- und Gesamtstatistik

Das App-Grundgerüst kennt nur Registry, Navigation, Spielerbestand, Repository und Synchronisierung. Spielregeln und Eingabefelder bleiben im Modul. Dadurch können neue Spielblöcke ergänzt werden, ohne den globalen App-Flow zu verändern.

## 8. Qualitäts- und Accessibility-Checkliste

- [ ] Jede Kachel ist vollständig tappbar und eindeutig beschriftet.
- [ ] Plus-Kacheln sind visuell und semantisch als Erstellen-Aktion erkennbar.
- [ ] Portrait und Landscape wurden mit großer und kleiner Fensterbreite geprüft.
- [ ] Keine Hauptfunktion hängt ausschließlich an einem Dialog.
- [ ] Zurück und Weiter sind in mehrstufigen Flows konsistent.
- [ ] Icon-only-Aktionen besitzen Tooltip und Semantics.
- [ ] Große Schrift erzeugt keinen Überlauf und keine abgeschnittenen Labels.
- [ ] Kontrast und Statusinformationen funktionieren ohne Farbwahrnehmung.
- [ ] Module können unabhängig getestet und ergänzt werden.
