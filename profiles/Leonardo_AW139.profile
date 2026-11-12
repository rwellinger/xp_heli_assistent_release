# Leonardo AW139 (X-Rotors). Probed against a running X-Plane 12 on 2026-08-25.
#
# Four times the mass of anything else here — 7135 kg against the EC130's 2000 — and the
# first airframe onboarded that brings its own four-axis autopilot, including an auto
# hover of its own. **It does not need this plugin's assists.** It is here as a test of
# the onboarding procedure well outside the range everything else was measured in.
#
# Feasibility, in the order docs/adding-an-aircraft.md asks for it:
#
#   - Every required parameter reads. The xlua scripts carry their own collective
#     handling (xrotors/aw139/coll_ratio, coll_axis) but leave prop_ratio alone.
#   - Writing reaches the flight model on both axes: the pedal nudge moved the yaw rate,
#     the collective nudge moved the torque.
# Reported by the pilot and not verified here: the autopilot's upper modes are said to
# need something like 30 kt before they engage, which would explain why a hover is
# undisturbed. What *is* verified is only the line below — with the switches off.
#
#   - **With AP1, AP2 and SAS off the aircraft does not write the pedal axis.** Worth
#     checking because the autopilot script names yoke_heading_ratio next to a
#     cltv_yaw_trim; at rest joy_mapped_axis_value[3] and yoke_heading_ratio were
#     bit-identical over 20 s, and 78 % of frames matched exactly while the collective
#     was worked, the rest being sampling skew during fast movements.
#
# Seven constants are measured and stand below; this line used to say "nothing is measured
# yet" and went on saying it for eighteen days, with the measurements sitting underneath it.
# Corrected 2026-09-12 — the same failure the AW109 row in CLAUDE.md made until 09-09.
#
# What is still missing, and why each one matters here:
#
#   - `yaw.torque_per_collective` (and the `yaw.hover_pedal` that anchors it). No sweep has
#     been flown. Absent means no feedforward, which is the safe answer — but it is the
#     largest single term of the yaw loop everywhere it has been measured.
# Sections 5c and 5d are both DONE as of 2026-09-12; the wind flight took three attempts and
# each one moved a limit. The trim consumption measured from it is direction-dependent —
# 0.210 deg/(m/s) into the wind against 0.353 with it, and 0.253 across — which is a fleet
# finding rather than an AW139 one; docs/aircraft-findings.md carries it.
#
# The hand-back test of section 5c is DONE, 2026-09-12: gap 0.1993, scheduled 1.33 s, flown
# 1.34 s — 0.1423/s against the 0.15/s limit, residual 0.0000, and afterwards `collective`
# follows the lever to 0.0000 median and max over 880 frames. It is the first hand-back in
# the fleet flown after the fade fix and the only one whose gap is large enough for the ramp
# to be doing the work.
#
# Everything not listed above is at the generic defaults, which are R22 figures — see the
# inner-gain note in the R22 profile for why that is not harmless.

name      = Leonardo AW139
acf_match = AW139
icao      = A139

# ── The logged mass of this airframe is not its loaded mass ──────────────────
# The add-on takes about 1500 kg off the aircraft for flight and puts it back on the
# ground. Measured 2026-09-11: 7009 -> 5509 kg over 1.2 s while the sequence raised the
# collective for lift-off, and the same curve backwards 1.5 s after touchdown. With the
# lever down it sits at 7014 kg against an MTOW of 6800 — over its own limit, which is
# what makes it look deliberate rather than accidental.
#
# Not this plugin: m_total is read-only, appears once in the source on the read side,
# and the AW109 in the same session moved 0.1 kg through the identical procedure. Why
# the add-on does it is not established (Issue #29).
#
# What it means for everything below: **the flight mass is the real one.** A recording
# started on the ground carries the wrong number in its metadata line, which is how the
# same flight once logged 7132 kg and 5612 kg. Every constant here is measured in
# flight and therefore against the mass the rotor actually carries — which is the mass
# the controllers need.

# ── Measured constants ───────────────────────────────────────────────────────
# Measured 2026-08-25 over 1307 frames of a settled 100 m hover at 5555 kg and
# 913 m density altitude. Utterly steady — p25, median and p75 all read 0.485.
const collective.hover_collective = 0.485

# Flown at 0.105 and confirmed from the data (correction/error over 1307 frames
# gives 0.1050 exactly). The airframe is the quietest of the five: pitch rate p90
# 0.03 deg/s, roll 0.06. **The onset was not swept** — this value was chosen by
# feel and is demonstrably calm, but where it starts to ring is unknown, so there
# is no measured margin behind it.
#
# **Lowered to 0.075 on 2026-10-08 for the assistant.** At 0.105 the roll was the
# fleet's least steady with speed; the inner loop asks only 0.01-0.09 of cyclic for every
# attitude, so each degree of error is worth more here than anywhere else. Roll rate RMS
# (2 s mean removed), hover / straight / turn, deg/s:
#   0.105  17:57  0.85 / 3.74 / 5.89     18:07 (bank 35)  2.86 / 5.22 / 9.04
#   0.075  18:25  0.52 / 1.38 / 2.60     pitch 0.12 / 0.35 / 0.20
# Still no onset swept upwards. Trims kept: the hover at 0.075 held 6.24 / -1.49 against
# the 6.27 / -1.17 below, almost no droop on this airframe. A take-me-up at 0.075 was
# flown after it and looked right to the pilot (not recorded).
const cyclic.inner_kp = 0.075

# ── cyclic.inner_kd: 0, flown 2026-10-08 17:54 / 17:57, assistant Full ─────────
# The exception of the fleet. Every other cell rocked with speed at kd 0 and went quiet
# at 0.040; here 0.040 set the roll banging between the +-0.50 authority at 0.5 s in the
# hover (roll rate RMS 16.2 deg/s, 235 of 363 frames at the stop, 19 fps). At 0 the hover
# is quiet (2.3) and forward flight does not rock: pitch / roll rate RMS straight
# 0.65 / 3.74, turn 0.45 / 5.89 deg/s, never at the authority. Why: the inner loop asks for
# only 0.01-0.09 of cyclic for every attitude flown (B412 0.2-0.45), with almost no droop,
# so a degree of error is worth far more here, and a rate term on a frame of lag drives
# the roll instead of damping it.
const cyclic.inner_kd = 0.0

# The assistant's bank (#61). Fast: at 30-41 m/s the generic 25 deg turned at 6-9 deg/s on
# a radius of 250-300 m with the stick at its stop (17:57), where the others turn at 15-17
# m/s. 35 deg gives about 175 m and 11 deg/s at 35 m/s. Unflown at 35.
const cyclic.assist_bank_limit_deg = 35.0

# **This airframe cannot hover inside the generic limits.** It flies its hover at
# +5.85 degrees nose up, against a generic `integral_limit_deg` of 5.0 and an
# `attitude_limit_degrees` of 6.0. Measured: the integrator sat on 5.000 for
# 100 % of the hover, the commanded attitude on 5.95 of an allowed 6.0, and the
# aircraft crept forward at a dead-constant 0.474 m/s — 30.8 m in 75 s, in
# absolutely still air.
#
# Every other airframe reaches these bounds only under wind (see issue #26). Here
# the airframe's own trim requirement exceeds them, so raising them is not tuning
# but a precondition for the assist working at all.
#
# 8.0 leaves room above the 5.85 for the droop the inner loop still adds; 10.0
# keeps roughly the same working range above the hover attitude that 6.0 gives an
# airframe trimmed near zero. The 6.0 default is deliberate elsewhere — it is why
# recovering a lost attitude takes 16 s — and is not being changed for anyone but
# this aircraft.
#
# **Raised to 11.0 on 2026-09-12: 8.0 was enough for still air and not for weather.**
# Round 2 of the chain, and unlike the authority raise of the same evening this one is
# measured rather than assumed — 5d asks for frames on the stop before the limit moves,
# and the run shows them:
#
#   8.55 m/s from 271 deg on a heading of 110 — 161 deg relative, so from behind, which
#   is the direction that loads this airframe's weak axis. `cyclic_trim_long` pinned at
#   exactly 8.000 for **100 % of the climb** and 59 % of the low hover, while
#   `cyclic_trim_lat` sat at 0.61 and never came near. The sequence aborted itself with
#   `assist_at_limit` at 14.5 m, which is the guard doing its job.
#
# The same run is what closed round 1: with `cyclic.authority` at 0.50 the roll and pitch
# corrections peaked at 0.098 and 0.062, against 49.8 % and 41.0 % of frames on the 0.300
# stop the evening before. **The limit moved rather than being found**, exactly as the
# MD 902 chain in docs/adding-an-aircraft.md predicts.
#
# 11.0 is the MD 902's figure from its own round 3, and it was flown the same evening:
# 18.5 kt at 174 deg relative — six degrees off dead astern — settled at **9.065** with a
# spread of 0.20 deg over 45 s, 0 % of frames on the stop, 1.86 deg of reserve left. The
# offset over those 45 s was **0.29 m** and the pilot's pitch and roll inputs were exactly
# 0.0000. 9.065 is above the old limit of 8.0, so the raise was necessary rather than
# generous.
const cyclic.integral_limit_deg = 11.0

# Raised from 10.0 to 14.0 on 2026-10-08 for the assistant's stop. The bound is absolute,
# not from the trim: at +6.3 deg of hover trim 10 left 3.7 deg of nose up, the least in the
# fleet (AS350 7.9, B412 7.3, 902X 5.6, R22 4.8), and the stop from 41 m/s flew 10.8 deg and
# slowed at about 1.1 m/s^2, 38 s to a standstill, the pilot pulling back to help (17:57).
# 14 gives 7.7, as the AS350. It bounds the trainer's position hold too, both ways — more
# room there than 10, which only had to clear the generic 6. Unflown at 14.
# cyclic.attitude_limit_deg was 14.0, counted from level. Since #78 every limit counts
# from the hover trim, and the generic 7.5 applies (2026-10-14).
# Measured with those raised limits in place, over the last quarter of a 414 s
# hover at inner_kp 0.105. The attitude actually flown is +6.14 / -1.20, so the
# droop is only 0.13 degrees here — this airframe needs almost no standing cyclic.
#
# The limits were the whole story: at 5.0 the integrator was pinned for 100 % of
# a hover and the aircraft crept forward at 0.474 m/s. At 8.0 it settles at 6.27,
# never touches the stop, and the same hover drifts **0.1 m in 414 seconds**.
const cyclic.hover_trim_long = 6.27

const cyclic.hover_trim_lat = -1.17

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.075, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 9 flights 2026-10-08 .. 2026-10-15: pitch +6.01
# (+5.47 .. +6.40), roll -0.90 (-1.44 .. -0.71). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = 6.01
const cyclic.hover_attitude_lat  = -0.90

# The generic 2.0 was a fifth of what this airframe carries. Read out of the flight
# of 2026-08-25 by the climb-capacity report — the data were already in the
# archive, nobody had asked them this question:
#
#   10.25 m/s sustained 37 s   rotor down 0.95 %   0.27 of collective still free
#
# At 5.6 tonnes it is the heaviest airframe here and it climbed at five times the
# sequence's setting without troubling the rotor.
#
# 5.0 rather than the 10 it demonstrated, for the same reason the AS350 got 3.0
# against a measured 8: the figure was taken at one weight and one density
# altitude, and a setting that spends the whole margin is wrong on the first warm
# day with a full cabin.
#
# **The climb was hand-flown, not flown by the sequence.** It establishes what the
# aircraft can do, not that the sequence walks its setpoint cleanly at that rate —
# that wants one take-me-up at 5.0 to confirm.
# sequence.climb_rate_ms = 5.0: the trainer's take-me-up climb, not used by the assistant.

# ── cyclic.authority: 0.50, and this one is NOT flown ────────────────────────
#
# Round 1 of the chain docs/adding-an-aircraft.md calls "expect the limit to move, not to
# be found". The MD 902 needed three of them — 0.30 -> 0.50 -> 0.70 — and each raise only
# revealed the next binding limit. This is the AW139's first, and it is an assumption with
# a measurement behind the *problem*, not behind the *value*.
#
# What is measured (2026-09-12, 13 kt from 272 deg, heading 255, low hover at 2 m):
#
#   cyclic_correction_roll   49.8 % of frames on the 0.300 stop
#   cyclic_correction_pitch  41.0 % of frames on the 0.300 stop
#   cyclic_trim_long/lat      0.0 % of frames on their 8.0 stop
#   drift                    5.68 m/s median against a 7.11 m/s wind
#   distance covered         48.77 m in 16 s, at 2 m above the ground, into an obstacle
#
# So the integral limit of 8.0 was never the constraint and `authority` was: the loop was
# not allowed to ask. Read off one frame — target roll +0.41 deg against an actual +3.13,
# an error of -2.72, times inner_kp 0.105 is -0.2855, already at the 0.30 ceiling.
#
# Two things make the evidence stronger than the single run suggests. The wind was 17 deg
# off the NOSE, which *relieves* the pitch axis — trim_long fell from 6.26 to 3.28 exactly
# as 5d describes — so this is the favourable direction and it still saturated. And the
# pilot's pitch and roll were 0.000 throughout: the drift is the loop's, not a hand's.
#
# **0.50 was copied from the MD 902's round 1 and is now flown.** Two wind hovers at 100 m
# the same evening, 17.5 and 18.5 kt: the pitch and roll corrections peaked at 0.089 and
# 0.094, and at 0.081 apiece in the tailwind case — against 49.8 % and 41.0 % of frames
# pinned on the old 0.300. The ceiling is no longer anywhere near the working range.
#
# What the raise did was move the binding limit rather than remove it: the next run pinned
# `cyclic.integral_limit_deg` at 8.000 for 100 % of a climb and aborted itself with
# `assist_at_limit` at 14.5 m. See that constant above — round 2, and it is the last one.
const cyclic.authority = 0.50

# rotor.design_rpm is deliberately absent (issue #47): the .acf says 100, a placeholder,
# and 17 reference flights hover anywhere between 279 and 302 RPM. No yardstick, no
# overspeed line — zero is the safe answer.

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 22.638 ft, times two.
const rotor.diameter_m = 13.80

# Where translational lift goes, slowing down: the collective held level above 15 m in the
# 18 reference flights, 1 m/s bins of ground speed — not a step as on the R22 or B412 but a
# slope: 0.475 to 7 m/s, 0.458 at 8, 0.432 at 9, 0.405 at 10, 0.379 at 11, 0.359 at 12.
# Hence hover power below 8 m/s and a lead of 4, the floor's line then follows the curve.
const collective.assist_lift_lost_below_ms = 8.0
const collective.assist_lift_lost_lead_ms  = 4.0

# ── Bindings ─────────────────────────────────────────────────────────────────
bind cyclic_pitch = sim/cockpit2/controls/yoke_pitch_ratio | clamp -1 1
bind cyclic_roll = sim/cockpit2/controls/yoke_roll_ratio | clamp -1 1
bind pedal = sim/cockpit2/controls/yoke_heading_ratio | clamp -1 1
# #71 (2026-10-10): behind override_prop_pitch, as the R22. Ground-tested first: prop 0 is
# the main rotor (-1.0 .. 15.3 deg), prop 1 the tail rotor (-15 .. 15 deg); the two engines
# drive no third prop. Without the flag the tail rotor is mid - total_heading_ratio * 15,
# mean error 0.001 deg at rest. Under the flag both rotors held the written value for 10 s
# (main 2.0 deg with the lever at 0, torque 3776 -> 6873 Nm), and the X-Rotors xlua never
# lowered the flag. Lever and blade angle are linear (-1 + 16.3 * lever, 0.003 deg), so the
# lever-unit constants above stand with the read moved to the blade angle.
bind collective = sim/flightmodel2/engines/prop_pitch_deg[0] | units blade_pitch_deg | clamp 0 1
write collective = sim/flightmodel/engine/POINT_pitch_deg_use[0] | units blade_pitch_deg | flag sim/operation/override/override_prop_pitch
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
const airframe.vne_kt = 167
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
