# Dreamfoil B206B3 JetRanger (DreamFoil Creations, XP12 v1.05 beta).
#
# Probed against a running X-Plane 12 on 2026-09-12 with the aircraft loaded, first on
# the skids with the rotor at its governed 394.6 RPM and then with the rotor stopped.
# Every parameter a profile has to bind reads through the standard datarefs; of 7754
# datarefs, 225 carry an add-on namespace (df206/, dreamfoil/, geforce/, SmartMenu/),
# and exactly one of those is a writable control channel.
#
# Three of the four axes steer through X-Plane's standard axes. The collective does not,
# and it fails in the way that reads as success: writes to prop_ratio[0] are held
# perfectly and never reach the rotor.
#
#     prop_ratio[0] = 0.25 held 6 s -> swashplate_collective  -1.5 .. -1.5  (span 0.0000)
#                                      torque_n_mtr         1309.77 .. 1309.84
#     df206/controls/collective = 0.25 -> swashplate_collective  1.05 .. 1.98
#                                         torque_n_mtr         1404 .. 2554
#                                         the aircraft got light
#
# This is the AW109's answer on a different aircraft: the standard channel is not the
# way in, and the add-on keeps its own.
#
# ── The read side is NOT the channel we command ──────────────────────────────
# Measured with the rotor stopped and the pilot sweeping the lever over its full travel,
# 109 samples over 25 s:
#
#     joy_mapped_axis_value[5]      0.000 .. 1.000   the lever
#     df206/anim/collective         0.000 .. 1.000   r = 1.0000 against blade pitch
#     df206/rotor/swashplate_coll  -1.500 .. 12.400  degrees
#     df206/controls/collective     flat 0.0000      <- stays silent while the pilot flies
#     prop_ratio[0]                 flat 0.0000      <- dead in both directions
#
# `df206/controls/collective` is an input to the add-on, not a mirror of the axis —
# exactly what 000/joy_rudder_ratio turned out to be on the AW109. Binding the read side
# there would have read a zero meaning "nothing is driving this" as "lever fully down".
#
# `df206/anim/collective` is the honest quantity: it follows the lever when the pilot
# flies and the command when the plugin commands, and it maps onto the blade exactly —
#
#     swashplate_collective = -1.5 + anim/collective * 13.9     max error 0.0000 deg
#
# so both sides of this axis live on the same 0..1 scale and no `units blade_pitch_deg`
# is needed, unlike the MD 902 and the AS350.
#
# ── Two add-on plugins that belong off before measuring ──────────────────────
# `geforce/path_pred_enabled` (writable) drives a camera that follows the predicted
# flight path — the same thing the JRX Bell 407 was withdrawn for, except here it has a
# switch. It costs frames and interferes with judging hover drift.
#
# `df206/anim/collective_friction` and `df206/anim/cyclic_friction` are writable and were
# both 0.0 as shipped. A friction system can hold an axis; if a future write test fails,
# check these before concluding anything about the channel.
#
# ── First flight, 2026-09-12 ─────────────────────────────────────────────────
# Flown by hand into a hover on all three assists; the take-me-up sequence cannot run
# before hover_collective exists. Still air, 410.8 m density altitude, 1326.7 kg, and the
# aircraft's own axis-orientation detector called the collective inverted after 6.4 s,
# which is what the bench measurement had already said.
#
# Two of the three written predictions held and are checked off in docs/onboarding-b206.md:
#
#   prop_dir = +1 -> left pedal      standing pedal -0.383, left.  HELD (9 of 9)
#   generic cyclic limits hold       0.0 % of frames at the 5.0 deg stop.  HELD, barely:
#                                    the longitudinal integrator peaked at 4.940, which is
#                                    1.2 % of headroom. It will bind in wind.
#   inner_kp near 0.10               MISSED. Swept 2026-09-12: onset at 0.090..0.100,
#                                    chosen 0.075. The regression said 0.098..0.110, so it
#                                    is out by a factor of 1.39 — the fourth predictor to
#                                    fail, and the range it gave (0.06..0.16) was still
#                                    useful. Adding this point drops `rotor_mi_rat` from
#                                    r = -0.433 to -0.387 over ten cells.
#
# ── What is NOT set here, and why ────────────────────────────────────────────
# `yaw.torque_per_collective` stays absent although this log regresses to -1.037 at
# r = -0.920 over 2061 frames, and although the cross-check is tempting: at the measured
# hover collective that line predicts -0.387 of pedal against a standing -0.383.
#
# It is not kept because the slope moves with the filter — -0.751 to -1.102 across eight
# reasonable choices, a factor of 1.47. The reason is known and disqualifying: the height
# hold was engaged, so the collective moved because the controller moved it, not because
# anybody swept it. The procedure asks for a deliberate sweep with the height hold OFF for
# exactly this reason, and the Cabri is what happens when that is skipped.
#
# Zero here means the feedforward is simply not applied, which costs build-up time on the
# pedal and commands nothing wrong. That is the right trade until the sweep is flown.

name      = Dreamfoil B206B3 JetRanger
acf_match = DF206B3_XP12
icao      = 206B3

# ── Measured constants ───────────────────────────────────────────────────────
# 500 settled frames over 28 s, all three assists engaged, above 5 m AGL with vertical
# speed under 0.25 m/s and drift under 0.35 m/s. Still air; wind read 0.00 throughout.
#
# The generic default is 0.400, which is 0.107 low on this airframe — it sits between the
# R22's 0.418 and the AS350's 0.558, as a 1451 kg turbine single should.
#
# Conditions matter for this one: 410.8 m density altitude and 1326.7 kg. The learner will
# re-measure it on the user's rig, which is the point of the fourth layer.
const collective.hover_collective = 0.507

# The lean the outer cyclic integrator settles at, same 500 frames, sd 0.12 and 0.10.
# Independently confirmed by the learner on the next flight, which had no knowledge of
# this calculation: 0.5023 / 4.9358 / -2.6106 over 650 frames and 30.0 s. Three routes,
# one answer — the same agreement the R66 showed.
#
# MEASURED AT cyclic.inner_kp = 0.060, which is the gain again since 2026-10-04 (see
# below), so they are valid as they stand. They were stale for the three weeks it ran at
# 0.075.
#
# The longitudinal figure is also the one to watch: 4.94 against an integral limit of 5.0
# is 1.2 % of headroom, and the attitude actually flown is +4.42 deg, which is a lot of
# nose-up for a hover. The higher gain buys roughly 0.1 deg back. It will still bind in
# wind, and the first wind flight is where cyclic.integral_limit_deg gets decided.
#
# VALID ONLY AT THE GAIN THEY WERE MEASURED AT. This is attitude plus the
# inner loop's standing error, and that error is correction/inner_kp — sweeping the gain
# moves these two numbers without anything about the helicopter having changed. The R66
# did exactly that: 2.66 -> 1.65 when its gain went 0.060 -> 0.110.
#
# The attitude actually flown was +4.42 / -1.95 degrees, so the droop is 0.46 and 0.77 —
# small for a gain this low, which is itself worth re-checking after the sweep.
const cyclic.hover_trim_long = 4.88
const cyclic.hover_trim_lat = -2.72

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.06, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 6 flights 2026-09-12 .. 2026-10-15: pitch +4.70
# (+4.17 .. +5.02), roll -2.05 (-2.39 .. -1.82). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = 4.70
const cyclic.hover_attitude_lat  = -2.05

# Sized for the assistant on 2026-10-08, not flown. Both bounds are absolute, not from the
# trim. attitude_limit: the generic 6 left 1.1 deg of nose up above the +4.88 trim, less
# than the AW139's 3.7 that could not brake from 41 m/s; 12 gives 7.1, as the B412.
# integral_limit: the trim alone (4.94 by the learner) took 98.8 % of the generic 5; 8
# leaves 3 deg, about 8 m/s of tailwind at the fleet's 0.4 deg/(m/s) upper bound. The wind
# flight decides it.
# cyclic.attitude_limit_deg was 12.0, counted from level. Since #78 every limit counts
# from the hover trim, and the generic 7.5 applies (2026-10-14).
const cyclic.integral_limit_deg = 8.0

# Swept in flight 2026-09-12, still air, recorded. Roll is the axis that rings, as on the
# Cabri and the R66. Roll rate p90 in 2 s windows on the way up:
#
#     0.060   0.14 .. 0.77, no trend        quiet
#     0.080   0.34 .. 0.60, no trend        quiet
#     0.090   0.80 .. 1.08, creeping up     onset
#     0.100   1.51 -> 2.84 over 8 s         growing, so already unstable
#     0.110   5.57 -> 19.69 over 10 s       diverging
#
# Onset 0.090..0.100, and 0.075 sits a factor 1.27 below it — the fleet carries 1.29..1.33,
# which is the strongest number this project has.
#
# The way back down is NOT usable from this run and no onset is claimed from it. The ring
# from 0.110 decayed monotonically with time rather than with the gain: 19.5 at 0.095, 15.0
# at 0.080, 2.3 at 0.070, 0.84 at 0.065, falling right through the steps. That is the
# defect issue #42 describes — one recording for the whole sweep, steps of 3 to 10 s, too
# short for the aircraft to settle. A proper reverse sweep wants one recording per step.
#
# Back to 0.060 on 2026-10-04 (X-Plane 12.4.4b3), unflown at that value since 2026-09-12. At
# 0.075 the same aircraft rang where it had been quiet: hover with POS roll RMS 2.2-2.7 deg/s
# against 0.53-0.69 on 2026-09-12, and in the descent to land with POS on and hands off it
# grew from 3.4 to 11 deg/s, worst at 9-13 m. The R66 and the EC130 show the same: the onset
# has moved down under the same gain and mass, apparently with the X-Plane beta. At 0.060
# the 2026-09-12 hovers were quiet (0.30-1.33). reference_flights/Dreamfoil_B206B3_JetRanger/
# 2026-10-04_19-00-17.
const cyclic.inner_kp = 0.060

# Rate damping for the assistant, flown 2026-10-08 19:41 in Full at kp 0.060 (assistant_check,
# rate RMS pitch/roll): hover 0.27/0.16, straight 0.26/0.44, turn 0.41/1.38 deg/s, all calm,
# the descent to land included; stop from 22.6 m/s at 1.50 m/s^2 with the 12 deg limit. Set by
# the pilot from the start ("eigentlich perfekt"), kd 0 and 0.040 not flown on this cell.
const cyclic.inner_kd = 0.020

# Design rotor speed, the yardstick of the rig check's overspeed line (issue #47).
# From .acf _prop/0/_des_rpm_prp; 7 reference flights at 93.9-99.6 %.
const rotor.design_rpm = 394

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 16.630 ft, times two.
const rotor.diameter_m = 10.14

# Where translational lift goes, for the assistant's floor when slowing down (#54). From the
# level-flight collective of the 9 reference flights above 15 m (tools/assistant_check.py
# power, 2026-10-08): 0.540 at 1 m/s, 0.499 at 5, 0.453 at 7, 0.437 at 8, 0.385 at 9, 0.327
# at 13 (no data 10-12) — a slope, steepest from 7 to 9. Unflown.
const collective.assist_lift_lost_below_ms = 6.0
const collective.assist_lift_lost_lead_ms  = 8.0

# ── Bindings ─────────────────────────────────────────────────────────────────
bind cyclic_pitch = sim/cockpit2/controls/yoke_pitch_ratio | clamp -1 1
bind cyclic_roll = sim/cockpit2/controls/yoke_roll_ratio | clamp -1 1
bind pedal = sim/cockpit2/controls/yoke_heading_ratio | clamp -1 1

# NOT prop_ratio[0]: it reads a flat 0.0000 whether the pilot flies or the plugin
# commands. See the header.
bind collective = df206/anim/collective | clamp 0 1

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
const airframe.vne_kt = 130
bind velocity_east_ms = sim/flightmodel/position/local_vx
bind velocity_south_ms = sim/flightmodel/position/local_vz
bind position_east_m = sim/flightmodel/position/local_x
bind position_south_m = sim/flightmodel/position/local_z
bind rotor_rpm = sim/cockpit2/engine/indicators/prop_speed_rpm[0]
bind engine_rpm = sim/cockpit2/engine/indicators/engine_speed_rpm[0]
bind engine_torque_nm = sim/cockpit2/engine/indicators/torque_n_mtr[0]
bind throttle = sim/cockpit2/engine/actuators/throttle_ratio[0] | clamp 0 1

# manifold_pressure deliberately unbound: a single Allison 250-C20J turbine. The dataref
# exists and reads 29.92, which is ambient pressure and not an engine indication —
# binding it would put a plausible-looking number where "n/a" is the truth.

# ── Writes ───────────────────────────────────────────────────────────────────
# The three axes not named here go through X-Plane's standard axes, which is what saying
# nothing means. No override flag on the collective: the add-on reads this dataref
# directly, and the plugin writes every frame anyway.
#
# #71 does not apply here, so no override_prop_pitch either. On X-Plane's lever the hardware
# took the collective for a frame on every change (R22, AW139, B412); this channel is the
# add-on's own, and the lever never reaches the rotor through it: 0 frames on the lever over
# 114, 27 and 240 airborne lever changes (2026-10-08, 10-09, 10-10). The flag would freeze
# X-Plane's props under an add-on that sets the rotor itself.
write collective = df206/controls/collective
