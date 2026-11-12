# Welly's Heli Assistent

An X-Plane 12 plugin that flies the helicopter controls you hand to it, the way MSFS 2024's
assisted cyclic, tail rotor and collective do: you say where to go, it keeps the helicopter
steady. Each axis — cyclic, pedals, collective — is switched on its own, in four levels from
*Full* down to *Light*.

Start here: **[quickstart_en.md](quickstart_en.md)** (Deutsch:
**[quickstart_de.md](quickstart_de.md)**). The complete help is built into the plugin: plugin menu
**Help**, or the **?** button in the assistant window.

## Requirements

- X-Plane 12
- macOS (Apple Silicon or Intel) or Windows 10/11 (x64)
- A joystick or yoke for the cyclic, pedals or a twist axis for the tail rotor, and a
  collective lever (a throttle axis works). The assistant reads your controls; it does not
  replace them.
- One of the supported helicopters below

## Installation

1. Copy the folder `xp_heli_assistent` into `<X-Plane 12>/Resources/plugins/`.
2. **macOS only:** macOS marks everything that arrived in a ZIP as quarantined, and X-Plane
   then refuses to load the plugin without saying why. Clear the flag once in Terminal:

   ```sh
   xattr -dr com.apple.quarantine "<X-Plane 12>/Resources/plugins/xp_heli_assistent"
   ```

3. Start X-Plane and load a supported helicopter. The plugin menu shows
   **Heli Assistent** under *Plugins*.

### Updating

Replace the folder, or let the **SkunkCrafts Updater** do it: the plugin supports it, and the
folder carries its control files. Everything in the folder belongs to the plugin and is
replaced. What is yours lives elsewhere and stays:

    <X-Plane 12>/Output/preferences/xp_heli_assistent/

There are your own values (**Save for this aircraft**), the window layout and what the plugin
learned about each helicopter on your machine. Deleting X-Plane's preferences folder — a
common fix for other problems — deletes these too.

Coming from 1.0.x: the plugin moves your files out of the old `config/` folder on its first
start. Of a tuning file it keeps only what you changed yourself; the old file stays as
`.migrated`.

When an update ships a different value for something you set yourself, the Settings window
says so in amber: **Use shipped** or **Keep mine**. **Reset to shipped** sets all your values
for that helicopter aside.

## Supported helicopters

The plugin recognises a helicopter by its profile in `profiles/`. Without a matching
profile the plugin stays inactive and says so.

- Robinson R22 Beta II (Laminar)
- Sikorsky S-76C (Laminar), UH-60M Black Hawk (free, melbo)
- Guimbal Cabri G2
- Aerospatiale SA315B Lama
- Airbus AS350 B, EC130 B4, EC135 (free, rotorsim "EC 135 V5")
- Bell 412
- Dreamfoil B206B3 JetRanger
- JRX Bell 407, MD 902
- Leonardo AW109, AW139
- Robinson R66 Turbine
- VSKYLABS Robinson R44 Raven II, 902X-NTR, Hungarocopter HC-02

Helicopters with their own autopilot or stability system (the AW139, for example):
switch that system off before you hand an axis to the assistant. Two systems flying the
same control fight each other.

Airbus EC135: after a cold-and-dark start, release the cyclic lock in the cockpit first, and
keep the collective under about 0.65 when you fly it yourself; above about 0.70 the pedals can
no longer stop the aircraft turning right.

## What's in the folder

| | |
|---|---|
| `mac_x64/xp_heli_assistent.xpl` | the plugin for macOS (one file for Apple Silicon and Intel) |
| `win_x64/xp_heli_assistent.xpl` | the plugin for Windows |
| `profiles/` | what the plugin knows about each helicopter |
| `basis/` | the tuning each helicopter ships with |
| `skunkcrafts_updater*` | for the SkunkCrafts Updater |
| `quickstart_en.md`, `quickstart_de.md` | getting started |
| `LICENSE` | the licence agreement |
| `THIRD-PARTY-NOTICES.md` | licences of the libraries the plugin uses |

## Licence

Copyright (c) 2026 Robert Wellinger. All rights reserved. See `LICENSE`.
