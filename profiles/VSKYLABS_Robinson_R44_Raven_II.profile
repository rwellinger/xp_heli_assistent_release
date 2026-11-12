# VSKYLABS Robinson R44 Raven II (VSL, v4.0.2) — piston, two blades, conventional tail rotor
#
# Read from a running X-Plane 12 over the Web API on 2026-10-13, on the skids with the
# rotor governed at 408 RPM (engine 2718, lever down). Script findings are from
# plugins/xlua/scripts/*/*.lua. VSKYLABS also built the R66, the Cabri G2, the 902X and the
# HC-02 — a lead for the control chain, never a conclusion. The R66 is the same rotor
# (10.06 m, 408 RPM) on a turbine; this one is a piston, like the HC-02.
#
# ── One script writes override_prop_pitch, every frame ───────────────────────
# R44_init.lua, after_physics: "collective friction" sets override_prop_pitch to 1 while
# speedbrake_ratio is 1 and to 0 otherwise. So the flag is never ours to keep: held over
# the Web API (2026-10-13, 30 Hz, 4 s) it read 0 in 20 of 20 samples and the blade stayed
# where it was. And with the friction on, every propeller freezes — the tail rotor too —
# with or without this plugin. Keep the speedbrake off.
#
# No other override, no copilot channel. servos_on 0, the script disconnects the autopilot
# servos; artificial_stability_on 1 and yaw_damper_on 1 as found.
#
# The pedal reaches the flight model scaled: total_heading_ratio = 1.16 x yoke_heading_ratio
# (-0.6 -> -0.696, +0.6 -> +0.696, ground test 2026-10-13), no offset.
#
# ── From the .acf, before flying ─────────────────────────────────────────────
#   _prop/0/_prop_dir      +1     -> left pedal, NEGATIVE yaw.torque_per_collective
#   acf/_rotor_mi_rat      0.23   -> plan to sweep inner_kp past 0.15 (R66 0.26: 0.090)
#   _prop/0 pitch          0 .. 10 deg (main),  _prop/1 -12.5 .. 14.5 deg (tail)
#   _prop/0/_des_rpm_prp   408    -> 408.1 on the skids, governed
#   engine RCP_INJ, one engine (no ERS), manifold derated 29.92 -> 26.5 inHg with power
#     (R44_engine_derating.lua)
#   correlator 0/0/0.75/1.10, _custom_govnr 1 -> the HC-02's governor read the hardware
#     lever; check this one in the hover before trusting the take-me-up
#   mass on the ramp as loaded 1020 kg (empty 1505 lb / 683 kg, MTOW 2500 lb / 1134 kg)

name      = VSKYLABS Robinson R44 Raven II
acf_match = Robinson-R44
icao      = R44

# Procedure: docs/adding-an-aircraft.md.
#
# First flights 2026-10-13 (laptop, Thrustmaster, fm 6, still air, 1015-1018 kg, density
# altitude 430-550 m). 16:06 hover by hand at 125 m, POS and YAW on, ALT off: lever 0.536
# at +0.12 m/s, pedal -0.401. 16:09 take-me-up to 100 m, learner under ALT after 30 s:
#   collective 0.5309, trim long +2.66 / lat -0.86 at inner_kp 0.060 (generic, unswept)
# Pedal in that hover -0.395 — one half of the feedforward pair, entered with its slope.
# The governor does NOT read the hardware lever (the HC-02's did): lever at 0.000 through
# the whole take-me-up, rotor 408.1, throttle 0.84-0.89, 2.0 m/s climb at collective 0.572
# with manifold 22 of 26.5-29.9 inHg.
const collective.hover_collective = 0.531
const rotor.design_rpm = 408


# inner_kp swept once, 2026-10-13 18:39 (laptop, fm 6, still air, 107 m AGL, all three
# assists, hands off, inner_kd 0), steps of 0.010. Roll rate p90 deg/s per step:
#   up    0.060-0.190 quiet (0.02-0.15, 4-15 s each); 0.200 lifts to 0.62; 0.210 breaks, 5.33
#         with the roll correction at authority (0.30)
#   down  0.200 14.3, 0.190 14.6, 0.180 12.9, 0.170 10.1 — all at authority, not decaying;
#         0.160 decays 8.8 -> 0.9 deg/s peak in 18 s; 0.150 quiet (0.44, the tail of it)
# Roll rings, pitch follows at about a fifth. A wide band like the AW109's: onset 0.200
# rising, settles at 0.160 falling. Margin taken from the settling end: 0.160 / 1.3 = 0.123
# -> 0.120. Learned trims at 0.060 and 0.150 differ (+2.66/-0.86 vs +1.84/-0.70), so they
# were re-learned at 0.120.
const cyclic.inner_kp = 0.120

# Trims learned at inner_kp 0.120 (2026-10-13, take-me-up hover, 1012 kg, density altitude
# 529 m, still air, 625 samples over 30 s): long +2.02 / lat -0.64.
const cyclic.hover_trim_long = 2.02
const cyclic.hover_trim_lat = -0.64

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.12, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 6 flights 2026-10-13 .. 2026-10-15: pitch +1.12
# (+1.05 .. +2.02), roll -1.02 (-1.91 .. -0.82). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = 1.12
const cyclic.hover_attitude_lat  = -1.02

# Assistant (§5e), Full, laptop, still air. tools/assistant_check.py flight, high-passed rate
# RMS deg/s pitch / roll (calm < 1.5, rocking > 3.0):
#   kd 0      (2026-10-13 19:04, hover only)  hover 1.55/0.64 "lively", period 1.5 s, never at
#                                             authority; the pilot felt it rock in the taxi
#   kd 0.040  (2026-10-13 19:06, 14 min)      hover 0.48/0.26  straight 0.56/0.71  turn 0.78/1.53
#                                             (turn period 4.2 s: the turn, not the loop)
# The fleet's pattern again; the pilot: "one of the safest Full aircraft".
# Simulator (studio-saitek, 2026-10-13 22:09, fm 8, 31 fps): at 0.040 the airframe vibrated —
# high-frequency roll rate 0.189 against 0.107 on the laptop, the plugin's command no
# rougher — and the pilot took kd down: at 0.020 it fell to 0.055. Straight 1.51/1.15,
# hover 0.70/0.37. 0.020 as on the R66; not flown on the laptop, by the pilot's decision.
const cyclic.inner_kd = 0.020

# Stops in the same flight at the generic attitude_limit 6: room above the trim only 3.0 deg
# (fleet 4.8-7.9). From 45 m/s: 51 s at 0.87 m/s^2, flare 5.5 deg; from 23-24 m/s: 0.76 m/s^2.
# 9, as on the R66, puts the room at 7.0 deg. Flown 2026-10-13 19:28: from 42.8 m/s in 36 s at
# 1.17 m/s^2 (flare 8.4 deg, +29 m kept by the hold), from 23.2 m/s at 1.06 m/s^2 (+6 m).
# cyclic.attitude_limit_deg was 9.0, counted from level. Since #78 every limit counts
# from the hover trim, and the generic 7.5 applies (2026-10-14).
# Lift-lost floor from the power curve (assistant_check.py power, 9 logs): level collective
# 0.550 at 6 m/s, 0.444 at 7, sloping down to 0.344 at 10 — a slope rather than a step.
const collective.assist_lift_lost_below_ms = 7.0
const collective.assist_lift_lost_lead_ms  = 4.0
# Rotor diameter from the .acf: _blad/0/_semilen_SEG 16.5 ft x 2 = 10.06 m.
const rotor.diameter_m = 10.06

# ── Pilot controls ───────────────────────────────────────────────────────────
bind cyclic_pitch = sim/cockpit2/controls/yoke_pitch_ratio   | clamp -1 1
bind cyclic_roll  = sim/cockpit2/controls/yoke_roll_ratio    | clamp -1 1
bind pedal        = sim/cockpit2/controls/yoke_heading_ratio | clamp -1 1
# Same option as the write line below, so read and write share one range.
bind collective   = sim/flightmodel2/engines/prop_pitch_deg[0] | units blade_pitch_deg | clamp 0 1

# ── Rates and attitude ───────────────────────────────────────────────────────
bind roll_rate_deg_s  = sim/flightmodel/position/P
bind pitch_rate_deg_s = sim/flightmodel/position/Q
bind yaw_rate_deg_s   = sim/flightmodel/position/R
bind sideslip_deg     = sim/flightmodel/position/beta

bind pitch_deg   = sim/flightmodel/position/theta | clamp -90 90
bind roll_deg    = sim/flightmodel/position/phi   | clamp -180 180
bind heading_deg = sim/flightmodel/position/psi

# ── Position and motion ──────────────────────────────────────────────────────
bind vertical_speed_ms = sim/flightmodel/position/vh_ind
bind altitude_agl_m    = sim/flightmodel/position/y_agl
bind altitude_msl_m    = sim/flightmodel/position/elevation
# Its never-exceed speed, from the .acf (P acf/_Vne_kts, read 2026-10-13).
bind indicated_airspeed_kt = sim/flightmodel/position/indicated_airspeed
const airframe.vne_kt = 130
bind velocity_east_ms  = sim/flightmodel/position/local_vx
bind velocity_south_ms = sim/flightmodel/position/local_vz
bind position_east_m   = sim/flightmodel/position/local_x
bind position_south_m  = sim/flightmodel/position/local_z

# ── Engine and rotor ─────────────────────────────────────────────────────────
bind rotor_rpm        = sim/cockpit2/engine/indicators/prop_speed_rpm[0]
bind engine_rpm       = sim/cockpit2/engine/indicators/engine_speed_rpm[0]
bind engine_torque_nm = sim/cockpit2/engine/indicators/torque_n_mtr[0]
bind throttle         = sim/cockpit2/engine/actuators/throttle_ratio[0] | clamp 0 1
# A real manifold: 11.1 inHg on the skids at idle, 12.15 with 1.5 deg of blade.
bind manifold_in_hg   = sim/cockpit2/engine/indicators/MPR_in_hg[0]

# ── Write access ─────────────────────────────────────────────────────────────
# Pedal and cyclic: the standard axes with their standard flags (nothing said here).
# Ground test 2026-10-13, pedal under override_joystick_heading: -0.6 held 100 % of passes,
# tail rotor 10.40 deg, +0.6 -> -8.40 deg; X-Plane's mid - prop_dir[0] x total x half range
# predicts 10.40 / -8.40. The yaw rate on the skids says nothing (held by friction).
#
# Collective: blade angle on index 0 behind override_prop_pitch (#71) — the R22's and the
# HC-02's route. Not the plugin's standard prop_ratio_all: index 1 is the tail rotor,
# prop_ratio read [0.0, 0.5] on the skids, so _all read 0.25 with the lever down (the 902X
# and HC-02 trap). Ground test 2026-10-13 through prop_ratio[0]: 0.15 held 100 % of
# passes, blade 0 -> 1.5 deg (0..10 range), manifold 11.1 -> 12.15 inHg.
#
# Without the flag (POINT_pitch_deg[0], the AS350's route) the first take-me-up
# (2026-10-13 16:09, laptop, fm 6) showed #71 in full: the lever raised in the hover in 35
# steps over 6 s, and every step flew one frame on the lever — 36 frames at 0.01-0.30
# against a command of 0.53. Sink to -1.72 m/s, the hold at its ceiling, rotor 418.7 RPM
# (102.6 %), yaw kicks to 3 deg/s.
#
# The script lowers the flag in after_physics, i.e. after the flight model; the plugin
# raises it again before every flight model (AxisOverride::reassert_owned, built for the
# B412). The Web API test above writes and reads between frames and cannot see which one
# the flight model gets — a flight decides it.
#
# Tried behind the flag 2026-10-13 16:18 and crashed: the hold read the flag after the
# flight model, found the script's 0, declared the axis lost and switched off — in every
# frame, re-engaged by the take-me-up in the next. Nobody updated the command, and the
# reassert before the flight model kept the flag up with the lift ramp's last 0.601: a
# 3.3 m/s climb for 40 s. After the abort the blade stood at 0 with the lever at 0.95
# (plugin still owning the axis) — 15 m/s down. 18:00 flown on the flag-free route again:
# #71 in 120 of 590 hold frames while the lever moved, up to 0.39 off the command.
#
# Fixed in the plugin (design-rationale, "Achsverlust an der Wirkung"): the hold judges the
# axis by the blade angle against the command, not by the flag, and lets go at once when it
# loses it. Back behind the flag, to be flown on both rigs.
write collective = sim/flightmodel/engine/POINT_pitch_deg_use[0] | units blade_pitch_deg | flag sim/operation/override/override_prop_pitch
