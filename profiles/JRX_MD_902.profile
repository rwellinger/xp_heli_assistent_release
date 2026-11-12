# MD 902 Explorer (JRX Design, v1.10)
#
# The second JRX airframe, and the first NOTAR in the fleet. Everything below was read
# back from a running X-Plane 12.4.3 over the Web API on 2026-09-08, on the ground with
# the rotor at 392 RPM.
#
# ── The same developer was a lead, and this time it paid ─────────────────────
# The Bell 407 taught that its add-on holds the pilot's axes and leaves the copilot's
# alone. That is a lead, never a conclusion — so this aircraft was started at step 1 like
# any other. The difference is that the ground test took ten minutes instead of an
# afternoon, because the file to read was obvious.
#
# jrx_md902_trim_operation.lua, in after_physics(), so on every frame:
#
#     if is_helicopter == 1 then
#         override_pitch = 1; override_roll = 1; override_yaw = 1
#         yoke_pitch = joy_pitch * sensitivity + pitch_offset + transition
#         yoke_roll  = joy_roll  * sensitivity + roll_offset  + transition
#         yoke_yaw   = filtered_yaw * yaw_sensitivity + yaw_offset + transition
#
# Measured, not assumed: probe_aircraft.py --write-test nudged the pedal and read back
# the written value in 0 % of passes. The yaw rate moved by 31 deg/s during that nudge
# and none of it came from the write — this airframe swings its nose about freely on the
# skids with the rotor turning, which is exactly the trap the read-back check exists for.
#
# The word "copilot" appears in no control script of this add-on. Not held, not cleared,
# not looked up. Measured on the ground 2026-09-08, each value written and read back on
# every pass of a five-second hold:
#
#   pedal  yoke_heading_ratio_copilot = -0.6  held 100 % (16/16), R  -18.7 .. -29.5 deg/s
#                                     = +0.6  held 100 % (16/16), R  +12.2 .. +60.9 deg/s
#   roll   yoke_roll_ratio_copilot    = +0.3  held 100 % (13/13), phi +0.47 -> +2.29
#                                     = -0.3  held 100 % (13/13), phi +0.32 -> -0.97
#   pitch  yoke_pitch_ratio_copilot   = +0.3  held 100 % (13/13), Q up to +1.88 deg/s
#                                     = -0.3  held 100 % (13/13), Q down to -3.76 deg/s
#
# Every axis was run in both directions, because on an airframe whose yaw wanders 30 deg/s
# on its own, a rate that moves is not evidence. A rate that follows the sign of the
# command is.
#
# ── SAS: the opposite of the Bell, and it matters ────────────────────────────
# sim/cockpit2/switches/artificial_stability_on was found at 1, and X-Plane's own
# artificial-stability constants read ZERO on this airframe:
#
#     sim/aircraft/artstability/acf_ASh_lo_rate   0.0
#     sim/aircraft/artstability/acf_ASp_lo_rate   0.0
#     sim/aircraft/artstability/acf_ASmaxr_lo     0.0
#
# So X-Plane's stabiliser does nothing here whichever way the switch is thrown. The switch
# drives the Lua script alone — and there, SAS ON is the NEUTRAL state: control sensitivity
# 1.0, vibration 0.003, no disturbances. SAS OFF multiplies pitch and roll input by 2.0,
# yaw by 1.15, and injects a random +-4 % kick on pitch and roll in roughly 3 % of frames.
#
# MEASURE WITH SAS ON. That is the reverse of the Bell 407, where artstab_mode had to go
# to 0 — there the switch changed X-Plane's constants, here it changes the add-on's own
# arithmetic. Anything measured with SAS off is a constant of an airframe being shaken on
# purpose.
#
# Consequence for the read side below: with artstability at zero, total_*_ratio is pilot
# and copilot alone — not their sum, as written here first, but the larger of the two
# (2026-10-08, see Write access). Measured — copilot pedal at +0.6 with the pilot's
# feet at rest read total_heading_ratio = 0.6000 exactly, span 0.0000 over 16 samples.
# The Bell's totals carried a remainder from its live stabiliser; these do not.
#
# ── The force trim is armed but idle ─────────────────────────────────────────
# The script gates its trim offsets on bus_volts > 20 (found at 28.0 V, so armed), but the
# offsets themselves start at zero and only move when the pilot presses one of the
# 902/Switches/Controls/trim_* commands. Nothing is added to any axis until he does.
# jrx/902/controls/cyclic/trim_rate reads 0 (Fine). Its state belongs in any log of a
# measurement flight — a trimmed cyclic is a shifted zero for every constant below.
#
# The script also has a "virtual cyclic centre" (trim_8_set_center) which FREEZES
# yoke_pitch and yoke_roll at captured values while held. Do not measure with it active.

name      = JRX MD 902
acf_match = md_902
icao      = MD902

# ── What is still unmeasured ─────────────────────────────────────────────────
# One constant is measured (hover_collective, below). The rest are absent, and that is a
# statement rather than an omission:
#
#   (cyclic.inner_kp is SWEPT — see the section below.)
#   (collective.hover_collective is MEASURED — see the section below.)
#   (cyclic.hover_trim_long/lat are MEASURED — see below.)
#   (yaw.torque_per_collective is MEASURED — see the section below.)
#
# Free hints for the sweep, from the .acf, so the range is chosen rather than guessed:
#   _prop/0/_num_blades   5        only the AW139 has more
#   _prop/0/_prop_dir     +1       left pedal, negative feedforward
#   acf/_rotor_mi_rat     0.500    the best predictor there is (r = -0.697 over seven
#                                  airframes) and it points at the LOW end: the R22 and
#                                  the Cabri share this value at 0.060 and 0.100, while
#                                  the Bell's 0.240 earned it 0.175
#   acf/_cyclic_def       14.0 pitch / 9.0 roll   pitch as wide as the Bell and the EC130,
#                                  which correlates the other way (+0.622)
#   m_total               2365 kg  between the AS350 and the EC130, mid-fleet
#
# The two predictors disagree on this airframe, which is the whole reason the rule is
# "sweep it, do not derive it". Worth noting for the rotor-head hypothesis: the MD 900's
# head is bearingless composite, the same family as the Bell's hingeless hub that sits at
# the top of the range. If the head is what sets this gain, this aircraft is the test.

# ── Measured constants ───────────────────────────────────────────────────────
# Measured 2026-09-08, still air (wind 0.00 m/s in every frame), 2351.3 kg, density
# altitude 633.4 m, in a settled hover at 123.6 m — well outside ground effect.
#
# 435 frames over the closing 30 s with the altitude hold engaged and the height standing
# at 123.62 m: p10 0.635, median 0.636, p90 0.636. Vertical speed p50 0.00 m/s, torque
# flat at 6022 Nm. The blade angle that corresponds to is +2.99 degrees, against a range
# of -4.0 to +7.0.
#
# What its absence cost, before it existed: take-me-up aborted with SEQ abort no_lift_off
# twice, thirty seconds each. The lift ramp climbs to hover_collective + lift_margin, so
# the generic 0.400 put it at 0.500 — a blade angle of +1.50 degrees. The aircraft never
# left the ground; it only came light and slid sideways on its skids, which read from the
# cockpit as an uncontrollable drift and was nothing of the sort.
#
# One qualification, because it is measurable rather than hypothetical: this hover carried
# 3.25 m/s of lateral drift, because the cyclic assist was at its stop (see inner_kp
# above). Flying sideways costs a little power, so the true still-hover figure is likely a
# few thousandths BELOW this. That errs in the safe direction — the Bell's lesson is that
# a hover collective set slightly high costs a moment of climb at engagement, while one
# set low puts the aircraft back on the ground. Re-read it once inner_kp is swept.
const collective.hover_collective = 0.636

# ── Inner gain: the softest airframe in the fleet ────────────────────────────
# Swept 2026-09-08 in still air, 100 m hover, all three assists on, hands off the cyclic.
# The gain is reconstructed from the log rather than from anyone's notes —
# cyclic_correction_pitch / (cyclic_target_pitch_deg - pitch_deg), exact because inner_kd
# is 0 — and it reproduced every slider setting to four decimals.
#
#   0.150   roll rate |P| max 13.4 deg/s, correction hitting -0.500 periodically   RINGING
#   0.100   still ringing, but DECAYING                                            onset
#   0.075   |P| +-0.075 deg/s, |Q| +-0.26, roll command free at -0.326 span 0.005  QUIET
#
# Onset on the way down is therefore 0.100, and 0.100 / 1.3 = 0.077.
#
# It is the ROLL axis. Pitch stayed at +-2 deg/s throughout, exactly as on the Cabri, the
# R66 and the Bell.
#
# 0.075 is the LOWEST inner gain in the fleet, below the R22's 0.060-choice from an onset
# of 0.080. And acf/_rotor_mi_rat, the only predictor this project has (r = -0.697 over
# seven airframes), reads 0.500 here and pointed at exactly this end of the range. The
# rotor-head hypothesis pointed the other way — the MD 900's head is bearingless composite,
# the same family as the Bell's hingeless hub at 0.175 — and is wrong. Eight airframes now,
# and the head explains nothing.
const cyclic.inner_kp = 0.075

# What this gain buys, measured over 30 s at 100 m: ground velocity 0.0009 / 0.0001 m/s.
# A drift of one millimetre per second, which is the stillest hover recorded in this
# project. It is NOT the gain alone: at 0.075 the inner loop's droop is 0.326/0.075 =
# 4.35 deg, which on top of the airframe's real -2.84 deg of lean puts the integrator near
# -7.2 — over the generic integral limit of 5.0. This value works only together with the
# 8.0 below, and either one alone leaves the aircraft drifting.
#
# That is a first for this project: an airframe with a gain window bounded from BELOW as
# well as above. Too much gain rings the roll axis; too little starves the integrator into
# its stop, which reads as a quiet aircraft that slowly walks away.

# ── Torque feedforward: the smallest in the fleet, and that may be the NOTAR ─
# Swept 2026-09-09, 65 s, in dead calm (wind 0.000 in every frame), altitude hold OFF and
# yaw damper on, hovering at 88-101 m with no forward speed. 2310.6 kg, density altitude
# 392.9 m. Collective deliberately walked over 0.399 to 0.833.
#
#   pedal = -0.568 * collective - 0.041      r = -0.900, RMS 0.012, n = 782
#
# Stable across filters, which is what the Cabri's failed attempt was not: -0.488 over all
# 876 frames, -0.568 below 0.5 deg/s of yaw rate, -0.544 below 0.3. The Cabri gave slopes
# from +0.15 to +2.52 out of one recording, and that is what a bad sweep looks like.
const yaw.torque_per_collective = -0.568
#
# The check that costs nothing, since the hover was flown anyway: put the settled hover
# collective into the fitted line. 0.6254 predicts -0.3962; the hover sat on -0.3985.
# Two thousandths.
#
# It also resolves what looked like a discrepancy. The standing pedal on 2026-09-08 read
# -0.461 at 2351.3 kg and 633.4 m density altitude; here it is -0.398 at 2310.6 kg and
# 392.9 m. Lighter and lower means less power means less pedal, and the hover collective
# moved the same way (0.636 -> 0.625). Two readings that move together are worth more than
# one repeated.
#
# The 41 kg between them is a different livery and two passengers, not measurement noise —
# which is worth writing down, because it means the constants here are tied to a LOADING as
# well as to a day. The collective figure the onboarding doc already warns about is the
# obvious one. The quieter one is cyclic.hover_trim_long/lat: two people in the back move
# the centre of gravity, and the lean the airframe needs moves with it. Both trims here
# were measured with the aircraft loaded as it was on 2026-09-09; a solo flight will settle
# somewhere else, and the preload will be that much off on the first take-off.
#
# ── Why this number is interesting beyond this aircraft ─────────────────────
# At 0.568 it is the SMALLEST magnitude in the fleet, roughly half of the other airframes
# that hover on left pedal:
#
#   Cabri +3.781 | EC130 +1.435 | AS350 +1.159 | R22 -1.112 | R66 -1.012 | AW109 -0.998
#   MD 902 -0.568
#
# That is the prediction made on the first evening of this onboarding, before anything had
# been flown: a NOTAR carries roughly 60 % of its anti-torque on the Coanda tailboom, and
# that share scales with rotor downwash — so it grows with power on its own and does not
# need feeding forward. Only the direct jet thruster, the part the pedals actually drive,
# should show up in this regression.
#
# **It fits, and it is one data point.** X-Plane models the NOTAR as an ordinary ducted
# tail rotor (_prop/1/_prop_ducted 1, six blades, geared 0.1333 to the main rotor) with no
# field for a Coanda boom anywhere in the .acf, so there is no mechanism in the simulation
# that ought to produce this. A second NOTAR would decide it; there is none in the fleet.
#
# The intercept is -0.041, the smallest in the fleet by a wide margin (the R22 is +0.173,
# the Cabri -1.868). The law anchors the feedforward at zero collective, so a small
# intercept is exactly what makes a measured slope usable — this one is as close to
# through-the-origin as any airframe has come.

# ── The cyclic assist needs more room than the fleet defaults give it ────────
# Measured 2026-09-08 in the same still-air hover at 123.6 m. With the generic
# cyclic.authority of 0.30 the roll axis was pinned against it for every frame of five
# separate 15-to-30 s recordings — total_roll_ratio flat at -0.2939 with a span of exactly
# 0.0000 — while the aircraft drifted right at 3.25 m/s and cyclic_trim_lat sat frozen at
# 0.000, because the outer loop was also on its 6-degree attitude stop and the anti-windup
# correctly refused to integrate.
#
# Raising authority to 0.50 and the attitude limit to 8.0, everything else untouched:
#
#                        authority 0.30    authority 0.50
#   drift                   3.25 m/s          0.28 m/s
#   pitch amplitude         3.45 deg          1.24 deg
#   |pitch rate|            4.06 deg/s        1.59 deg/s
#   |roll rate|             2.19 deg/s        0.55 deg/s
#   total_roll_ratio        flat 0.0000       span 0.0400
#
# The two constants are not equally earned, and the difference is worth writing down:
#
#   AUTHORITY IS MEASURED, and was raised twice. In still air the loop settles at a
#   correction of -0.337, which the generic 0.30 could not deliver. The number is the
#   airframe's, not a preference — this cell hovers on -0.461 of left pedal, the second
#   largest standing pedal in the fleet, so its translating tendency is correspondingly
#   large and it genuinely needs to hang further left than anything measured before it.
#
#   Raised again to 0.70 on 2026-09-09, in wind. At 0.50 the roll correction sat on its
#   stop for 38.9 % of a 19 kt hover and the aircraft drifted at 3.04 m/s. At 0.70, in
#   15 kt, it never exceeds 0.542 — so 0.70 carries a real margin rather than being the
#   next round number. What is NOT measured: 0.70 in the full 19 kt. The two wind runs
#   differ in strength as well as in gain, which is why neither is called a comparison.
#
#   ATTITUDE_LIMIT was first raised to 8.0 on that evidence alone: at this gain the outer
#   loop asks for -2.35 - 0.337/0.100 = -5.72 degrees, so the generic 6.0 would just have
#   covered it, and "just" is not a state to leave a limit in that the weather attacks
#   first. It went to 10.0 an hour later for the reason below.
#
# ── And then the integrator hit ITS stop ─────────────────────────────────────
# With the first two limits opened, the gain sweep of 2026-09-08 23:39 showed cyclic_trim_lat
# standing at exactly -5.000 — cyclic.integral_limit_deg — across every stage of the sweep.
# Toggling the assist reset it to -0.275, and it walked straight back to the stop in twelve
# seconds. Anti-windup then correctly froze it, so the outer loop stopped learning again and
# the aircraft never fully settled, which is why the sweep read as "not recovering" all the
# way down to 0.080.
#
# So this airframe breaks all three generic limits of the cyclic cascade, and the reason is
# one number: it hovers on -0.461 of left pedal, second only to the Cabri. A large standing
# pedal is a large tail thrust is a large translating tendency — this cell simply has to
# hang further left than anything measured before it, and three stops in a row forbade it.
#
# 8.0 / 10.0 was not a guess: it is the pairing the AS350, AW109 and AW139 already carry,
# keeping two degrees of headroom between the integrator's stop and the attitude stop so the
# proportional term still has somewhere to go.
#
# ── Third round: 11.0 / 14.0, and it is FLOWN ────────────────────────────────
# Flown 2026-09-09 in 15 kt of crosswind at 8.0 / 10.0, authority already at 0.70:
#
#   cyclic_trim_lat        -8.000 in 100 % of frames, 80.6 s on the stop without a break
#   cyclic_target_roll     -9.39  (integrator 8.0 clamped + P 1.39, never reached the 10.0)
#   cyclic_correction_roll -0.473 median, never above 0.542 against an authority of 0.70
#   drift                   0.695 m/s, and 33 m of travel in 95 s
#
# The chain reads off the log without fitting anything: the integrator is clamped, so the
# setpoint is clamped at 9.39, so the attitude error is 6.47 degrees, so the inner P puts
# out 0.075 x 6.47 = 0.485 — which is what the log says. THE LOOP IS ALLOWED MORE CYCLIC
# THAN IT ASKS FOR; it cannot ask, because the error it is fed is capped upstream.
#
# So the binding limit moved back to the integrator, and 11.0 / 14.0 was the next step with
# the same three degrees of headroom. Flown 2026-09-09 in 8.76 m/s from 271 — MORE wind
# than the run above, which is what makes the comparison worth anything:
#
#                        8.0 / 10.0        11.0 / 14.0
#   wind                  7.58 m/s          8.76 m/s
#   cyclic_trim_lat      -8.000, 100 %     -9.971, 0 % on the stop
#   correction_roll       max 0.542         0.496, never near the 0.70
#   target_roll          -9.39 (capped)    -9.911, never near the 14.0
#   drift p50             0.695 m/s         0.006 m/s
#   travel               33 m in 95 s      0.3 m in 61 s
#
# All three bounds free at once, and the integrator settles at -9.97 — so this airframe
# genuinely needed more than 8.0, and 11.0 carries about a degree of margin at 17 kt.
#
# What that degree is worth, since the standing part is known: still air needs 7.62, so
# 8.76 m/s of crosswind cost 2.35 degrees, or 0.27 per m/s. That is below the fleet rule
# of thumb of 0.4 and puts the stop at roughly 24 kt of crosswind. Beyond that this cell
# gives up position again, and the amber POS lamp is what says so.
#
# The honest reading of all three rounds: this airframe keeps running out of room, and
# 4.6 of its 8 degrees of trim were never the airframe at all — they are the inner loop's
# droop, correction/inner_kp, largest exactly where the gain is smallest, and this cell has
# the smallest gain in the fleet. Raising limits makes room for an error the controller
# creates. What would remove it is a HIGHER inner_kp — droop is correction/inner_kp, so
# doubling the gain halves it, measured on the EC130 (0.060 -> 0.120). NOT inner_kd: the
# inner output is kp*error - kd*rate, and in a settled hover the rate is zero, so kd
# contributes nothing to a standing error. What kd buys is the damping that lets kp go
# higher, and on this airframe roll rings at 0.100. That makes it the cell where a
# kd-then-kp sweep would pay most, and it has never been flown anywhere.
#
# The wider lesson, and the reason the first gain sweep on this airframe was thrown away:
# THE PITCH OSCILLATION WAS AN ARTEFACT OF THE SATURATED ROLL AXIS. A 4.5 s limit cycle on
# pitch grew steadily with inner_kp and looked exactly like the onset this procedure hunts
# for. It was not: it vanished when the roll axis was given room, at unchanged inner_kp.
# A loop that never settles cannot be swept — the Cabri said the same thing more gently
# when its two sweeps an hour apart disagreed.
const cyclic.authority = 0.70
# cyclic.attitude_limit_deg was 14.0, counted from level. Since #78 every limit counts
# from the hover trim, and the generic 7.5 applies (2026-10-14).
const cyclic.integral_limit_deg = 11.0

# ── Hover trim, and the price of the softest gain in the fleet ───────────────
# Measured 2026-09-09 over the climb of a take-me-up in still air, with inner_kp at the
# swept 0.075: cyclic_trim_lat -7.62 (p10 -7.63, p90 -7.21), cyclic_trim_long -0.109.
const cyclic.hover_trim_lat  = -7.621

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.075, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 4 flights 2026-09-09 .. 2026-10-08: pitch -2.35
# (-2.43 .. -2.16), roll -2.50 (-2.91 .. -1.96). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = -2.35
const cyclic.hover_attitude_lat  = -2.50
const cyclic.hover_trim_long = -0.109

# Design rotor speed, the yardstick of the rig check's overspeed line (issue #47).
# From .acf _prop/0/_des_rpm_prp; 13 reference flights hover at 100.0-100.1 %.
const rotor.design_rpm = 392

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 16.000 ft, times two.
const rotor.diameter_m = 9.75

# ── Assistant (docs/adding-an-aircraft.md §5e), 2026-10-08 ───────────────────
# First assistant flights after the move to the standard axes (see Write access). With the
# stick deflected the rotor now gets the attitude command alone: pitch stick -0.81, total
# +0.217 against a correction of +0.201; roll stick +1.00, total -0.372 against -0.368.
#
# THIS AIRFRAME RUNS AT 12-15 FPS on the reference rig (every log since 2026-09-08; 12.7 in
# these), against 19 and more for the rest of the fleet — the rig check reports it red. One
# control step is 79 ms. inner_kp 0.075 above was swept at that rate, and so was this:
#
#   kd 0      23:09  pitch swinging 3-4.3 deg peak to peak at 4.8 s, slowly decaying
#   kd 0.010  23:18  0.5-1.7 deg; rate RMS hover 0.24/0.30, straight 0.61/0.73 deg/s
#
# Kept at 0.010 on purpose, below the fleet's 0.020-0.040: the derivative is taken over one
# frame, and the AW139 showed at 19 fps what a late derivative does (roll beating at the
# stop with 0.040). On a faster machine both kp and kd want sweeping again.
const cyclic.inner_kd = 0.010
#
# From assistant_check.py power over all MD 902 references: level-flight collective 0.620
# hovering, rising to 0.652 at 6 m/s, then a slope down to 0.542 at 11 — no step, so the
# long lead the tool proposes (B206, R66 alike). Unflown.
const collective.assist_lift_lost_below_ms = 9.0
const collective.assist_lift_lost_lead_ms  = 9.0
#
# Not yet flown: the pedal held against the yaw assist in the air (same overwrite as the
# cyclic, so expected to behave alike). The turn ran lively in roll (rate RMS 2.79 deg/s,
# period 2.9 s) on the bank limit of 25 at 20 m/s, radius about 98 m. The stop from
# 18.8 m/s took 1.32 m/s^2 with an 11.8 deg flare and climbed 3.2 m.
#
# THIS AIRFRAME HAS THE TIGHTEST LATERAL AXIS IN THE FLEET, and by a wide margin:
# 8.0 - 7.62 = 0.38 degrees of headroom against wind, where the Bell's 1.68 was already
# called thin enough to need a wind test.
#
# Most of that is not the airframe. It hangs at -3.02 degrees in the hover; the other
# 4.6 degrees are the inner loop's droop, which is correction/inner_kp and therefore
# largest exactly where the gain is smallest. At 0.075 — the lowest gain in the fleet —
# roughly SIXTY PERCENT of the integrator's budget is spent by the controller on itself.
#
# That is the cost side of the sweep, and it is worth stating plainly: the gain that made
# this the stillest hover in the project (0.001 m/s) is the same gain that leaves it least
# able to answer a gust. The two are the same number and cannot be separated by tuning.
#
# What follows, and is NOT yet done:
#   - A wind flight, across the LATERAL axis, is now the most important open measurement
#     on this aircraft. Watch frames on the stop, not the median.
#   - If it clamps, the answer is probably integral_limit 10.0 / attitude_limit 12.0 rather
#     than more gain — more gain rings the roll axis at 0.100. But that is reasoning, not
#     measurement, and this file does not carry reasoning as constants.
#   - A kd-then-kp sweep. inner_kd is 0 fleet-wide and has never been flown anywhere. It
#     does not remove the droop by itself — in a settled hover the rate is zero — but it
#     damps the ring that caps inner_kp at 0.100 here, and a higher kp does remove it.
#     See docs/flight-scripts.md.
#
# Re-flown from a genuine standstill on 2026-09-09 — the log carries the sequence's own
# "ASSIST yaw on; ASSIST cyclic on" at 5.9 s, so this one counts: **6.56 m of offset over a
# 14.4 m path, in 8.78 m/s (17 kt) of wind.** For comparison the EC130 used 27 m in 10 kt.
#
# That it completed at all is the second finding. Before the limits above were raised, the
# sequence stalled at three metres in wind, waiting for a stillness the assist could not
# deliver (issue #28). It now climbs out in 17 kt.
#
# **Flown in dead calm the same evening: 2.61 m of offset over a 4.03 m path**, from a
# genuine standstill, with the closing hover holding drift at p50 0.002 m/s. That puts it
# among the best-measured cells (EC130 0.7 m, AS350 0.2 m, Bell 1.23 m).
#
# The 2.61 m is explained rather than merely small, and the explanation is the loading note
# above. cyclic_trim_lat settled at -6.643 in that hover against the -7.621 this profile
# preloads — 0.98 degrees apart, because the preload was measured a day earlier with a
# different livery and two passengers aboard. At the fleet's 3.3 m per degree of trim
# difference that is 3.2 m of travel, against 2.61 m observed.
#
# So the residual is not controller error and not a bad preload: it is the centre of
# gravity having moved since the constant was measured. **A preload is only as good as the
# loading it was measured at**, and this is the first run in the project where that shows
# up as a number rather than as a caveat.

# ── The standing pedal, and the sign that was predicted before the flight ────
# The same 435 frames: pedal -0.461 (p10 -0.467, p90 -0.459), hands off, the heading
# standing to 0.13 degrees. LEFT pedal.
#
# _prop/0/_prop_dir reads +1 in jrx_md_902.acf, and across the seven airframes measured
# before this one that has meant left pedal without a miss. This is the eighth, and it
# holds. yaw.torque_per_collective is therefore NEGATIVE here — the Robinson family, not
# the EC130 — but its MAGNITUDE still needs a deliberate collective sweep and stays absent
# until then.
#
# Worth recording against the NOTAR question: -0.461 is the largest standing pedal in the
# fleet after the Cabri's +0.637. If X-Plane modelled the Coanda contribution — the part
# of the anti-torque that comes free with rotor downwash — this number would be expected
# to sit low, not high. It does not. The .acf models an ordinary ducted tail rotor
# (_prop/1/_prop_ducted 1, six blades, geared 0.1333 to the main rotor at 2939.8 RPM) and
# nothing here suggests otherwise.

# ── Pilot controls ───────────────────────────────────────────────────────────
# These three read the TOTAL, not the pilot's axis, for the same reason as the Bell: the
# assist commands through the copilot channel, so yoke_*_ratio would keep showing what the
# pilot's hand does and say nothing about what the aircraft was told. A log like that
# cannot support a measurement.
#
# Unlike the Bell, nothing else is mixed in here — artstability is zeroed on this airframe
# (see above). Not a sum, though: the larger of the two channels (see Write access, 2026-10-08).
# On the standard axes they show what the flight model flew, which is the command: X-Plane
# computes total_* in the flight model, and the script's rewrite comes after it.
#
# Safe by construction: no controller reads these. CyclicPitch and CyclicRoll are consumed
# only by the overlay and the recorder (src/ui/overlay_renderer.cpp).
bind cyclic_pitch = sim/cockpit2/controls/total_pitch_ratio   | clamp -1 1
bind cyclic_roll  = sim/cockpit2/controls/total_roll_ratio    | clamp -1 1
bind pedal        = sim/cockpit2/controls/total_heading_ratio | clamp -1 1

# prop_ratio rather than the blade angle, and the two were checked against each other
# rather than assumed. The range is acf_min_pitch -4.0 to acf_max_pitch +7.0 — confirmed
# twice over, since jrx_md902_trim_operation.lua carries the same figures in a comment.
# prop_ratio_all held at 0.300 read back a blade angle of -0.7000 against a predicted
# -0.700, with torque going 2680 -> 3121 Nm. The standard axis is the way in here, so
# none of the AS350's POINT_pitch_deg machinery is needed.
bind collective   = sim/cockpit2/engine/actuators/prop_ratio[0] | clamp 0 1

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
const airframe.vne_kt = 140
bind velocity_east_ms  = sim/flightmodel/position/local_vx
bind velocity_south_ms = sim/flightmodel/position/local_vz
bind position_east_m   = sim/flightmodel/position/local_x
bind position_south_m  = sim/flightmodel/position/local_z

# ── Engine and rotor ─────────────────────────────────────────────────────────
# Two PW207E free turbines. Index 0 is the main rotor; index 1 is the NOTAR fan, which
# reads 2939.8 RPM against the rotor's 392.0 — exactly the _prop/1/_prop_gear_rat of
# 0.13333 from the .acf. The fan is geared rigidly to the rotor and only its blade pitch
# is controlled, so its speed carries no information the rotor's does not.
bind rotor_rpm        = sim/cockpit2/engine/indicators/prop_speed_rpm[0]
bind engine_rpm       = sim/cockpit2/engine/indicators/engine_speed_rpm[0]
bind engine_torque_nm = sim/cockpit2/engine/indicators/torque_n_mtr[0]
bind throttle         = sim/cockpit2/engine/actuators/throttle_ratio[0] | clamp 0 1
# Manifold pressure deliberately unbound: it reads a flat 29.92 inHg, which is ambient
# pressure, because a turbine has no manifold. "n/a" is the truth; a plausible number
# would not be.

# ── Write access ─────────────────────────────────────────────────────────────
# The collective says nothing here, which means the standard axis with no flag. Measured
# 2026-09-08: a +0.15 nudge held 100 % of passes and took torque 1095 -> 2619 Nm.
# override_prop_pitch is touched by the add-on only inside its start-up sequence
# (jrx_md_902_start_up_items.lua sets it to 1 at line 397 and back to 0 at line 454),
# never in a frame loop, so the axis is ours once the aircraft is running.
#
# The other three stay on the standard axes since 2026-10-08 — no write line. Until then
# they went through the copilot channel, and that channel is NOT added to the pilot's:
# X-Plane flies whichever of the two is larger in magnitude. Ground test, 12.4.4, pedal,
# assist off, copilot written over the Web API against a held pilot pedal of -0.353:
#
#   copilot +0.2  total -0.353  (sum would be -0.15)   R  0
#   copilot -0.2  total -0.353  (sum would be -0.55)   R  0
#   copilot +0.4  total +0.400  (sum would be +0.05)   R +17 deg/s
#   copilot +0.6  total +0.600  (sum would be +0.25)   R +30..39 deg/s
#
# and in 53 of 61 samples with both channels non-zero, total was the larger of the two,
# never the sum. So a correction against a held stick never arrived, and under the
# assistant's attitude command the raw stick won whenever it was the larger. The
# measurement of 2026-09-08 ("copilot +0.6, total 0.6000") had the pilot's channel at zero
# and could not tell the two rules apart. Two more facts of the channel: X-Plane clamps it
# at +-1, and a value written there stays after its flag is lowered.
#
# The standard axes instead: the script writes the pilot's axes in after_physics(), AFTER
# the flight model, and AxisOverride::reassert_owned() rewrites the command BEFORE it, so
# the flight model should fly the command. The read-back test of 2026-09-08 (0 % held) does
# not contradict this — it read at an arbitrary moment and saw the script's value; the
# pre-flight-model write did not exist then.
#
# Ground test 2026-10-08 23:05 (assistant, yaw on, rotor 392): the script rewrote the
# pilot's pedal from joy_mapped (0.000) every frame, and total_heading_ratio stood on the
# command for 20 s — -0.322 against -0.320, -0.516 against -0.515. The pre-flight-model
# write wins. Not yet shown with the pedal deflected (the same overwrite, so expected the
# same), nor in the air; the yaw rate on the skids says nothing (-0.5 pedal, -0.05 deg/s).
