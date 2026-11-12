# VSKYLABS Test-Pilot Hungarocopter HC-02 (VSL, v2.0.1) — ultralight, two blades, piston
#
# Read from a running X-Plane 12 over the Web API on 2026-10-11, on the skids with the
# rotor governed at 540 RPM (engine 5348, lever down). Script findings are from
# plugins/xlua/scripts/*/*.lua. VSKYLABS also built the Cabri G2, the R66 and the 902X — a
# lead for the control chain, never a conclusion.
#
# ── No script holds an override flag ─────────────────────────────────────────
# None of the six xlua scripts touches override_joystick*, override_prop_pitch or any
# copilot dataref, and all of those flags read 0 on the ground. The standard axes are the
# way in for cyclic and pedals.
#
# ── Two engines: the second is the electric ERS ──────────────────────────────
# Engine 0 is the piston (RCP_INJ), engine 1 an electric motor (ELE): the ERS, a battery
# emergency drive switched on by a push-button (hc02_ers.lua; throttle_ratio[1] is 0
# otherwise). prop_ratio on the skids with the lever down read [0.0, 0.5, ...], so
# prop_ratio_all read 0.25 — the 902X trap again. The plugin's standard collective target
# is prop_ratio_all; on this airframe the collective is written as a blade angle on index 0
# instead (the R22's route), see the write line below.
#
# ── Stabilisation ─────────────────────────────────────────────────────────────
# artificial_stability_on 1 and yaw_damper_on 1 as found, with the artificial-stability
# rates at 0.005 (pitch, roll, heading). No script writes them and the cockpit has no switch
# for them. Every constant here is conditional on that state.
#
# No autopilot: no panel for one (pilot, 2026-10-11), autopilot_mode 0 and servos_on 0, the
# .acf mentions it only in X-Plane's stock failure entries. X-Plane's own AP still exists
# behind its commands — a key bound to one would put a second controller on the axes.
#
# The pedal reaches the flight model scaled: total_heading_ratio = 1.25 x yoke_heading_ratio
# (-0.6 -> -0.747, +0.6 -> +0.750, ground test 2026-10-11), no offset. Source not found in
# the .acf rudder ratios (all 1.0). The tail rotor follows total_heading_ratio, not the pedal.
#
# ── From the .acf, before flying ─────────────────────────────────────────────
#   _prop/0/_prop_dir      +1     -> left pedal, NEGATIVE yaw.torque_per_collective
#   acf/_rotor_mi_rat      0.36   -> plan to sweep inner_kp past 0.15
#   _prop/0 pitch          0 .. 12.5 deg (main),  _prop/1 -7 .. 12 deg (tail)
#   _prop/0/_des_rpm_prp   570    -> checked against the hover below (541, 94.9 %)
#   mass on the ramp as loaded 540 kg (empty 727.5 lb / 330 kg, MTOW 1322.7 lb / 600 kg)
#
# Governor: the add-on's switch (custom_slider_on[18]) drives governor_on[0]; a boost
# switch raises the governed engine speed to 103 %. Measure with the governor ON, boost OFF.

name      = VSKYLABS Hungarocopter HC-02
acf_match = VSL HC02
icao      = HC02

# Procedure: docs/adding-an-aircraft.md.
#
# First flight 2026-10-11 22:48 (laptop, Thrustmaster, fm 6, still air, 538.7 kg, density
# altitude 428 m): climbed by hand with POS and YAW from the student window, hover at 102 m
# AGL from 119 to 139 s, vertical speed within 0.05 m/s, ground speed 0.0, lever held by hand
# (ALT off, so the learner had nothing to take).
#   collective 0.675 (p10 0.671, p90 0.675)  pedal -0.415, left as prop_dir +1 predicts
#   trim long +1.34 / lat -2.48 at inner_kp 0.060 (see the sweep below for 0.095)
#   rotor 541 RPM = 94.9 % of the .acf's 570, governed (engine 5356), so 570 stands
# The hover pedal is not entered: it is one half of the feedforward pair, and the slope
# still needs its sweep.
const collective.hover_collective = 0.675
const rotor.design_rpm = 570

# inner_kp swept twice, 2026-10-11 23:32 and 23:35 (laptop, fm 6, still air, 100 m AGL,
# all three assists, hands off, inner_kd 0). Pitch rate peak-to-peak per 2 s, deg/s:
#   sweep 1 up    0.060-0.120 quiet (p90 0.20-0.62), 0.130 for 16 s steady near 1.0, not
#                 growing; 0.140 GROWS, 0.76 -> 2.47 in 12 s, period ~1.2 s
#   sweep 2       0.145 grows 0.47 -> 2.72 in 8 s; down: 0.125 2.75 -> 2.28 (4 s, decaying),
#                 0.115 1.35 -> 0.70, 0.105 1.28 -> 0.24, 0.100 and below at the floor 0.3-0.7
# Pitch rings, roll follows at about half. Onset 0.140 rising, settles from 0.125 falling —
# no wide band (the AW109's ran 0.200 -> 0.125). Margin taken from the settling end:
# 0.125 / 1.3 = 0.096 -> 0.095. The steps down were 4-8 s, not the 20-30 the procedure asks;
# the 16 s at 0.130 that never grew is what supports the top of the band.
const cyclic.inner_kp = 0.095

# Assistant (§5e), Full, laptop, still air. tools/assistant_check.py flight, high-passed rate
# RMS deg/s pitch / roll (calm < 1.5, rocking > 3.0):
#   kd 0      (2026-10-11 23:55, 613 s)  hover 1.64/0.68  straight 2.15/1.96  turn 1.17/2.85
#                                        "lively", period 1.1-1.4 s, never at authority
#   kd 0.020  felt between the two, not recorded
#   kd 0.040  (2026-10-12 00:11)         hover 0.70/0.05  straight 0.56/0.49  turn 0.53/0.74
# The fleet's pattern (902X, AS350, B412): rocking grows with speed, kd 0.040 takes it out.
# Pilot's choice 0.040.
const cyclic.inner_kd = 0.040

# Trims: measured +1.34 / -2.48 by hand at inner_kp 0.060 (22:48) and +1.40 / -2.58 in the
# hold (23:07, correction pitch +0.123, roll -0.013). Lean + correction/kp, so at 0.095 the
# pitch droop falls from 2.05 to 1.29 deg and roll from -0.21 to -0.14:
#   predicted at 0.095   long +0.64   lat -2.50
# Measured by the learner at 0.095 (23:39, 536 kg, 30 s settled): long +0.74 / lat -2.45 —
# 0.10 and 0.05 deg from the prediction, so the droop arithmetic holds on this cell.
const cyclic.hover_trim_long = 0.74
const cyclic.hover_trim_lat  = -2.45

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.095, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 8 flights 2026-10-11 .. 2026-10-15: pitch -0.23
# (-0.66 .. +0.75), roll -2.01 (-2.61 .. -0.82). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = -0.23
const cyclic.hover_attitude_lat  = -2.01
#
# trim_lat follows the collective: -3.0 in a 3.5 m/s climb, -1.1 to -1.4 descending at 5 m/s
# (23:39), the tail rotor's sideways push. Long stays within 0.05 throughout.

# Torque feedforward. Deliberate collective sweep 2026-10-11 23:39 (laptop, still air, ALT
# off, POS and YAW on, ground speed under 1 m/s, above 20 m): four climbs and descents by
# hand between collective 0.41 and 0.84.
#   all frames                pedal = -1.642 x coll + 0.697   r -0.989  n 3864
#   |yaw rate| < 0.3 deg/s    pedal = -1.635 x coll + 0.694   r -0.997  n 2659
#   collective steady 2 s     pedal = -1.652 x coll + 0.705   r -0.999  n 1825
# Negative, as prop_dir +1 says. The line at the hover collective 0.675 gives -0.410; the
# hand hover at 22:48 stood on -0.415 and this recording's hover on -0.420 at 0.679.
const yaw.torque_per_collective = -1.65
const yaw.hover_pedal           = -0.415

# Climb limit. The pilot gets RPM LOW above about 720 ft/min (3.7 m/s) by hand, lever =
# collective, so it is power and not the governor coupling: 3.36-3.59 m/s at collective
# 0.754-0.769 drooped the rotor 1.7-4.4 % with manifold pressure on its 39.9 inHg ceiling.
# (analyze_flight_log.py calls that COMFORTABLE — it watches throttle only on a manifold,
# and here the throttle is not where it ends; the flight wins.) The altitude hold may ask
# for 5 m/s by default.
const collective.max_climb_ms = 3.0

# Translational lift. tools/assistant_check.py power over the archive, split by weight
# (2026-10-12; mixed, the 100 kg between them reads as a slope). Level collective above 15 m
# by ground speed:
#   535-540 kg (15 logs): 1-6 m/s 0.669-0.697, 7 0.629, 8 0.567, 10 0.505, 11 0.451, 12 0.438
#   435-437 kg  (2 logs): 0-6 m/s 0.537-0.584, 7 0.483, 8 0.479, 10 0.384, 11 0.356, 12 0.350
# Both flat to 6 m/s and falling from 7 to 11-12: a step at 7 over about 5 m/s, which the
# tool reads as 7/5 (heavy) and 7/4 (light). The first value, 4/8, came from the heavy logs
# alone with no bins at 4-6. Not flown against a decelerating sink: both stops of
# 2026-10-12 21:11 braked at 0.9 m/s^2 and climbed 5.9 and 7.5 m, never asking for it.
const collective.assist_lift_lost_below_ms = 7.0
const collective.assist_lift_lost_lead_ms  = 5.0
#
# Climb capacity, same flight: 3.6 m/s for 47 s at collective 0.754, rotor down 0.7 %,
# 0.25 of lever left, manifold 40.3 inHg. The generic sequence climb of 2.0 is not entered.

# Rotor diameter from the .acf: _blad/0/_semilen_SEG 11.48 ft x 2 = 7.00 m.
const rotor.diameter_m = 7.00

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
# Its never-exceed speed, from the .acf (P acf/_Vne_kts, read 2026-10-11).
bind indicated_airspeed_kt = sim/flightmodel/position/indicated_airspeed
const airframe.vne_kt = 100
bind velocity_east_ms  = sim/flightmodel/position/local_vx
bind velocity_south_ms = sim/flightmodel/position/local_vz
bind position_east_m   = sim/flightmodel/position/local_x
bind position_south_m  = sim/flightmodel/position/local_z

# ── Engine and rotor ─────────────────────────────────────────────────────────
# Piston, index 0. Index 1 is the ERS motor and is not bound.
bind rotor_rpm        = sim/cockpit2/engine/indicators/prop_speed_rpm[0]
bind engine_rpm       = sim/cockpit2/engine/indicators/engine_speed_rpm[0]
bind engine_torque_nm = sim/cockpit2/engine/indicators/torque_n_mtr[0]
bind throttle         = sim/cockpit2/engine/actuators/throttle_ratio[0] | clamp 0 1
# A real manifold: 14.6 inHg on the skids at idle, 15.4 with 2 deg of blade.
bind manifold_in_hg   = sim/cockpit2/engine/indicators/MPR_in_hg[0]

# ── Write access ─────────────────────────────────────────────────────────────
# Pedal and cyclic: the standard axes with their standard flags (nothing said here).
# Ground test 2026-10-11, pedal under override_joystick_heading: -0.6 held 100 % of passes,
# tail rotor 9.63 deg, +0.6 -> -4.65 deg; X-Plane's mid - prop_dir[0] x total x half range
# predicts 9.60 / -4.62. The yaw rate on the skids says nothing (lever down, held by friction).
#
# Collective: blade angle on index 0 behind override_prop_pitch (#71). Ground test
# 2026-10-11, both routes held 2.0 deg on the main rotor for 4 s (MPR 14.6 -> 15.4, torque
# 30 -> 35 Nm); under the flag the tail rotor stood frozen at 2.5 deg, which the plugin
# covers by writing it from total_heading_ratio.
#
# Without the flag the first take-me-up (2026-10-11 22:54) lost the handover: the lever,
# left down through the whole sequence, was raised towards the commanded 0.709, and a lever
# moving in every frame took the blade in every frame — six frames in a row at 0.02-0.12.
# The cell sank at 4.5 m/s, the hold ran to 1.000 and gave the axis up ("command not
# followed"). A light cell pays for #71 in height, not in rotor shake.
#
# Behind the flag (2026-10-11 23:07, laptop, fm 6): the lever raised from 0 to 0.653 in the
# hold, 78 lever changes, not one frame off the command.
#
# The governor takes its base throttle from the HARDWARE lever, not from the blade angle and
# not from prop_ratio (.acf _correlator_interp 0/0/0.8/0.55, _custom_govnr 1). Same flight,
# hold at 100 m, lever moved with the blade standing still: lever 0.000 -> throttle 0.894,
# engine 5202, rotor 525 (92.1 %, the cockpit's red arc and RPM LOW), collective 0.706;
# lever 0.653 -> throttle 0.467, engine 5353, rotor 541 (94.9 %), collective 0.670. With the
# lever left down, the climb at 0.750 made 2.0 m/s at rotor 523 against 3.6 m/s by hand.
#
# Not fixable from here: writing prop_ratio[0] = command every frame under the flag was
# built and flown (23:19) and changed nothing. A diff of 791 datarefs with the lever down
# and up (hover at 19 m, 23:2x) moved exactly one input, joy_mapped_axis_value[5]
# (1.000 -> 0.351, the raw axis), which is read-only. Only override_throttles with a
# governor of our own would reach it, and that is out of proportion. The ERS motor's speed
# follows the lever too (engine 1, 2287 -> 1055 RPM, power under 15 W) — noted, not used.
#
# So on this cell: the take-me-up works but climbs in the red arc with the lever down (a
# lever moved during the sequence aborts it, pilot_input). Bring the lever to the LEVER
# line once the hold has the aircraft. In the assistant the lever position is the command,
# so it stands near hover power anyway. The R22 shows the same coupling in its throttle
# (0.28 lever off, 0.43 matched) but its governor holds 530 either way.
write collective = sim/flightmodel/engine/POINT_pitch_deg_use[0] | units blade_pitch_deg | flag sim/operation/override/override_prop_pitch
