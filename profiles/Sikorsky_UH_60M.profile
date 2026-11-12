# Sikorsky UH-60M Black Hawk (free, melbo @x-plane.org, v0.9.8) — twin turbine, four blades,
# conventional tail rotor, wheels
#
# Read from a running X-Plane 12 over the Web API on 2026-10-29, on the wheels with the
# rotor governed at 258 RPM, lever down, 7417 kg. Preparation and predictions:
# docs/onboarding-uh60m.md.
#
# ── Scripts ──────────────────────────────────────────────────────────────────
# plugins/UH60M: SASL 3.23.2, every module encrypted (.secured) — nothing can be read. As
# found, every sim/operation/override/* flag stands at 0. The add-on's own AFCS was off:
# uh60m/sys/sas1 0, sas2 0, fps_on 0, trim_on 0 (acf_config.ini says the same). The
# stabilator was on automatic (uh60m/sys/hstab_auto 1) — a script that moves it with speed.
# acf/_stab_* all 0, acf/_auto_trim_EQ 0.
#
# ── From the .acf ────────────────────────────────────────────────────────────
#   _prop/0/_prop_dir      +1     -> left pedal, NEGATIVE yaw.torque_per_collective — but
#   acf/_tail_with_coll    5 deg  -> the tail rotor follows the collective, as on the S-76,
#                                    where the sign rule missed
#   acf/_rotor_mi_rat      0.50   -> the R22's, the Cabri's and the MD 902's; sweep anyway
#   _prop/0 pitch          -3.7 .. 16 deg at runtime (the .acf field reads -2.5), tail -22 .. 22
#   _prop/0/_des_rpm_prp   400    -> the rotor reads 258 governed, the real UH-60's Nr
#   two TRB_FRE engines, correlator 0/0/0/0; empty 12511 lb (5675 kg), max 22000 lb (9979 kg)
#
# ── Write test 2026-10-29, on the wheels, hands off ──────────────────────────
# probe_aircraft.py --write-test, prop_ratio[0] alone. Pedal -0.6 held 100 %, yaw rate
# -26.5 deg/s: the aircraft turned 55 deg left on its wheels (heading 159 -> 104).
# Collective +0.15 held 100 %; repeated alone with probe_dataref.py hold: blade -3.70 ->
# -0.745 deg (exactly linear over acf_min/max_pitch), torque 6200 -> 6925 Nm, rotor 258
# steady, no lift, and the TAIL rotor's blade 0.02 -> 0.76 deg (0.15 x 5 deg of
# _tail_with_coll). prop_ratio [0.0, 0.50]: index 1 is the tail rotor, prop_ratio_all reads
# 0.25 with the lever down — never the collective here.

name      = Sikorsky UH-60M
acf_match = UH60M
icao      = UH60M

# ── Measured constants ───────────────────────────────────────────────────────
# Settled hover 2026-10-29 12:08 (reference_flights/Sikorsky_UH_60M, laptop, fm 8), assistant
# Full, 62.4 m AGL (4 rotor diameters, out of ground effect), still air, 7392 kg, density
# altitude 430-490 m, inner_kp 0.060 (generic). 25 s, height 62.40..62.47, drift 0.00:
#   collective 0.507 (0.505..0.508), pedal -0.115 (left, as _prop_dir +1 says), attitude
#   +5.04 / -3.26 deg, rotor 258.00, torque 28380 Nm. The learner took 0.5063 / +4.57 / -3.77
#   over 30 s in the same hover, at inner_kp 0.060 — the trims hang on the gain and are
#   learned again at the swept one before they go in.
const collective.hover_collective = 0.507

# inner_kp swept once, 2026-10-29 12:14 (laptop, fm 8, still air, 91 m AGL, 7356 kg, Full,
# hands off, inner_kd 0). Roll rings, pitch follows at about a tenth, period 1.1-1.2 s.
#   up    0.060-0.130 quiet (roll rate RMS <= 0.18 deg/s, 3-10 s each); 0.140 lifts to 0.45;
#         0.150 breaks: roll rate p-p 2.7 -> 9.2 deg/s in 8 s
#   down  0.140 and 0.130 still growing, at authority; 0.120 peaks (p-p 28) and decays
#         slowly (-> 23 in 6 s); 0.110 decays (20.6 -> 3.0 in 16 s); 0.100 quiet (0.05)
# The down steps were 5-7 s (16 s at 0.110), shorter than §4a asks; the 2 s windows read
# one continuous decay from 79 s on, so the settling end stands at 0.110. Margin from there:
# 0.110 / 1.3 = 0.085. Prediction 2 of docs/onboarding-uh60m.md held (0.06-0.10, not mi_rat).
# One sweep only — a soft number until the second.
#
# Second sweep on the kd 0.020 step, 2026-10-29 14:21 (laptop, still air, hover, Full, hands
# off): 0.085, 0.14, 0.15, 0.18, 0.21, 0.25, 0.29 at 0.01-0.04 deg/s RMS, 0.30 (18 s) at
# 0.11 / 0.06 — no onset up to the slider's end, as on the Lama. Steps 2-10 s, shorter than
# §4a asks. In flight 0.23 (0.30 / 1.3) was very restless by the pilot's judgement (not
# recorded); 0.15 flew soft and calm. The hover sweep does not see the onset with speed
# (§5e), so the flown figure stands: 0.15.
# The 14:35 circuit at 0.15 (laptop, Full) against the 12:30 one at 0.085: high-passed roll
# rate RMS straight 1.82 vs 0.88, turn 2.30 vs 0.64 deg/s, hands off above 60 kt 0.61 vs
# 0.29 — twice as lively everywhere, still under 3. 0.12 tried as the middle.
# Simulator rig at 0.12: without the collective flag (15:49) the turn rocked at 4.16 deg/s
# roll, the 8-bit lever jolting the rotor; behind the flag (18:07) hover 0.44 / 0.06,
# straight 0.48 / 1.12, turn 0.40 / 1.33 — calm, and the pilot felt it. The rocking was the
# lever, not the gain. Laptop flight behind the flag still to come.
const cyclic.inner_kp = 0.12

# Learned 2026-10-29 18:07 (simulator, Full, inner_kp 0.12 / kd 0.020, 63 m AGL, still air,
# 7101 kg, density altitude 539 m): LEARNED 0.4944 / +5.02 / -3.55. In force from 18:36: stop
# from 85 kt hands off in 29 s at 1.48 m/s^2, flare 13.1 deg, against 63-69 s at 0.65 and
# 8.1 deg with no trim (18:07) — the attitude limit counts from the trim (#78).
const cyclic.hover_trim_long = 5.02
const cyclic.hover_trim_lat  = -3.55

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.12, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 2 flights 2026-10-29 .. 2026-10-29: pitch +5.26
# (+5.24 .. +5.28), roll -3.44 (-3.56 .. -3.31). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = 5.26
const cyclic.hover_attitude_lat  = -3.44

# The anchor half of the feedforward pair, from the 12:08 hover above.
const yaw.hover_pedal = -0.115

# Collective sweep by hand 2026-10-29 12:22 (laptop, still air, 7250 kg, ALT off, yaw on,
# ground speed < 1 m/s), 96-193 s. Two vortex ring episodes in it (sink to -18 m/s, rotor
# down to 221) are left out, as is every frame with |vs| >= 3 m/s, rotor off 258 by 5 or
# more, |yaw rate| >= 1: 774 frames, collective 0.33..0.61, slope -0.642 (r -0.89), halves
# -0.679 / -0.624, through -0.110 at hover_collective (anchor -0.115). The unfiltered fits
# run -0.67..-0.79. Negative, as _prop_dir +1 says; _tail_with_coll 5 did not flip it.
const yaw.torque_per_collective = -0.65

# inner_kd 0.020, set by the pilot after a descent that felt unsteady at kp 0.100 / kd 0
# (not recorded). The 12:22 hover at kp 0.100 / kd 0.020: rate RMS 0.26 / 0.14, calm.
# kd itself not swept; kp swept on it once (14:21, above).
const cyclic.inner_kd = 0.020

# The generic 5.0 binds in still air. 2026-10-29 12:30 (laptop, kp 0.085 / kd 0.020, no trim
# preload, 7120-7160 kg): in all three settled hovers (130-148 s, 306-313 s, 413-425 s) the
# pitch integrator stood at exactly +5.00 against an attitude of +5.2..+5.3; lateral
# -3.44..-4.27. 8.0 as on the S-76, the AS350, the B206 and the Lama. The trims go in once a
# hover below the new limit has been learned.
const cyclic.integral_limit_deg = 8.0

# Design rotor speed, the yardstick of the rig check's overspeed line (#47). NOT the .acf's
# _des_rpm_prp 400: governed 258.00 (257.99..258.05) in the 12:08 hover, 258.9 on the wheels.
const rotor.design_rpm = 258

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 25.54 ft, times two.
const rotor.diameter_m = 15.57

# ── Pilot controls ───────────────────────────────────────────────────────────
bind cyclic_pitch = sim/cockpit2/controls/yoke_pitch_ratio   | clamp -1 1
bind cyclic_roll  = sim/cockpit2/controls/yoke_roll_ratio    | clamp -1 1
bind pedal        = sim/cockpit2/controls/yoke_heading_ratio | clamp -1 1
# The blade angle, mapped back onto 0..1 over acf_min_pitch[0]..acf_max_pitch[0], as on the
# S-76. prop_ratio_all is the mean over both rotors.
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
const airframe.vne_kt = 193
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

# Behind override_prop_pitch, as the AS350 (#75). Without it every hardware lever change
# flew one frame on the lever (#71), and the simulator rig's 8-bit Saitek lever, which
# flickers at rest, made that felt: 2026-10-29 15:49 (Full, kp 0.12), the rotor stood on the
# lever in 7.3 % of the hold's frames, jumps median 0.17, p90 0.42, max 0.72 of the travel
# (the laptop's 10-bit lever at 14:35: 2.2 %, median 0.10).
# The flag freezes the tail rotor too, and here it follows the collective (acf_tail_with_coll
# 5 deg). Ground test 2026-10-29 with the flag down: tail = pedal share + 5 x collective,
# exact at 0.1 / 0.2 / 0.3 and additive with the pedal; the plugin writes it that way since
# (BladePitchRange::tail_rotor_pitch). With the flag: ground test of the tail rotor and a
# flight on each rig still to come.
write collective = sim/flightmodel/engine/POINT_pitch_deg_use[0] | units blade_pitch_deg | flag sim/operation/override/override_prop_pitch
