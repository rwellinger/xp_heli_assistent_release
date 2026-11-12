# Sikorsky S-76C (Laminar default) — twin turbine, four blades, conventional tail rotor
#
# Read from a running X-Plane 12 over the Web API on 2026-10-21, on the wheels with the
# rotor governed at 313 RPM (design 313), lever down, 4771 kg. Preparation and predictions:
# docs/onboarding-s76.md.
#
# ── Scripts ──────────────────────────────────────────────────────────────────
# plugins/xlua/scripts: s76_landgear, s76_throttles (fuel levers, throttle_ratio_all,
# rotor brake on flight start), s76_autopilot (only the IAS button). None of them touches a
# flight control or an override flag. autopilot_on 0, servos_on 0;
# artificial_stability_on 1 and yaw_damper_on 1 as found, with every acf/_stab_* at 0.
#
# ── From the .acf ────────────────────────────────────────────────────────────
#   _prop/0/_prop_dir      +1     -> left pedal, NEGATIVE yaw.torque_per_collective
#   acf/_rotor_mi_rat      0.24   -> sweep inner_kp past 0.15
#   _prop/0 pitch          -2.2 .. 10 deg (main),  _prop/1 -12 .. 12 deg (tail)
#   _prop/0/_des_rpm_prp   313    -> 313.0 on the wheels, governed
#   two TRB_FRE engines, correlator 0/0/0/0; empty 3435 kg, max 5307 kg
#
# ── Write test 2026-10-21, on the wheels, hands off ──────────────────────────
# Pedal: yoke_heading_ratio -0.6 under override_joystick_heading, held 100 %; yaw rate
# -16 deg/s within 0.3 s (aborted at 8). total_heading_ratio read -0.97 for -0.6 — the
# pedal reaches the flight model scaled by about 1.6 (R44: 1.16). Not yet explained.
# Collective: prop_ratio[0] = 0.15, held 100 %; blade -2.2 -> -0.37 deg (exactly linear over
# the range), torque 2845 -> 3642 Nm, tail rotor unaffected, no lift.
# probe_aircraft.py --write-test was NOT used: it nudges prop_ratio_all, which here moves
# the tail rotor too (prop_ratio [0.0, 0.50] -> _all 0.25 with the lever down).

name      = Sikorsky S-76C
acf_match = Sikorsky S-76
icao      = S76

# ── Measured constants ───────────────────────────────────────────────────────
# Settled hover 2026-10-21 19:46 (reference_flights/Sikorsky_S_76C, laptop, fm 8), assistant
# Full with all three axes, 41.5 m AGL (3 rotor diameters, out of ground effect), still air,
# 4755 kg, density altitude 43 m. 33 s, 1024 rows, height and drift both 0.0:
#   collective 0.670 (0.668..0.671), pedal +0.042, attitude +6.11 / -2.72 deg,
#   outer target +5.14 / -3.81 deg with the pitch integrator AT its limit of 5.0.
# The first flight (19:42) hovered at 0.638 in ground effect at 4-6 m and stuck in the
# lift-off ramp: with the generic 0.40 it pulled only to 0.50, where the wheels go light.
const collective.hover_collective = 0.670

# The tail rotor follows the collective: acf/_tail_with_coll = 11 deg over the full lever, the
# only airframe installed with it. The hover takes +0.04 of pedal — right, not the left that
# _prop_dir +1 predicts on every other cell — and the slope is still to be swept. This is the
# anchor half of the feedforward pair; without yaw.torque_per_collective it does nothing.
const yaw.hover_pedal = 0.042

# inner_kp swept once, 2026-10-21 20:29 (laptop, fm 8, still air, 49.6 m AGL, 4628 kg, Full,
# hands off, inner_kd 0). Roll rings, pitch follows at about a thirtieth.
#   up    0.060-0.260 quiet (roll rate RMS <= 0.09 deg/s, 3-8 s each); 0.270 lifts to 0.15;
#         0.280 breaks: roll p90 0.8 -> 22 deg/s in 12 s, period 0.5 s, correction at 0.60
#   down  0.270 and 0.260 at authority, not decaying; 0.250 decays slowly (p90 27 -> 14 in
#         14 s); 0.240 decays to 0.08 in 20 s; 0.230 quiet (RMS 0.17)
# Prediction 2 of docs/onboarding-s76.md held: rotor_mi_rat 0.240 like the Bell 407, and the
# sweep reads like its twin — roll alone, ringing at 0.280, settling at 0.220 there and 0.240
# here (the Bell's upward onset was never measured: it jumped from 0.130 to 0.280). Margin from the settling end:
# 0.240 / 1.3 = 0.185 -> 0.180. One sweep only — a soft number until the second.
const cyclic.inner_kp = 0.180

# inner_kd 0.020, set by the pilot in flight 2026-10-21 (laptop, still air, Full). At kp 0.180
# and kd 0 the roll axis rang from at least 56 kt up (log started late): p90 38-42 deg/s
# from 79 to 134 kt, period 0.6 s, the correction on assist_authority 0.60 (21:06). At kd
# 0.020 (21:10): high-passed rate RMS pitch / roll hover 1.38 / 0.38, straight 0.19 / 1.37,
# turn 1.57 / 1.12; roll p90 0.14-0.36 deg/s at 40-140 kt outside the turn, at authority in
# 13 frames. The 0.6 s period and the small median correction (0.07) matched the AW139, where
# kd made it worse — here it did not; the pilot's flight decided it. 0.040 not flown. At kp
# 0.060 and kd 0 (19:52) the same speeds were calm: the hover sweep's gain needs kd with speed.
const cyclic.inner_kd = 0.020

# Trims learned at inner_kp 0.180 (2026-10-21 before 20:55, laptop, settled hover, 4641 kg,
# density altitude 78 m, still air, 1141 samples over 30 s): +6.26 / -3.63. At the generic
# 0.060 the outer target had read +5.14 / -3.81 at an attitude of +6.11 / -2.72 — the droop
# a gain three times higher takes away. The same hover put the collective at 0.658, which
# fits the 114 kg less than at 0.670. The preload counts against the integral limit, hence
# 8.0 as on the AS350 and the B206 (the generic 5.0 bound at the old gain).
const cyclic.hover_trim_long    = 6.26
const cyclic.hover_trim_lat     = -3.63

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.18, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 3 flights 2026-10-21 .. 2026-10-24: pitch +6.48
# (+6.12 .. +6.57), roll -3.19 (-3.47 .. -2.98). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = 6.48
const cyclic.hover_attitude_lat  = -3.19
const cyclic.integral_limit_deg = 8.0

# The hold's floor is hover_collective - max_offset. With the generic 0.35 that is 0.32 (about
# 1.7 deg of blade), and both stops from speed on 2026-10-21 19:52 sat on it: from 74 m/s the
# flare climbed 120 m at up to 5.7 m/s, from 57 m/s 76 m with the lever fully down asking for
# -5 m/s. 0.60 puts the floor at 0.07, near the -2.2 deg stop. To be re-flown.
const collective.max_offset = 0.60

# Design rotor speed, the yardstick of the rig check's overspeed line (#47).
# From .acf _prop/0/_des_rpm_prp; 313.0 on the wheels, governed (2026-10-21).
const rotor.design_rpm = 313

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 22.000 ft, times two.
const rotor.diameter_m = 13.41

# ── Pilot controls ───────────────────────────────────────────────────────────
bind cyclic_pitch = sim/cockpit2/controls/yoke_pitch_ratio   | clamp -1 1
bind cyclic_roll  = sim/cockpit2/controls/yoke_roll_ratio    | clamp -1 1
bind pedal        = sim/cockpit2/controls/yoke_heading_ratio | clamp -1 1
# The blade angle, mapped back onto 0..1 over acf_min_pitch[0]..acf_max_pitch[0], as on the
# R22. prop_ratio_all is the mean over both rotors and reads 0.25 with the lever down.
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
const airframe.vne_kt = 155
bind velocity_east_ms  = sim/flightmodel/position/local_vx
bind velocity_south_ms = sim/flightmodel/position/local_vz
bind position_east_m   = sim/flightmodel/position/local_x
bind position_south_m  = sim/flightmodel/position/local_z

# ── Engine and rotor ─────────────────────────────────────────────────────────
# Index 0 is the first of two turbines; the torque is that engine's share.
bind rotor_rpm        = sim/cockpit2/engine/indicators/prop_speed_rpm[0]
bind engine_rpm       = sim/cockpit2/engine/indicators/engine_speed_rpm[0]
bind engine_torque_nm = sim/cockpit2/engine/indicators/torque_n_mtr[0]
bind throttle         = sim/cockpit2/engine/actuators/throttle_ratio[0] | clamp 0 1
# Turbines: manifold pressure reads ambient (29.92) and stays unbound.

# The main rotor's lever only. The standard target, prop_ratio_all, would write the tail
# rotor's prop_ratio[1] as well. No flag yet: override_prop_pitch freezes the tail rotor too,
# and a cell gets the flag only after a ground test of its tail rotor and a flight (#71).
# Until then every hardware lever change flies one frame on the lever.
write collective = sim/cockpit2/engine/actuators/prop_ratio[0]
