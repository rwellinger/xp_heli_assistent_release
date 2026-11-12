# Airbus EC130 B4 (RSG add-on, "EC130 B4 V1.5"). Every path below was read back from a
# running X-Plane 12 on 2026-08-22 with the aircraft loaded, and writing was confirmed
# to reach the flight model on both the pedal and collective axes.
#
# It reads the standard datarefs despite shipping SASL and xlua, which is why it can be
# supported at all — an add-on that routes its controls through custom datarefs could
# not be, however complete its profile.
#
# Its main rotor turns the *other way* than the R22's: torque yaws the nose left and is
# held with right pedal, so the torque feedforward is positive where the R22's is
# negative. Both constants are measured on this airframe; none is carried over.

name      = Airbus EC130 B4
acf_match = EC130
icao      = EC30

# ── Measured constants ───────────────────────────────────────────────────────
const collective.hover_collective = 0.485

const yaw.torque_per_collective = 1.435

# Inner loop gain. **0.075 since 2026-09-29, on X-Plane 12.4.4 b2.** The 0.120 below
# was right on 12.4.3 and is a wobble now: at 2000 kg in still air it read pitch rate
# RMS 11.2 deg/s and 30 % of frames on the authority stop, against 0.20 deg/s and 0 %
# at the same setting on 2026-08-25. 0.080 was quiet, 0.075 quieter: pitch rate RMS
# 0.26, roll 0.34, drift p50 0.01 m/s, 0 % on the stop. The onset has moved from 0.155
# to somewhere below 0.120, and nothing in this plugin's code or in this profile
# changed with it; the 12.4.4 release notes name no helicopter change either. Every
# inner_kp swept before the beta is under the same suspicion (Issue #45).
#
# The original sweep, 2026-08-25 in still air at 50 m, on 12.4.3. It belongs to
# this airframe rather than to the generic defaults because the ceiling is set by
# mass and rotor inertia.
#
# Recorded: 0.120 is indistinguishable from the 0.060 it started at (pitch rate
# p90 0.24 against 0.31 deg/s), and 0.180 is an unmistakable wobble at 4.53.
# Flown afterwards without the recorder running, the onset is at about **0.155** —
# so this sits a factor 1.29 below it, not the 1.5 the recorded steps suggested.
#
# That margin was measured in the kindest condition there is: still air, settled
# hover, the inner loop nowhere near its authority. In wind it works against
# larger deflections and the margin shrinks with it. If the airframe turns nervous
# in weather, 0.100 is the fallback and costs 0.17 degrees of authority.
#
# It is here and not only in the tuning file because the two constants below
# depend on it: the inner loop is pure proportional, so it holds a standing
# attitude error of correction/kp, and the outer integrator settles that far past
# the attitude actually flown. Raising kp from 0.060 to 0.120 halved that error
# and gave the airframe 1.77 degrees of authority against weather where it had
# 0.96. Split them and the preload commands a lean this aircraft does not need.
const cyclic.inner_kp = 0.075

# Rate damping for the assistant, flown 2026-10-08 in Full (assistant_check, rate RMS
# pitch/roll): kd 0 rocked with speed — straight 1.90/1.13 deg/s at 1.1 s, turn 1.27/2.73
# at 2.8 s (19:12); kd 0.020 calm everywhere — hover 0.57/0.26, straight 0.43/0.81, turn
# 0.39/1.16 (19:22, to a landing on the H). The pilot's choice by feel: "nothing to complain
# about". 0.040, where the 902X, AS350 and B412 ended, was not flown here. kd leaves the
# trims alone (no rate in a settled hover).
const cyclic.inner_kd = 0.020

# What the outer integrator settles at — not the attitude the airframe holds.
# Measured 2026-09-29 in still air at inner_kp 0.075, 2000 kg, 416 m density
# altitude, and only valid at that gain: 80 s of settled hover with ALT off,
# drift p50 0.01 m/s (reference_flights/Airbus_EC130_B4/2026-09-29_16-21-06).
# The learned layer took 3.74 / 1.17 over its own 30 s window on the same day.
#
# The figures before were 3.23 / 1.60 at kp 0.120 and 3.97 / 1.75 at kp 0.060 —
# the same quantity, the inner loop's standing error riding on the attitude flown.
const cyclic.hover_trim_long = 3.73

const cyclic.hover_trim_lat = 1.43

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.075, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 6 flights 2026-09-29 .. 2026-10-15: pitch +1.86
# (+1.60 .. +2.41), roll +1.90 (+1.42 .. +2.24). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = 1.86
const cyclic.hover_attitude_lat  = 1.90

# Raised from the generic 6.0 to 11.0 on 2026-10-08 for the assistant's stop. The bound is
# absolute, not from the trim: at +3.73 deg of hover trim 6 left 2.3 deg of nose up, and the
# stop from 21.4 m/s slowed at 0.65 m/s^2, 32 s to a standstill (19:12). 11 gives 7.3, as the
# B412. It bounds the trainer's position hold too, both ways. Unflown at 11.
# cyclic.attitude_limit_deg was 11.0, counted from level. Since #78 every limit counts
# from the hover trim, and the generic 7.5 applies (2026-10-14).
# Design rotor speed, the yardstick of the rig check's overspeed line (issue #47).
# From .acf _prop/0/_des_rpm_prp; 14 reference flights hover at 102.0-103.1 %.
const rotor.design_rpm = 386

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 17.552 ft, times two.
const rotor.diameter_m = 10.70

# Where translational lift goes, for the assistant's floor when slowing down (#54). From the
# level-flight collective of the 15 reference flights above 15 m (tools/assistant_check.py
# power, 2026-10-08): 0.486 at 1 m/s, 0.452 at 4, 0.429 at 5, 0.392 at 9, 0.361 at 11,
# 0.343 at 14 — a slope like the AW139's, not a step, hence the long lead. Unflown.
const collective.assist_lift_lost_below_ms = 5.0
const collective.assist_lift_lost_lead_ms  = 7.0

# ── Bindings ─────────────────────────────────────────────────────────────────
bind cyclic_pitch = sim/cockpit2/controls/yoke_pitch_ratio | clamp -1 1
bind cyclic_roll = sim/cockpit2/controls/yoke_roll_ratio | clamp -1 1
bind pedal = sim/cockpit2/controls/yoke_heading_ratio | clamp -1 1
bind collective = sim/cockpit2/engine/actuators/prop_ratio[0] | clamp 0 1
bind roll_rate_deg_s = sim/flightmodel/position/P
bind pitch_rate_deg_s = sim/flightmodel/position/Q
bind yaw_rate_deg_s = sim/flightmodel/position/R
bind sideslip_deg = sim/flightmodel/position/beta
bind pitch_deg = sim/flightmodel/position/theta | clamp -90 90
bind roll_deg = sim/flightmodel/position/phi | clamp -180 180
bind heading_deg = sim/flightmodel/position/psi
bind vertical_speed_ms = sim/flightmodel/position/vh_ind
bind altitude_agl_m = sim/flightmodel/position/y_agl
bind altitude_msl_m = sim/flightmodel/position/elevation
# #76: indicated airspeed, for the assistant's VNE. Its never-exceed speed, from the .acf
# (P acf/_Vne_kts, read 2026-10-11).
bind indicated_airspeed_kt = sim/flightmodel/position/indicated_airspeed
const airframe.vne_kt = 155
bind velocity_east_ms = sim/flightmodel/position/local_vx
bind velocity_south_ms = sim/flightmodel/position/local_vz
bind position_east_m = sim/flightmodel/position/local_x
bind position_south_m = sim/flightmodel/position/local_z
bind rotor_rpm = sim/cockpit2/engine/indicators/prop_speed_rpm[0]
bind engine_rpm = sim/cockpit2/engine/indicators/engine_speed_rpm[0]
bind engine_torque_nm = sim/cockpit2/engine/indicators/torque_n_mtr[0]
bind throttle = sim/cockpit2/engine/actuators/throttle_ratio[0] | clamp 0 1

# No `write` lines: steered entirely through X-Plane's standard axes, and saying
# nothing here means exactly that.
