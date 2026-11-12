# Bell 412 (X-Trident AB412 v5.2). Everything below was read back from a running
# X-Plane 12 over the Web API on 2026-10-02, on the ground with the rotor at 316.7 RPM.
#
# ── The same developer as the AW109, and the lead did NOT carry over ──────────
# The AW109 taught that this house keeps its own axis namespace and leaves prop_ratio dead.
# The B412 is a native plugin (plugins/Bell412/64/mac.xpl, no control Lua), and its
# strings name 000/joy_{pitch,roll,rudder,collective}_ratio_custom and _raw — the same
# shape of namespace, with no override flag beside it. Likely was not measured, so the
# ground test ran in full. Every standard axis reaches the blade angles, written and read
# back on every pass, AFCS off (AP1 and AP2, see below):
#
#   pedal        yoke_heading_ratio -0.6 / +0.6   tail rotor POINT_pitch_deg[1]  8.4 / -2.4 deg (3.0 neutral)
#   cyclic pitch yoke_pitch_ratio   +0.5          cyclic_elevator_deg            +5.74
#   cyclic roll  yoke_roll_ratio    +0.5          cyclic_aileron_deg             +3.63
#   collective   POINT_pitch_deg[0] -2.84          prop_pitch_deg[0] -2.84 on 15/15 samples over 4 s,
#                                                  torque_n_mtr[0] 282 -> 405 Nm
#
# A first run of those holds had AP1 and AP2 engaged; the yes/no answer survives that, the
# magnitudes above are from it and are not used anywhere.
#
# Hand sweep of all four axes, AFCS off, 60 s at 20 Hz: in every steady stretch
# joy_mapped_axis_value[1/2/3] = yoke_{pitch,roll,heading}_ratio = total_*_ratio to four
# decimals. Nothing mixes into the pilot's axes with the AFCS off. 000/joy_rudder_ratio_*
# stayed at 0.0000 throughout while the pedals swept full travel — do not bind them.
#
# ── AFCS: switch AP1 and AP2 off before any measurement ───────────────────────
# 412/ap/art_stab reads 1 with them engaged and 0 with both off — the one dataref that
# says from outside the cockpit whether a second controller is on the axes. Every constant
# below has to be measured with art_stab = 0.
#
# The add-on's SAS level (LOW / MODERATE / DEFAULT / HIGH / Arcade, 412/ap/sas_level, -2 is
# LOW) is the gain of that same controller and does nothing with AP1/AP2 off. Measured
# 2026-10-02: switching LOW -> HIGH on the ground changed none of 761 add-on datarefs but
# the level itself, and 20 s of hands-off hover at each level, assists on, gave total_*_ratio
# equal to the pilot axes to a median of 0.0003 and the cyclic blade angle equal to
# 12 deg x pitch / 7.5 deg x roll to 0.001 deg — no SAS contribution at either. X-Plane's own
# artificial stability is switched on (artificial_stability_on 1) with every acf_AS*
# constant at zero, so it is inert, as on the MD 902.
#
# ── What the .acf says before flying ─────────────────────────────────────────
#   _prop/0/_prop_dir    +1    -> LEFT pedal in the hover, NEGATIVE yaw.torque_per_collective
#                               (predicted, not measured; confirm with the first settled hover)
#   _prop/0/_des_rpm_prp 324   ground idle 316.7 = 97.7 %; not yet checked against a hover log
#   _rotor_mi_rat        0.370 -> plan to sweep cyclic.inner_kp past 0.15
#   _m_empty 6786 lb, _m_max 1.19e4 lb; flown at m_total 5351 kg
#
# Measure in the order docs/adding-an-aircraft.md gives: inner gain sweep (4a), then the
# constants (4b), first hover by hand (5b), the hand-back test (5c).

name      = Bell 412
acf_match = Bell412
icao      = 412

# ── Measured constants ───────────────────────────────────────────────────────
# Source for all five: the first flight, 2026-10-02 14:59, flown by hand with yaw and
# cyclic assist on, ALT off. Settled hover 90-103 s at 65 m AGL, wind 0.00, 5317 kg,
# density altitude 416 m, AFCS off. In that window:
#
#   collective 0.6037   pedal -0.804   pitch +5.7 deg   roll -0.8 deg   drift 0.08 / 0.05 m/s
#   cyclic pitch total +0.362 = pilot +0.488 + assist -0.126,   roll total +0.060 (assist)
#
# Pedal -0.804 is LEFT, as _prop_dir +1 predicted. The feedforward pair below is anchored on
# a later hover (17:18) instead, the one hover_collective comes from. Note how little
# is left: -0.91 in the climb at 0.645 of collective, and on 2026-10-02 (16:52, two climbs
# by hand at 3-5 m/s) the pedal sat on -1.000 for 334 frames from about 0.69 of collective.
# The heading held within 2 degrees, just; above about 0.70 neither the yaw damper nor a
# pilot has any left pedal to give. The smallest yaw reserve in the fleet.

# Was 0.604, a cold start from that hand-flown hover (13 s, sinking at 0.16 m/s). Now the
# learner's figure from 2026-10-02 17:18: 0.5984 over 30 s at 100 m, 5164 kg, density
# altitude 515 m, wind 0.00, inner_kp 0.075. The learner had read 0.6099 to 0.6120 at
# 5290-5310 kg earlier the same day — the 2-3 % of mass is the difference. ALT was never engaged, so the learner had nothing to measure. Replaces the
# generic 0.40, against which the take-me-up at 14:55 ramped to 0.50 and never left the
# ground (49 m slid forward on the skids at 0.10 m AGL).
const collective.hover_collective = 0.598

# Torque feedforward, from the two take-me-up runs of 2026-10-02 (17:06, 17:18): the Lift
# phase ramps the collective from 0.54 to 0.64 with the yaw damper holding heading, which
# is the deliberate sweep docs/adding-an-aircraft.md asks for, flown by the sequence.
# Airborne, |forward speed| < 3 m/s, |yaw rate| < 1 deg/s, pedal off its stop:
#
#   17:06   6394 frames   slope -2.132   r = -0.986   collective 0.548..0.643
#   17:18   2685 frames   slope -2.079   r = -0.992   collective 0.542..0.636
#
# Negative, as _prop_dir +1 predicted. The anchor is the settled hover of the 17:18 run,
# the same one hover_collective above comes from: collective 0.5987, pedal -0.7946. The
# fitted line puts -0.793 there; the 17:06 hover (0.6044 -> -0.807 measured) is predicted
# at -0.808. Shorter logs with 0.02 of collective range regress to anything from -2.8 to
# +4.8 and are not used. The steepest slope in the fleet, matching the smallest reserve:
# at 0.69 the line asks for -0.99, so kFeedforwardShare (0.9) bounds it before the stop.
const yaw.torque_per_collective = -2.10
const yaw.hover_pedal = -0.795

# The three cyclic bounds are raised far enough to let the assist hover the aircraft
# hands-off, which is what the inner_kp sweep needs. They are sized from this hover, not
# yet flown with:
#
#   authority      the hover needs +0.36 of aft cyclic in total; 0.30 cannot provide it.
#                  0.60 leaves room to decelerate.
#   attitude_limit pure-P inner loop: 0.36 at inner_kp 0.060 costs 6 deg of standing error,
#                  on top of a +5.7 deg hover attitude, so the target needs about 11.7.
#   integral_limit the same standing lean has to fit in the integrator.
#
# The error is asymmetric, as on the MD 902: too small and the assist cannot hold at all,
# too large only grants room it need not use. A higher inner_kp shrinks the droop, so
# lower these again after the sweep.
#
# Second round, 2026-10-02 15:07, the first take-me-up with the bounds above: the assist
# hovered the aircraft hands-off at 100 m (0.13 m travel in 30 s) and the learner took
# hover_trim_long 11.96 against an integral_limit of 12.0 — 0.02 deg of reserve. The
# correction was 0.363, below the 0.60 authority, so that bound holds. Of the 11.96, 6.0 is
# droop (0.363 / 0.060) and 5.9 is attitude. Raised so the inner_kp sweep can start from
# 0.060 without the integrator on its stop; the sweep is what brings the trim down.
const cyclic.authority          = 0.60
# cyclic.attitude_limit_deg was 18.0, counted from level. Since #78 every limit counts
# from the hover trim, and the generic 7.5 applies (2026-10-14).
const cyclic.integral_limit_deg = 16.0

# Swept 2026-10-02 17:06, 100 m, wind 0.00, 5237 kg, AFCS off, hands off, all three
# assists on. Roll is the axis that rings; pitch stayed under 1.5 deg/s p90 throughout.
#
#   going up    roll rate p90: 0.100 0.36 | 0.110 0.90 | 0.120 1.10 | 0.130 2.44, growing
#               over 16 s from 1.1 to 2.8 | 0.140 7.22, growing to 8.8
#   coming down 0.130 .. 0.100 held only ~2 s each, so they say nothing about decay
#               0.090  16 s  9.8 -> 2.9   decays, slowly
#               0.080  10 s  2.8 -> 0.9   decays
#               0.075   7 s  0.6 -> 0.2   quiet; a second run 3.5 -> 0.8 in 8 s
#
# Onset about 0.125 going up; 0.090 is the highest gain shown to settle. 0.075 sits 1.2
# below that and 1.7 below the onset, and is the highest step that went quiet on its own
# within seconds. A sweep down at 0.11 / 0.10 / 0.095 with 20-30 s each could justify
# more. _rotor_mi_rat 0.370 suggested sweeping past 0.15; the onset came at 0.125.
#
# The trims below the learner writes depend on this gain: at 0.060 the integrator stood at
# 11.96-12.08, at 0.140 at 8.64 — the droop shrinking with 1/kp.
const cyclic.inner_kp = 0.075

# ── cyclic.inner_kd: 2026-10-08 17:35 / 17:42, assistant Full ─────────────────
# At kd 0 the assistant rocked in forward flight, pitch about 2.6 s and roll about 2.1 s,
# never at the authority. High-passed rate RMS (2 s mean removed), pitch / roll deg/s:
#   kd 0      hover 1.39 / 1.24   straight 3.26 / 5.95   turn 3.21 / 5.63
#   kd 0.040  hover 0.30 / 0.12   straight 0.37 / 0.48   turn 0.37 / 0.63
# The pilot: "mit 0.04 perfekt". 0.020 was flown for seconds only. kd damps the attitude
# rates, so it leaves kp's droop and the hover trims as measured.
const cyclic.inner_kd = 0.040

# The hover trims, measured at this gain and therefore valid only with it (the trim is
# lean + correction / inner_kp). Same hover as hover_collective above: the learner's
# 10.7125 / -0.0047 over 30 s, settled in the recording at a median of 10.718 / 0.023.
# The split checks: attitude 5.76 + correction 0.372 / 0.075 = 4.96 of droop -> 10.72.
#
# Without them the take-me-up carries the aircraft about 40 m forward while the
# integrator winds up from zero (42.2 m measured at 17:18, 39 m of it at 3 m height).
const cyclic.hover_trim_long = 10.71
const cyclic.hover_trim_lat  = 0.00

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.075, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 7 flights 2026-10-02 .. 2026-10-15: pitch +5.80
# (+5.67 .. +6.23), roll -0.32 (-0.81 .. -0.09). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = 5.80
const cyclic.hover_attitude_lat  = -0.32

# _prop/0/_des_rpm_prp from the .acf, confirmed: the hover above ran at 316.7 RPM = 97.7 %.
const rotor.design_rpm = 324

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 23.000 ft, times two.
const rotor.diameter_m = 14.02

# Where translational lift goes, slowing down: the collective held level above 15 m, from
# the trainer flights 2026-10-02 to 10-05 in 1 m/s bins of ground speed: 0.64 at 10 m/s,
# 0.54 at 11, 0.49 at 12 (hover 0.60). Read as for the 902X: the bin with part of the step.
const collective.assist_lift_lost_below_ms = 11.0

# ── Pilot axes ───────────────────────────────────────────────────────────────
bind cyclic_pitch = sim/cockpit2/controls/yoke_pitch_ratio   | clamp -1 1
bind cyclic_roll  = sim/cockpit2/controls/yoke_roll_ratio    | clamp -1 1
bind pedal        = sim/cockpit2/controls/yoke_heading_ratio | clamp -1 1

# Read from the blade angle, because it is written there (see below). The range comes from
# acf_min_pitch/acf_max_pitch at runtime: -5.8 .. 9.0 deg here. Verified by hand sweep:
# prop_ratio[0] = 1 - joy_mapped_axis_value[5] (the lever on this rig is inverted) and
# POINT_pitch_deg[0] = -5.8 + 14.8 * prop_ratio[0], to four decimals in every steady stretch.
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
# #76: indicated airspeed, for the assistant's VNE. Its never-exceed speed, from the .acf
# (P acf/_Vne_kts, read 2026-10-11).
bind indicated_airspeed_kt = sim/flightmodel/position/indicated_airspeed
const airframe.vne_kt = 168
bind velocity_east_ms  = sim/flightmodel/position/local_vx
bind velocity_south_ms = sim/flightmodel/position/local_vz
bind position_east_m   = sim/flightmodel/position/local_x
bind position_south_m  = sim/flightmodel/position/local_z

# ── Engine and rotor ─────────────────────────────────────────────────────────
# PT6T Twin-Pac, acf_num_engines 2. Index 0 is the main rotor (316.7 RPM), index 1 the
# tail rotor (1624.8). Both engines read 6450.7 RPM. Torque is engine 1 only, and the two
# indices were far apart on the ground (356 / 63 Nm) — a power figure from this column is
# half the story at best.
bind rotor_rpm        = sim/cockpit2/engine/indicators/prop_speed_rpm[0]
bind engine_rpm       = sim/cockpit2/engine/indicators/engine_speed_rpm[0]
bind engine_torque_nm = sim/cockpit2/engine/indicators/torque_n_mtr[0]
# Throttle unbound: the add-on holds override_throttles = 1 and throttle_ratio reads 0.0
# with both engines running. Manifold unbound: 29.92 is ambient, a turbine has none.

# ── Write access ─────────────────────────────────────────────────────────────
# Cyclic and pedals: the standard axes, so nothing is said — but the feasibility check
# above was half wrong for the cyclic. The add-on lowers override_joystick_pitch and _roll
# the moment they are raised (48 writes over 6 s read back 0, 2026-10-02); the heading flag
# and the copilot flags it leaves alone. The ground test passed only because the stick was
# still: X-Plane copies the hardware onto an axis with its flag down only in the frames the
# hardware moves. In flight that cost a held trim of 0.358 in 48 of 229 frames as soon as the
# pilot touched the stick, and the nose went to -16 degrees.
#
# Fixed in the plugin rather than here: AxisOverride::reassert_owned() raises the flags of
# every owned axis again before each flight model. Verified on the ground afterwards with
# POS commanding +0.51: 27 frames of moving stick, the axis read stick + correction in all
# of them (clamped at +1.0 where the sum exceeded it).
#
# The copilot channel was the fallback and is not usable here: its flags hold, but it does
# not add — any pilot deflection (+-0.23, +-0.385, +-1) replaced a held +0.2 completely.
#
# The collective is written as the blade angle, not through the standard prop_ratio_all,
# for two reasons. prop_ratio_all would also write index 1, and prop_ratio[1] (0.50 on
# the ground) belongs to the tail rotor here. And X-Plane only refreshes prop_ratio[0]
# from the lever when the lever moves: a value written there stayed for 32 s against a
# parked lever. Same shape as the R22 and AS350, so their path.
#
# #71 (2026-10-10): behind override_prop_pitch. Without the flag the lever took
# the collective for a frame on almost every change (247 of 253, 2026-10-09). Ground test:
# prop 1 is the tail rotor (-6 .. 12 deg), mid - total_heading_ratio * 9 to 0.000 deg at
# rest. Over the Web API the flag read back 0 in every sample of a 10 s hold at 20 Hz — the
# add-on lowers it as it lowers the pitch and roll flags. Those hold in the plugin because
# they are raised again before each flight model; rewrite_collective() does the same here.
# Flown 2026-10-10 17:40 (laptop, Full, 527 s): 257 lever changes in the air, none on the
# lever, the blade angle equal to the command in all 13580 frames, hover yaw median 0.55 deg/s.
write collective = sim/flightmodel/engine/POINT_pitch_deg_use[0] | units blade_pitch_deg | flag sim/operation/override/override_prop_pitch
