# Aerospatiale SA 315B Lama (Philip Ubben, v2.5) — single fixed-shaft turbine (Artouste),
# three blades, conventional tail rotor, main rotor turning clockwise seen from above
#
# Read from a running X-Plane 12 over the Web API on 2026-10-23, on the skids with the
# rotor governed at 353.2 RPM (design 353), lever down, 1400 kg (289 kg fuel), still air.
#
# ── Scripts ──────────────────────────────────────────────────────────────────
# plugins/xlua/scripts/Lama/Lama.lua is LuaJIT bytecode; its strings name every dataref it
# looks up. Of the flight controls it references yoke_pitch/roll_ratio (mirrored into
# SA315b/custom/PhilipUbben_yoke_*_ratio, animation), joystick/yoke_heading_ratio and
# POINT_pitch_deg_use[0]. It holds override_throttles (its own governor) and none of the
# joystick overrides. Its tablet "stability" options were all off, and X-Plane's own read
# art_stab_on 0, yaw_damper_on 0, acf_AS*_lo_rate 0, autopilot_on 0.
# The script writes the tail rotor's range at runtime: the .acf says -5 .. 13 deg, the sim
# reads acf_min/max_pitch[1] -5.211 .. 12.789. The plugin reads the range live.
#
# ── From the .acf ────────────────────────────────────────────────────────────
#   _prop/0/_prop_dir      -1     -> right pedal, POSITIVE yaw.torque_per_collective
#   acf/_tail_with_coll    0      -> the sign rule holds (the S-76's exception does not apply)
#   acf/_rotor_mi_rat      0.24   -> the Bell 407's and the S-76's: sweep inner_kp past 0.15
#   _prop/0 pitch          4 .. 13 deg (main, 9 deg of range — narrower than the MD 902's 11)
#   _prop/0/_des_rpm_prp   353    -> 353.2 on the skids, governed
#   one TRB_FIX engine, correlator 0/0/0/0; empty 1021 kg, max 1950 kg
#
# ── Write test 2026-10-23, on the skids, hands off ───────────────────────────
# Pedal: yoke_heading_ratio under override_joystick_heading, held 100 %, flag read back 1;
# -0.6 -> yaw rate -4.0 deg/s, +0.6 -> +4.6. total_heading_ratio equals the pedal (factor 1.0).
# Cyclic: +-0.15 on pitch and roll, value and flag held 100 %, total_*_ratio equals it.
# Collective: prop_ratio[0] = 0.30 -> blade 6.70 deg (4 + 0.30 x 9, exact), torque 1658 ->
# 3320 Nm, rotor 346 -> 352.6 RPM within 1.3 s. The governor answers the load, not the
# hardware lever (joy_mapped_axis_value[5] stood at 0 throughout) — not the HC-02's coupling.
# prop_ratio is [0.0, 0.4996] with the lever down, prop_ratio_all 0.25: index 1 is the tail
# rotor, so the collective never goes through _all.
# Flag: override_prop_pitch = 1 with POINT_pitch_deg_use[0] = 6.0 held at 20 Hz, flag read
# back 1 in every sample, blade 6.0, governor caught it. The tail rotor froze at 3.78 deg.

name      = Aerospatiale SA315B Lama
acf_match = SA315B
icao      = LAMA

# ── Measured constants ───────────────────────────────────────────────────────
# The script moves sim/flightmodel/weight/m_total in flight: 1376 kg on the skids (empty 1021
# + fixed 90 + fuel 265), 1204 in the settled hover, 1064 .. 1381 over one flight, 76 steps
# too large for fuel burn (2026-10-23 19:13). The learner compares the mass at load with the
# mass it learned at, so on this cell it refuses its own values on the ground every time
# ("1376 kg now against 1204 kg"). These three therefore have to live here.

# Settled hover 2026-10-23 19:13 (laptop, fm 8), assistant Full with all three axes, 88.3 m
# AGL (8 rotor diameters), still air, mass read 1204 kg, density altitude 103 m, 30 s from
# 15 s: collective 0.452 (0.4519 .. 0.4523), rotor 352.0. The learner wrote 0.4514.
const collective.hover_collective = 0.452

# The same hover stood on +0.192 of pedal — right, as prop_dir -1 predicts. The anchor half
# of the feedforward pair below.
const yaw.hover_pedal = 0.192

# Collective swept by hand, ALT off, yaw damper on, no speed (2026-10-23 20:12, laptop, 80-310
# m AGL): collective 0 .. 1.0, climb -13.5 .. +17 m/s. Quasi-steady points (collective within
# 0.03 over 1 s, yaw rate under 1 deg/s, ground speed under 2 m/s) with |climb| under 3 m/s:
# pedal = +0.875 * collective - 0.208, R^2 0.964, 232 points over collective 0.12 .. 0.75. At
# the hover's 0.452 it gives +0.187 against the +0.192 measured — five thousandths. All 1096
# points give +0.929 (R^2 0.903) but miss the anchor by 0.14: 552 of them sit at collective 0
# in a -12 m/s descent, where the inflow drives the rotor. Sign as prop_dir -1 predicts.
# Without it, ALT re-engaged at -13.5 m/s stepped the collective to 0.802 and yawed -17.8 deg/s.
const yaw.torque_per_collective = 0.875

# inner_kp and inner_kd, 2026-10-23 (laptop, fm 8, 28 fps, still air, 61 m AGL, Full, hands off).
# At kd 0 (19:29) pitch lifted at 0.095-0.100 and on the way down still rang at 0.070-0.080
# (rate RMS 1.3 deg/s for 7 s each), decaying at 0.060: the onset of a kd-0 cell near 0.07.
# Regressed in that ring: control power 210 / 226 deg/s^2 per unit (pitch / roll), own rate
# damping only -1.1 / -1.4 /s (the S-76: 634 and -9.4 in roll) — the model's period 1.37 /
# 1.32 s matches the flown one. kd adds power x kd of damping, 4.2-4.5 /s at 0.020.
# At kd 0.020 (19:34) every step from 0.060 to 0.300, the slider's end, stayed at 0.01-0.03
# deg/s RMS, high-passed alike (no buzz), correction 0.014 of 0.60. Onset above 0.30 ->
# 0.30 / 1.3 = 0.23, a margin of at least 1.3. The vertical descent that rang at kd 0 (19:13:
# roll +-3 deg, 1.3 s, 7.7-11 deg/s RMS at -3.2 m/s, kp 0.060) stayed at 0.5-0.6 deg/s RMS at
# -4.5 to -5.8 m/s and under 1.5 at -10.7 m/s (19:38). With speed (19:42, Full, to 99 kt
# against VNE 114): high-passed rate RMS pitch / roll hover 0.71 / 0.45, straight 1.49 / 1.48,
# turn 0.95 / 1.47 (22 deg bank at 59 kt) — calm everywhere. On the authority only at 97-99 kt
# with the stick 0.75-0.85 forward. Stops from 98 and 57 kt: 1.63 / 1.45 m/s^2, flare 9.7
# deg, climbing 39 / 9 m. The stick pulse proposed on top was not flown.
#
# Pitch limit (xp_heli_assistent#5): the Lama has no torque gauge; its limit is a maximum
# collective per density altitude on the Collins pitch indicator, 0.80 of the needle at 0 ft
# (0.75 at -3300 .. 1.00 from 13200 ft, aircraft manual EN_Pitch_Indicator.pdf). The needle
# (SA315b/engine/PhilipUbben_pitch_indicator) follows the blade, so under the flag it shows
# the assistant's command, not the lever: about (blade - 3.6) / 7.9 from three close points,
# making 0.80 a command of about 0.66. The hold's ceiling is hover + max_offset = 0.80 and it
# reached it at 74 kt climbing (19:42, 890 frames above 0.66). Only realism while the tablet's
# "Over-Pitch-Fail" is off (the default, and as flown); no profile line can bound it without
# lifting the floor too.
#
# Level-flight collective (7 logs): 0.43-0.45 to 8 m/s, 0.25 at 12, none between; no stop
# sank, so collective.assist_lift_lost_below_ms stays 0 (the tool's starting value: 9 / 4).
const cyclic.inner_kp = 0.23
#
# kd on the simulator rig (Saitek, fm 8, DA 890-950 m), rate RMS pitch / roll, hover / straight / turn:
#   0.020 (21:14, 1255 kg)  0.83/0.26  0.71/0.88  0.51/2.15
#   0.030 (20:51, 1278 kg)  1.31/0.55  0.61/0.81  1.02/1.90  — before the stick had a null zone
#   0.040 (21:25, 1065 kg)  0.44/0.07  0.72/0.50  0.56/2.38
# No buzz at any (second-difference RMS of the rate 0.025-0.031 / 0.069-0.073 deg/s), the turn's
# roll lively at all three — the hand, not kd. The pilot found 0.020 restless there and chose
# 0.030 after a second, unrecorded flight with the stick fixed. Laptop at 0.030 (21:40, 1280 kg,
# 33 fps): hover 0.74/0.41, straight 1.17/1.24, turn 1.47/1.85, stop from 93 kt in 28 s at
# 1.66 m/s^2; whole flight 0.84/1.02 against the simulator's 0.50/0.72 at the same kd — the
# simulator felt restless and moved less (the Lama's camera "vibrations" option is the lead).
const cyclic.inner_kd = 0.030

# Trims learned at inner_kp 0.23, kd 0.020 (2026-10-23 19:38, 61 m, 1171 kg read, 811 samples
# over 30 s): +2.06 / +3.02. At 0.060 they read +1.92 / +2.83 — higher now, not lower, though
# the droop is small either way (correction 0.013: 0.2 deg at 0.060, 0.06 at 0.23); the moved
# mass is a candidate, unmeasured. Inside the generic integral limit of 5.0.
const cyclic.hover_trim_long = 2.06
const cyclic.hover_trim_lat  = 3.02

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.23, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 7 flights 2026-10-23 .. 2026-10-24: pitch +1.57
# (+1.52 .. +2.10), roll +3.22 (+2.78 .. +3.67). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = 1.57
const cyclic.hover_attitude_lat  = 3.22

# Wind (laptop, Full, hands off). The hover leans 3.02 right in still air and the integral limit
# counts from zero (#83), so the right side has 2 degrees, the left 8. Lateral cost measured
# from the left: 21-22 kt took trim_lat from +3.02 to -0.6 .. -1.0 (21:59, 22:08; 0 frames on the
# stop, 1 m in 51 s) — 0.33 deg/(m/s), predicting the stop from the right at 12 kt. Tailwind
# costs 0.26 on the longitudinal axis (stop at about 22 kt). From the right (23:10, 25-30 kt):
# trim_lat on 5.0 from the climb on, 100 % of a level hover at 205 ft in 28 kt (27 across),
# drifting left at 1.6 kt; 3.02 + 0.33 x 14.1 m/s = 7.7 needed. 8.0 as on the AS350 and the
# S-76; the roll it allows stays inside the attitude limit counted from the trim (10.5).
const cyclic.integral_limit_deg = 8.0

# Design rotor speed, the yardstick of the rig check's overspeed line (#47).
# From .acf _prop/0/_des_rpm_prp; 353.2 on the skids, governed (2026-10-23).
const rotor.design_rpm = 353

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 18.08 ft, times two.
const rotor.diameter_m = 11.02

# ── Pilot controls ───────────────────────────────────────────────────────────
bind cyclic_pitch = sim/cockpit2/controls/yoke_pitch_ratio   | clamp -1 1
bind cyclic_roll  = sim/cockpit2/controls/yoke_roll_ratio    | clamp -1 1
bind pedal        = sim/cockpit2/controls/yoke_heading_ratio | clamp -1 1
# The blade angle, mapped back onto 0..1 over acf_min_pitch[0]..acf_max_pitch[0] (4 .. 13).
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
# #76: never-exceed speed from the .acf (P acf/_Vne_kts).
bind indicated_airspeed_kt = sim/flightmodel/position/indicated_airspeed
const airframe.vne_kt = 114
bind velocity_east_ms  = sim/flightmodel/position/local_vx
bind velocity_south_ms = sim/flightmodel/position/local_vz
bind position_east_m   = sim/flightmodel/position/local_x
bind position_south_m  = sim/flightmodel/position/local_z

# ── Engine and rotor ─────────────────────────────────────────────────────────
# Fixed-shaft turbine: engine_speed_rpm reads the rotor's 353.2.
bind rotor_rpm        = sim/cockpit2/engine/indicators/prop_speed_rpm[0]
bind engine_rpm       = sim/cockpit2/engine/indicators/engine_speed_rpm[0]
bind engine_torque_nm = sim/cockpit2/engine/indicators/torque_n_mtr[0]
bind throttle         = sim/cockpit2/engine/actuators/throttle_ratio[0] | clamp 0 1
# Turbine: manifold pressure reads ambient (29.92) and stays unbound.

# #71: behind override_prop_pitch, the route of the R22, R44, Cabri, AS350 and HC-02. The
# script references POINT_pitch_deg_use[0]; whether it lowers the flag after the flight model
# (the R44's script does) the Web API cannot see — the axis-loss check counts at the effect.
# Ground test 2026-10-23: the tail rotor (prop 1) follows 3.79 + 9.0 x total_heading_ratio,
# the plugin's formula with prop_dir[0] = -1: errors -0.011 / +0.009 / -0.025 deg at -1.0 /
# -0.3 / +0.3, -0.14 at +1.0 still travelling after 1.5 s. Not yet flown behind the flag.
write collective = sim/flightmodel/engine/POINT_pitch_deg_use[0] | units blade_pitch_deg | flag sim/operation/override/override_prop_pitch
