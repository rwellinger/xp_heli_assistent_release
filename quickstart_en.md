# Quickstart — Welly's Heli Assistent

From installed to hovering in ten minutes. Everything here is in more detail in the plugin's
built-in help (plugin menu **Heli Assistent → Help**).

## 1. Once: your controls

The assistant only reads what your controls send. In X-Plane's **Settings → Joystick**:

- Assign **pitch**, **roll**, **yaw** (pedals or twist) and **collective** to your hardware,
  and calibrate them.
- A stick that does not return exactly to centre needs a small **null zone**. A very
  sensitive stick is calmer with a **response curve** that is flatter around the centre.
  The plugin never changes these settings itself; they belong to your hardware, and
  X-Plane applies them to every aircraft.

## 2. Before you start the engine

The assistant has to learn which way your collective lever runs, and it can only do that
while it is not flying the collective itself. Moving the lever through its travel with the
rotor turning would lift you off, so:

1. Load a supported helicopter, on the ground, **rotor stopped**. The window **Before you
   start** opens by itself.
2. **Heli Assistent → Settings → Check hardware**: move each control as told — stick round
   to its stops, each pedal to its stop, lever from bottom to top. Thirty seconds.
3. Start the engine and bring the rotor to speed, **lever down**.

## 3. Bind these commands

**Settings → Keyboard** in X-Plane, search for `xp_heli_assistent`:

| Command | What it does | Put it on |
|---|---|---|
| `assist/bypass` | **drops every axis at once**, no fade | a button on the stick — the most important one |
| `assist/all_on` | switches every axis on | a button |
| `assist/cyclic`, `assist/yaw`, `assist/collective` | switches one axis on or off | buttons, optional |
| `assist/height_reference_toggle` | holds height above sea level (ALT) or above the ground (AGL) | optional |
| `window/assistant` | opens the assistant window | optional |

## 4. Your first flight (level Full)

1. Open the assistant window (**Heli Assistent → Assistant**). Leave the level on **Full**.
2. Press **All on**. The lamps for Cyclic, Pedals and Collective light up.
3. **Raise the lever above the green band** in the lever bar. The assistant lifts off and
   holds a low hover.
4. Fly:
   - **Stick forward** leans the helicopter and it speeds up. **Let go** and it slows down
     and stops over the ground.
   - **Lever above the band**: climb, **below**: sink, **in the band**: height held.
   - **Slow (TAXI lamp lit): turn with the pedals.** The roll stick slides you sideways.
   - **Fast (TAXI lamp dark): turn with the roll stick**, like an aeroplane. The pedals keep
     the flight balanced.
   - Read the TAXI lamp, not the speed: it switches with a gap between the two speeds.
5. **Landing:** slow down to a hover, lower the lever below the band. Near the ground the
   sink rate is limited. At touchdown the collective is handed back to your lever —
   **lower the lever**.

## 5. Taking an axis back

Click its lamp. If your control is far from where the assistant has it, the first click
answers **PRESS AGAIN**: bring your control closer, or click again to take it anyway. The
axis is then handed back to you smoothly.

There is deliberately no "all off" in the air: which axis you take back, and when, is your
decision. On the ground **All on** becomes **All off**.

In an emergency: **BYPASS**. Every axis is yours at once, without a fade — check the
collective lever immediately.

## 6. The levels

The level is chosen in the drop-down at the top of the assistant window, **only while every
axis is off**. Each step down hands one more skill back to you.

| | Full | Medium | Basic | Light |
|---|---|---|---|---|
| Stick let go | **stops** over the ground | attitude held, speed stays | attitude held | yours |
| Pedals | hold and turn the heading | yours, torque taken care of | fly directly | yours |
| Lever | climb or sink rate, band = height held | climb or sink rate, band = vertical speed zero | flies directly, damped | yours |
| Lift-off | the assistant (lever above the band) | the assistant | yourself | yourself |

## 7. Read the status line

The line at the bottom of the assistant window says the most urgent thing; hover over it
for the full sentence. **Red means act now**: `COLLECTIVE LOST - YOU HAVE IT` (something
else moved the collective, fly the lever) or `BYPASS - ALL YOURS`. **Amber** means the
assistant is only doing part of the job, for example `CYCLIC AT LIMIT`.

## 8. What the assistant does not do

- **It is not a rescue system.** It holds an attitude; it does not win one back.
- **Vortex ring state:** slow over the ground the sink rate is always limited, because an
  assistant that holds your speed at zero would fly you straight into it. If the helicopter
  sinks straight down fast anyway: **switch the cyclic off and fly forward.**
- Helicopters with their own autopilot or stability system: switch it off first.

## More

- Built-in help: everything about the windows, the status line and the settings.
- **Settings → Assistant tab**: how fast you may sink when slow, how fast the roll stick
  slides you sideways, how much cyclic the assistant may use.
- Your settings are per helicopter: **Save for this aircraft** keeps them.
