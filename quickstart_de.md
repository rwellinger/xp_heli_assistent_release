# Schnelleinstieg — Welly's Heli Assistent

Von der Installation zum Schwebeflug in zehn Minuten. Alles hier steht ausführlicher in der
eingebauten Hilfe des Plugins (Plugin-Menü **Heli Assistent → Help**). Das Plugin selbst ist
englisch beschriftet; die Namen der Knöpfe stehen hier deshalb so, wie Du sie siehst.

## 1. Einmalig: Deine Steuerung

Der Assistent liest nur, was Deine Steuerung sendet. In X-Plane unter **Settings → Joystick**:

- **Pitch**, **Roll**, **Yaw** (Pedale oder Drehachse) und **Collective** Deiner Hardware
  zuweisen und kalibrieren.
- Ein Stick, der nicht genau in die Mitte zurückkehrt, braucht eine kleine **Null Zone**.
  Ein sehr empfindlicher Stick wird mit einer **Response Curve**, die um die Mitte flacher
  ist, ruhiger. Das Plugin ändert diese Einstellungen nie selbst: Sie gehören zu Deiner
  Hardware, und X-Plane wendet sie auf jedes Flugzeug an.

## 2. Vor dem Anlassen

Der Assistent muss lernen, in welche Richtung Dein Collective-Hebel läuft, und das kann er
nur, solange er den Collective nicht selbst fliegt. Den Hebel bei drehendem Rotor ganz
durchzuziehen hiesse abheben, darum:

1. Unterstützten Helikopter laden, am Boden, **Rotor steht**. Das Fenster **Before you
   start** öffnet sich von selbst.
2. **Heli Assistent → Settings → Check hardware**: jede Achse bewegen, wie angezeigt — Stick
   einmal rundum an die Anschläge, jedes Pedal an den Anschlag, Hebel von ganz unten nach
   ganz oben. Dreissig Sekunden.
3. Triebwerk anlassen, Rotor auf Drehzahl bringen, **Hebel unten**.

## 3. Diese Kommandos belegen

In X-Plane unter **Settings → Keyboard**, Suche nach `xp_heli_assistent`:

| Kommando | Was es tut | Worauf |
|---|---|---|
| `assist/bypass` | **gibt alle Achsen sofort zurück**, ohne Überblendung | ein Knopf am Stick — der wichtigste |
| `assist/all_on` | schaltet alle Achsen ein | ein Knopf |
| `assist/cyclic`, `assist/yaw`, `assist/collective` | schaltet eine Achse ein oder aus | Knöpfe, optional |
| `assist/height_reference_toggle` | hält die Höhe über Meer (ALT) oder über Grund (AGL) | optional |
| `window/assistant` | öffnet das Assistentenfenster | optional |

## 4. Dein erster Flug (Stufe Full)

1. Assistentenfenster öffnen (**Heli Assistent → Assistant**). Stufe auf **Full** lassen.
2. **All on** drücken. Die Lampen für Cyclic, Pedals und Collective leuchten.
3. **Hebel über das grüne Band** im Hebelbalken ziehen. Der Assistent hebt ab und hält einen
   tiefen Schwebeflug.
4. Fliegen:
   - **Stick nach vorn** neigt den Helikopter, er wird schneller. **Loslassen**, und er
     bremst ab und bleibt über Grund stehen.
   - **Hebel über dem Band**: steigen, **darunter**: sinken, **im Band**: Höhe halten.
   - **Langsam (Lampe TAXI leuchtet): mit den Pedalen drehen.** Der Querstick schiebt Dich
     seitwärts.
   - **Schnell (Lampe TAXI dunkel): mit dem Querstick kurven**, wie im Flugzeug. Die Pedale
     halten den Flug koordiniert.
   - Lies die Lampe, nicht die Fahrt: Sie schaltet mit einer Lücke zwischen zwei
     Geschwindigkeiten um.
5. **Landen:** auf Schwebeflug abbremsen, Hebel unter das Band. In Bodennähe ist die
   Sinkrate begrenzt. Beim Aufsetzen geht der Collective an Deinen Hebel zurück —
   **Hebel ganz runter**.

## 5. Eine Achse zurücknehmen

Ihre Lampe anklicken. Steht Deine Steuerung weit weg von dem, was der Assistent gibt,
antwortet der erste Klick mit **PRESS AGAIN**: Steuerung näher heranführen, oder nochmals
klicken und sie trotzdem nehmen. Die Achse geht dann sanft an Dich über.

In der Luft gibt es absichtlich kein „alles aus": Welche Achse Du wann zurücknimmst, ist
Deine Entscheidung. Am Boden wird **All on** zu **All off**.

Im Notfall: **BYPASS**. Alle Achsen gehören Dir sofort, ohne Überblendung — sofort den
Collective-Hebel prüfen.

## 6. Die Stufen

Die Stufe wählst Du im Auswahlfeld oben im Assistentenfenster, **nur solange alle Achsen
aus sind**. Jede Stufe tiefer gibt Dir eine Fertigkeit mehr zurück.

| | Full | Medium | Basic | Light |
|---|---|---|---|---|
| Stick losgelassen | **bleibt stehen** über Grund | Lage gehalten, Fahrt bleibt | Lage gehalten | Deins |
| Pedale | halten und drehen den Kurs | Deine, Drehmoment ausgeglichen | fliegen direkt | Deine |
| Hebel | Steig- oder Sinkrate, Band = Höhe halten | Steig- oder Sinkrate, Band = Vertikalgeschwindigkeit null | fliegt direkt, gedämpft | Deiner |
| Abheben | der Assistent (Hebel über das Band) | der Assistent | selbst | selbst |

## 7. Die Statuszeile lesen

Die Zeile unten im Assistentenfenster sagt das Dringendste; mit der Maus darüber steht der
ganze Satz. **Rot heisst jetzt handeln**: `COLLECTIVE LOST - YOU HAVE IT` (etwas anderes hat
den Collective bewegt, flieg den Hebel) oder `BYPASS - ALL YOURS`. **Bernstein** heisst, der
Assistent macht seine Arbeit nur teilweise, zum Beispiel `CYCLIC AT LIMIT`.

## 8. Was der Assistent nicht tut

- **Er ist kein Rettungssystem.** Er hält eine Lage, er gewinnt keine zurück.
- **Vortex Ring State:** Langsam über Grund ist die Sinkrate immer begrenzt, denn ein
  Assistent, der die Fahrt auf null hält, würde Dich geradewegs hineinfliegen. Sinkt der
  Helikopter trotzdem schnell senkrecht: **Cyclic ausschalten und vorwärts fliegen.**
- Helikopter mit eigenem Autopiloten oder Stabilisierungssystem: dieses zuerst ausschalten.

## Mehr

- Eingebaute Hilfe: alles zu den Fenstern, zur Statuszeile und zu den Einstellungen.
- **Settings → Reiter Assistant**: wie schnell Du langsam sinken darfst, wie schnell der
  Querstick Dich seitwärts schiebt, wie viel Cyclic der Assistent nutzen darf.
- Deine Einstellungen gelten je Helikopter: **Save for this aircraft** speichert sie.
