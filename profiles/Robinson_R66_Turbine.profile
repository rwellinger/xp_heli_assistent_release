# Robinson R66 Turbine (VSKYLABS). Probed against a running X-Plane 12 on 2026-08-24
# with the aircraft loaded on the ground: every parameter a profile has to bind reads,
# and of 7507 datarefs exactly one carries the add-on's own namespace
# (vskylabs/r66/doors_combined). Nothing about the controls is custom, which is what
# makes it supportable.
#
# Writing reaches the flight model on both axes. The pedals moved the yaw rate from
# -0.001 to -4.66 deg/s; the collective proved it the expensive way, lifting the
# aircraft off its skids at 0.40 with the rotor governed — the probe's two-second nudge
# had simply been too small to show it.
#
# A turbine, like the EC130, but a Robinson: rotor at 407 RPM against the R22's 530,
# 1133 kg all-up against 539. Which way its rotor turns decides the sign of the torque
# feedforward, and being a Robinson is not a measurement — it stays at zero until the
# sweep is flown.

name      = Robinson R66 Turbine
acf_match = Robinson-R66
icao      = R66

# ── Measured constants ───────────────────────────────────────────────────────
# The hover collective agreed to 0.001 across two consecutive sequence runs
# (0.451 and 0.452, both at 100 m with the height loop settled), and the
# regression below independently predicts 0.446 from the standing pedal. Three
# routes, one answer.
#
# Short of the 90 s the procedure asks for — each run held its hover for 3 s
# before the recording stopped. Kept anyway: the generic default of 0.400 is
# 0.05 low, and the lift ramp uses this to know where the aircraft gets light.
const collective.hover_collective = 0.451

# Measured over 4088 settled frames with the collective swept across its full
# range (0.023 .. 0.810), yaw damper engaged, height hold off, no forward speed:
#
#     pedal = -1.012 * collective + 0.098    r = -0.967, residual RMS 0.042
#
# Filtering barely moves it — all airborne frames give -1.008 — which is what a
# sound regression looks like. The Cabri's first attempt gave anything from
# +0.15 to +2.52 depending on the filter, and that was the tell.
#
# Negative, like the R22 and unlike the EC130 and Cabri: this rotor turns the
# same way as the R22's, torque yaws the nose right and it is held with left
# pedal. Confirmed independently by the standing pedal, which is negative in
# every phase of both sequence runs.
#
# The cross-check holds to 0.005: at the measured hover collective of 0.451 the
# line predicts -0.359 of pedal, and the two runs stood at -0.353 and -0.355.
#
# Unlike the Cabri this slope is usable as it stands. The intercept is +0.098,
# small enough for the integrator to absorb, which is the condition the law's
# "slope times collective" form needs (see issue #20). At this airframe's
# maximum of 0.810 collective the feedforward asks for 0.82 of pedal against a
# limit of 0.90, so the safety net does not clip it either.
const yaw.torque_per_collective = -1.012

# Inner loop gain, swept in flight 2026-08-25 in still air and recorded. The
# wobble is on the roll axis, as on the Cabri: roll rate p90 holds at 0.15 through
# 0.130, lifts to 0.26 at 0.140, 0.85 at 0.150 and rings at 4.48 by 0.160.
#
# 0.110 is a factor 1.27 below the first sign of it, the margin the other three
# carry — and the EC130 has since held its own 1.29 under 22 kt of wind without a
# trace of the wobble, which is the evidence that this margin survives load.
#
# 0.130 was flown and is genuinely quiet, but it is only 1.08 below that first
# sign and buys 0.17 degrees of droop. The same trade was declined on the EC130.
#
# Lowered to 0.090 on 2026-10-04 (X-Plane 12.4.4b3), unflown at the new value. At 0.110 the
# hover stayed quiet (roll RMS 0.32 deg/s at 70 m), but descending with POS on and the
# collective down at 0.365 the roll axis rang at about 1 Hz: +-1.5 deg, roll RMS 5.8 deg/s,
# the correction swinging +0.21 / -0.10 every half second, gone the moment the collective
# came back to hover power. Never flown with POS at low collective before, so whether the
# beta moved the onset (as on the EC130) or the descent always had less margin is open.
# reference_flights/Robinson_R66_Turbine/2026-10-04_18-45-05.
const cyclic.inner_kp = 0.090

# Rate damping for the assistant, swept in flight 2026-10-08 19:55 in Full at kp 0.090
# (assistant_check, rate RMS pitch/roll deg/s):
#
#     kd      hover        straight     turn
#     0       0.95/0.66    2.49/2.72    1.24/3.83  rocking, roll 1.3-1.9 s
#     0.020   0.69/0.35    1.34/1.44    0.97/0.86  calm
#
# The pilot's choice; 0.040 not flown on this cell. kd leaves the trims alone.
const cyclic.inner_kd = 0.020

# Measured at inner_kp 0.110 in still air, 2026-08-25, and only valid there. The
# attitude actually flown is +0.19 / -1.24 and did not move across a sweep from
# 0.110 to 0.160; the rest is the inner loop's standing error.
#
# The previous pair (2.66 / -0.62) was the same quantity at kp 0.060 and carried
# a full degree more droop.
#
# Re-derived for inner_kp 0.090 on 2026-10-04 from that day's quiet hover at 70 m (1118 kg,
# still air, density altitude 510 m): attitude -0.48 / -0.75, standing correction
# +0.158 / +0.042, so attitude + correction / 0.090 = 1.27 / -0.29. Note the attitude moved
# against 2026-08-25 at the same mass (+0.19 / -1.24): 0.7 deg of pitch, 0.5 of roll. Derived,
# not flown at the new gain; the learner replaces it after 30 s of a quiet hover.
const cyclic.hover_trim_long = 1.27

const cyclic.hover_trim_lat = -0.29

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.09, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 3 flights 2026-10-08 .. 2026-10-15: pitch -0.17
# (-0.31 .. +0.06), roll -1.03 (-1.49 .. -0.75). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = -0.17
const cyclic.hover_attitude_lat  = -1.03

# Raised from the generic 6.0 to 9.0 on 2026-10-08 for the assistant's stop. The bound is
# absolute, not from the trim: the stop from 22.0 m/s flew 5.4 deg and slowed at 0.83 m/s^2,
# 4.2 deg of room above the trim the hold had learned (19:49). 9 gives about 7.5, as the
# AS350 and the B412. It bounds the trainer's position hold too, both ways. Unflown at 9.
# cyclic.attitude_limit_deg was 9.0, counted from level. Since #78 every limit counts
# from the hover trim, and the generic 7.5 applies (2026-10-14).
# Design rotor speed, the yardstick of the rig check's overspeed line (issue #47).
# From .acf _prop/0/_des_rpm_prp; 16 reference flights hover at 99.8-100.0 %.
const rotor.design_rpm = 408

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 16.500 ft, times two.
const rotor.diameter_m = 10.06

# Where translational lift goes, for the assistant's floor when slowing down (#54). From the
# level-flight collective of the 18 reference flights above 15 m (tools/assistant_check.py
# power, 2026-10-08): 0.458 at 6 m/s, 0.387 at 9, 0.215 at 13, 0.26-0.29 at 28-33 — no data
# at 7-8 or 10-12, so whether it is a step or a slope is not known; the lead takes the slope.
# Unflown.
const collective.assist_lift_lost_below_ms = 7.0
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
const airframe.vne_kt = 140
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
