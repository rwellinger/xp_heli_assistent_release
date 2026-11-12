# Bell 407 (JRX Design, v1.41)
#
# The first Bell in the fleet, and the first airframe that gives up only part of itself.
# Everything here was read back from a running X-Plane 12 over the Web API on 2026-09-07.
#
# ── The pilot's axes are held; the copilot's are not ─────────────────────────
# The add-on flies its own cyclic and pedals. From b407_22_trim_functions.lua, in
# after_physics(), so on every frame:
#
#     override_pitch = 1; override_roll = 1; override_yaw = 1
#     yoke_pitch = clamp(joy_pitch + pitch_offset, -1, 1)
#     yoke_roll  = clamp(joy_roll  + roll_offset,  -1, 1)
#     yoke_yaw   = clamp(aaps_apply(joy_yaw + yaw_offset), -1, 1)
#
# That is a force-trim implementation, and a good one — it is why those axes are held. A
# write of -0.6 to yoke_heading_ratio, held for five seconds, read back 0.0058 in all
# twenty-two samples and never moved the yaw rate. Both ways round it are shut:
# joy_mapped_axis_value, which the script reads from, is read-only, and the
# jrx/b407/controls/cyclic/*_output datarefs are animation outputs it overwrites each frame.
#
# What it never touches is the copilot side. The script sets
# override_joystick_{pitch,roll,heading}_copilot only in aircraft_unload() and
# flight_crash(), never in the frame loop — so the seat beside the one it flies is empty.
# Measured 2026-09-07 on the ground, rotor at 413 RPM, each value held and read back on
# every pass:
#
#   pedal   yoke_heading_ratio_copilot = -0.6  held 100 % (22/22), yaw rate +0.2 -> -3.5 deg/s
#                                      = +0.6  held 100 % (23/23), yaw rate      -> +2.5 deg/s,
#                                              heading 7.9 deg in 5 s
#   roll    yoke_roll_ratio_copilot    = +0.3  held 100 % (14/14), the aircraft leaned right
#   pitch   yoke_pitch_ratio_copilot   = +0.3  held 100 % (14/14), attitude followed
#
# The sign reversal on the pedal is what makes this a measurement rather than a coincidence:
# the yaw rate on this airframe wanders about 0.3 deg/s on its own at idle, and both
# commands moved it an order of magnitude further, each in its own direction.
#
# ── The two channels add, and the pilot wins ─────────────────────────────────
# Measured in the same session: with the copilot roll held at +0.6 the aircraft sat at
# +2.02 deg. Full left cyclic from the pilot took that to +0.09 deg — his input cancelled
# the assist outright. So the pilot can always overrule, which is the property that matters,
# and the command is *additive* rather than absolute.
#
# That suits the cyclic assist, which is additive anyway. It does NOT suit the yaw damper,
# which commands the whole pedal position: while the pedals rest the sum is the command and
# all is well, but a pilot pressing a pedal gets his own input twice. This is not yet
# resolved and must be measured in flight before the yaw assist is trusted here. On the
# ground the exact combination rule cannot be separated cleanly — the skids bound the
# attitude — so "they add" is the honest reading of this run, not a proven formula.
#
# Superseded 2026-10-08: X-Plane flies the larger of the two channels, not their sum (MD 902
# matrix test), and both assists now write the standard axes, ahead of the script. The pedal
# held against the yaw assist was flown on 2026-10-09 08:23: ±0.5 turned ±16 deg/s, ±1.0
# ±33 deg/s, linear — the pilot's input arrives once, not twice.

name      = JRX Bell 407
acf_match = Bell 407
icao      = B407

# ── Measured constants ───────────────────────────────────────────────────────
# Measured 2026-09-07, still air (wind 0.00 m/s in every frame), 1721.5 kg, density
# altitude 412.6 m, in a settled hover at 106 m — outside ground effect.
#
# 367 frames with the altitude hold engaged and the height standing at 105.9 m: median
# 0.5461, p10 0.5460, p90 0.5462. A spread of two ten-thousandths over twenty seconds,
# with the vertical speed at +0.0005 m/s. A live read through the Web API during the same
# hover returned 0.5462.
#
# What this number cost, before it existed: the take-me-up sequence lifted off on the
# ramp's 0.500, the collective hold engaged at 0.50 m AGL and immediately commanded the
# generic 0.400 — and the aircraft was back on the ground half a second later. Twice.
const collective.hover_collective = 0.546
#
# Confirmed the same evening at a different weight, which is the check that costs nothing:
# 0.5240 over the closing hover of the take-me-up flight at 1592.4 kg and 491.1 m density
# altitude. 129 kg lighter and 79 m higher — the mass pushes the number down, the density
# altitude up, and the mass wins by 0.022. Two readings that move the right way are worth
# more than one reading repeated.
#
# The shipped value stays at the heavier measurement: it is the one the take-me-up was
# flown on, and a hover collective set slightly high costs a moment of climb at engagement
# while one set low is what put the aircraft back on the ground twice.

# The climb was flown 2026-09-07 at this setting: 4.91 m/s sustained over 23 s, rotor from
# 413.0 down to 402.3 RPM (2.6 % droop, well clear of the 8 % guard) and torque peaking at
# 9848 Nm. The generic 2.0 left three quarters of the airframe unused. Not the limit — the
# limit was never reached — but a rate this airframe demonstrably holds.
#
# A hand-flown collective exercise in the same flight puts a ceiling under that number
# rather than leaving it a guess: 5.99 m/s sustained over 17 s at collective 0.623 with the
# rotor between 411.2 and 423.4 RPM — no droop at all. It only breaks at the top of the
# lever: catching a 9.8 m/s descent with collective at 1.000 pulled the rotor to 317.8 RPM,
# 77 % of governed speed. The sequence's own guard trips at 92 %, well before that.
# Swept 2026-09-07 in still air, 100 m hover, all three assists on, hands off the cyclic.
# The gain is reconstructed from the log rather than from anyone's notes —
# cyclic_correction_roll / (cyclic_target_roll_deg - roll_deg), exact because inner_kd is 0 —
# and the sweep was flown twice in one recording:
#
#   0.060 .. 0.130   roll rate p90 0.02 .. 0.20 deg/s      quiet throughout
#   0.280            24.1                                   ringing, correction on its stop
#   0.250            21.9                                   still ringing
#   0.230            20.5 -> 15.8                            still ringing
#   0.220             9.3 -> 4.9 -> 2.9 -> 1.5 -> 0.15       DECAYS
#
# Second pass, same recording: 0.270 loud, 0.240 and 0.230 loud, 0.220 decays (14.5 -> 7.5
# -> 3.8 -> 2.2 -> 0.6). Onset on the way down is therefore 0.230, and 0.230 / 1.3 = 0.177.
#
# It is the ROLL axis alone. Pitch stayed between p90 0.07 and 0.43 deg/s across the whole
# sweep and never took part.
#
# 0.175 is the highest inner gain in the fleet by a wide margin — the previous ceiling was
# the EC130's 0.155 at 2000 kg, and this airframe hovers at 1600. The mass ordering was
# already broken by the Cabri; this buries it. Whatever sets this number, it is not weight.
#
const cyclic.inner_kp = 0.175

# ── Hover trim, and how much of it was ever the controller ───────────────────
# Measured 2026-09-07 over the climb of a take-me-up in dead-still air (wind 0.00 in every
# frame), with inner_kp at the swept 0.175.
#
# Having the same aircraft flown at two gains separates the two things this number contains
# for the first time in this project. The inner loop is pure proportional, so it holds a
# standing attitude error of correction/inner_kp — the integrator settles at
# "physical lean + that error", and the error shrinks with 1/kp:
#
#   inner_kp 0.060:  long +2.34   lat -3.85
#   inner_kp 0.175:  long +2.08   lat -3.32
#   -> droop at 0.060 was +0.40 / -0.81, and the airframe's own lean is +1.94 / -3.04
#
# The check was already in the same recording and was not fitted to: the closing hover reads
# +1.920 and -2.974 against those computed +1.94 and -3.04.
#
# So the Bell really does hang about three degrees left in the hover — translating tendency,
# as it should be — and only a bit under a degree of the old reading was the low gain. The
# expectation going in was that most of it would evaporate. It did not.
# ── Wind, flown 2026-09-07 ───────────────────────────────────────────────────
# 8.0 to 12.55 m/s (16-24 kt) from 000 against a heading of 041, so off the left bow, over a
# take-me-up plus a minute of hover:
#
#   trim_long  +0.544  (it was +2.08 in still air — a headwind RELIEVES the pitch axis)
#   trim_lat   -3.288 median, -4.468 at its worst
#   frames on the 5.0 stop: 0 of 1337, on both axes
#   drift p80 0.356 m/s, and 0.9 m of travel over 58 s
#
# Under a metre of position at 24 knots. The prediction going in was that the lateral axis
# would hit its stop around 8 kt, from the fleet rule of thumb of 0.4 deg of trim per m/s.
# It does not hold here: roughly 8 m/s of crosswind component cost 1.15 deg, so 0.14 deg per
# m/s, a third of the expectation.
#
# What it leaves open: 0.53 deg of headroom on the lateral axis at its worst. The wind came
# off the bow, so a DIRECT crosswind of the same strength would probably clamp it — and a
# clamped integrator is the quiet failure, where the aircraft flies on and simply stops
# holding position (the amber POS lamp is there for exactly this). cyclic.integral_limit_deg
# is deliberately NOT raised: the stop was never reached, and a profile entry without a
# measurement behind it is the thing this system exists to prevent. The AS350 needed 8.0
# because its integrator was measured at 5.72. Fly a direct crosswind before changing it.

const cyclic.hover_trim_long = 2.081
const cyclic.hover_trim_lat  = -3.324

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.175, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 8 flights 2026-10-08 .. 2026-10-15: pitch +1.63
# (+1.30 .. +2.12), roll -2.14 (-2.49 .. -1.85). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = 1.63
const cyclic.hover_attitude_lat  = -2.14

# sequence.climb_rate_ms = 5.0: the trainer's take-me-up climb, not used by the assistant.

# ── Back in the fleet 2026-10-08; assistant desk steps (§5e) ─────────────────
# Design rotor speed for the rig check's overspeed line (#47): .acf _prop/0/_des_rpm_prp
# 413.0; ten reference flights hover at 413.0-413.4.
const rotor.design_rpm = 413
# Ground-effect band of the assistant (#54): .acf _blad/0/_semilen_SEG 17.487 ft, times two.
const rotor.diameter_m = 10.66
# Room for the stop: the hover pitch trim is +2.08, so the generic attitude limit of 6 left
# 3.9 deg of flare (fleet 4.8-7.9; the AW139 at 3.7 slowed at 1.1 m/s^2). 9 gives 6.9 —
# flown 23:33, see below. The 22:24 flight that flared to 27.8 deg ran on the copilot
# channel and says nothing about the limit.
# cyclic.attitude_limit_deg was 9.0, counted from level. Since #78 every limit counts
# from the hover trim, and the generic 7.5 applies (2026-10-14).
# assistant_check.py power over the Bell references: level-flight collective 0.56 at
# 2-3 m/s, 0.574 at 6, then falling to 0.40 by 14 — a slope. The tool's starting value,
# unflown.
const collective.assist_lift_lost_below_ms = 9.0
const collective.assist_lift_lost_lead_ms  = 5.0
#
# First assistant flight on the standard axes, 2026-10-08 23:33 (12.4.4 beta, 21 fps, Full,
# two flights in one log). The stick no longer reaches the rotor past the command: pitch
# stick -0.86, total +0.042 against a correction of +0.024 (the rest is X-Plane's artificial
# stability, see the read side). Rate RMS pitch/roll, deg/s:
#
#             hover        straight     turn
#   kd 0      0.56/1.24    1.18/2.11    0.62/3.82  rocking at 0.5 s
#   kd 0.020  0.32/0.21    0.80/1.50    0.46/1.80
#
# The pilot: steers as well as the other Bell. Stops at 1.17 m/s^2 from 16.7 m/s with 7.2 deg
# of room above the trim, so attitude_limit 9 holds.
#
# Hand-back (§5c), 2026-10-08 23:49: altitude hold off in a hover at 22.9 m, command 0.559
# walked to the lever at 0.543 in 1.4 s (the minimum duration) without a step, and the
# rotor followed the lever to 0.0000, median and maximum, over 1899 frames and its whole
# travel down to the landing. The gap was small (0.016) — the shared fade's worst case was
# flown on the MD 902 and the AW139, not here. The pedal held against the yaw assist:
# flown 2026-10-09, see the top of this file.
const cyclic.inner_kd = 0.020
#
# Note for whoever flies it: sim/custom/407/artstab_mode was found on 2 ("Medium
# Assistance") and has to go to 0 first. It is not the autopilot — it swaps X-Plane's own
# artificial-stability constants (sim/aircraft/artstability/*), and mode 2 raises the roll
# rate damping from 0.015 to 0.065 and the yaw authority from 30 to 60. Anything measured
# with it up is a constant of the combined system. The command that cycles it is
# 407/Switches/Controls/flight_mode.

# yaw.torque_per_collective is deliberately absent, and the attempt to measure it is worth
# recording. A collective exercise on 2026-09-07 (2549 frames, collective 0.00 to 0.93)
# regresses to a slope anywhere between -0.192 and -0.648 depending on which frames are
# kept — a factor of 3.4 — and the best correlation reached is r = -0.804, below the 0.85
# this project requires before it will print a number at all.
#
# The reason is in the manoeuvre, not the maths: the collective was moved to climb and
# descend, so the yaw rate never settled between steps (p90 3.5 deg/s, peaks to 60). The
# sweep that works holds each step long enough for the rate to die, in a hover, with no
# altitude hold and no forward speed.
#
# What IS known: the sign. The aircraft hovers on -0.139 of LEFT pedal, read twice 220 s
# apart in the same flight (-0.1392 and -0.1382 at collective 0.5247 and 0.5240). It turns
# like the Robinsons and unlike the EC130, so a copied EC130 slope would drive the yaw it
# exists to cancel. And the two best-correlated fits predict -0.128 and -0.134 of pedal at
# the measured hover collective against -0.139 observed — close enough to say the shape is
# right and the magnitude is not yet earned.
#
# Its absence has a price, and the same flight shows it: without feedforward the damper
# saturated in 2.2 % of frames and the heading wandered 99 degrees across the collective
# exercise. That is the standing pedal being relearned from zero on every power change.

# ── Cockpit state the constants above rest on (read 2026-09-07 from the running sim) ──
#   sim/custom/407/artstab_mode                  0  "Realistic baseline", NOT SAS off
#                                                   (acf_ASh_lo_rate 0.015, ASp_lo_rate 0.025,
#                                                    ASh_hi_pos 1.0, ASmaxr_lo 30.0)
#   jrxDR/407/overhead/switches/force_trim_power 0  off, at 28.2 V bus — so the script's
#                                                   trim_active is false and no offset is
#                                                   added to any axis
#   jrx/b407/controls/cyclic/trim_rate           0  only scales the trim keys while held
#   AFCS / autopilot unit                           inactive
#
# The tablet's "Fly With Copilot" and "Dual Flight Controls" switches do NOT touch this, and
# the proof is the flying rather than the reading: every measurement here — the ground test
# on all three axes, the full take-me-up, both hovers — was made with "Fly With Copilot"
# switched OFF. The copilot channel works with nobody in the seat. The two share a name and
# nothing else: one is a 3D object with a mass, the other is X-Plane's second control input.
#
# The code agrees. Neither jrxDR/407/configuration/options/copilot nor .../dual_FC appears
# anywhere in b407_22_trim_functions.lua, the one file that drives an axis; they live in
# kill_objects (3D objects) and fuel_weights (mass). Set them freely.
#
# The script does know our three overrides — it looks them up at lines 24-26 — but writes
# them at exactly two places, aircraft_unload() and flight_crash(), both setting 0. Never in
# the frame loop, and it never writes yoke_*_ratio_copilot at all. One consequence worth
# knowing: a crash hands the overrides back. Harmless, because the controllers stand down
# after a crash anyway and re-assert the flag when re-engaged.
#
# Mode 0 is the right one to measure on: X-Plane's artificial stability runs on every
# helicopter in the fleet, so this stays comparable. Mode 2 — where the first onboarding
# attempt found it — raises roll damping from 0.015 to 0.065 and yaw authority from 30 to
# 60, and every constant taken there would be one of the combined system. Command to cycle
# it: 407/Switches/Controls/flight_mode.

# ── Pilot controls ───────────────────────────────────────────────────────────
# These three read the TOTAL, not the pilot's axis, and this airframe is the reason. The
# assist commands through the copilot channel, so yoke_*_ratio keeps showing what the
# pilot's hand does and nothing else: over 6269 frames of a flight with all three assists
# running, `pedal` spanned 0.0175. A log like that cannot say what the aircraft was being
# told to do.
#
# X-Plane already keeps the answer. From DataRefs.txt: "Total rudder control input (sum of
# user pedal plus autopilot servo plus artificial stability)". Measured 2026-09-07 with the
# assists live and hands off:
#
#   axis    copilot command   pilot axis   total_*_ratio
#   roll        -0.151          +0.005        -0.113
#   pitch       +0.093           ~0           +0.146
#   yaw         -0.025          +0.002        -0.047
#
# (Not a plain sum, and the copilot channel is not added at all — the larger of the two
# channels wins, see Write access; on the standard axes the copilot column is gone.)
# The remainder is X-Plane's artificial stability, which runs at
# SAS mode 0 on this aircraft and is part of what actually reaches the rotor. That makes
# these columns MORE honest than a raw axis, and it also makes them not directly comparable
# with the other seven profiles, which read the axis the assist writes to. Say so before
# comparing a Bell number against an R22 one.
#
# Safe by construction: no controller reads these. CyclicPitch and CyclicRoll are consumed
# only by the overlay and the recorder (src/ui/overlay_renderer.cpp), so this changes what
# is logged and displayed, never what is flown.
bind cyclic_pitch = sim/cockpit2/controls/total_pitch_ratio   | clamp -1 1
bind cyclic_roll  = sim/cockpit2/controls/total_roll_ratio    | clamp -1 1
bind pedal        = sim/cockpit2/controls/total_heading_ratio | clamp -1 1
# prop_ratio rather than the blade angle, and the two were checked against each other
# rather than assumed: the range is acf_min_pitch -4.0 to acf_max_pitch 12.0, and
# prop_ratio 0.2596 read back as 0.1537 degrees against a predicted 0.154. Under the
# collective hold, 0.400 read back as 2.400 against a predicted 2.400. The AS350's
# corruption of prop_ratio came from writing POINT_pitch_deg, which this airframe does not
# need — it is steered through the standard axis.
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
# Rotor and engine read the same 413.0 RPM, as on the EC130 — the gauge is downstream of
# the gearbox on both.
bind rotor_rpm        = sim/cockpit2/engine/indicators/prop_speed_rpm[0]
bind engine_rpm       = sim/cockpit2/engine/indicators/engine_speed_rpm[0]
bind engine_torque_nm = sim/cockpit2/engine/indicators/torque_n_mtr[0]
bind throttle         = sim/cockpit2/engine/actuators/throttle_ratio[0] | clamp 0 1
# Manifold pressure deliberately unbound: it reads a flat 29.92 inHg, which is ambient
# pressure, because a turbine has no manifold. "n/a" is the truth; a plausible number
# would not be.

# ── Write access ─────────────────────────────────────────────────────────────
# The collective says nothing here, which means the standard axis with no flag — measured
# 2026-09-07: prop_ratio_all = 0.40 held 100 % of passes, blade angle -0.20 -> 2.40 deg,
# torque 2116 -> 4396 Nm, the aircraft came light.
#
# The other three are on the standard axes since 2026-10-08 — no write line. Until then
# they went through the copilot channel, and that channel is not added to the pilot's:
# X-Plane flies whichever of the two is larger in magnitude (measured on the MD 902 by the
# same developer, see its profile, Write access). A correction against a held stick never
# arrived, and under the assistant the raw stick won whenever it was the larger — the
# reference flight of 2026-10-08 22:24 (stick -0.31 against a correction of +0.30, flare
# 27.8 deg against a limit of 6, bank 33 against 25) is that.
#
# The script writes the pilot's axes only in after_physics() (b407_22_trim_functions.lua,
# checked 2026-10-08; the collective is read there for the animation, never written), and
# AxisOverride::reassert_owned() rewrites the command before the flight model — the route
# proven on the MD 902 the same evening. UNFLOWN on this airframe.
#
# #71 (2026-10-10): NOT behind override_prop_pitch. The tail-rotor ground test passed and a
# flight behind the flag (20:29, fm 4) had none of 179 lever changes on the lever, but the
# airframe rocked in roll in turns (0.3 s, stick at -0.9) and the cockpit view stood tilted
# on the ground, with fm 8 as well. Flown again without the flag the same evening: calm, by
# the pilot's judgement (no log). The lever may take the collective for a frame here.
#
# The constants above were flown on the copilot channel in hover with the stick near
# centre, where both rules give the same total, so they carry over.
