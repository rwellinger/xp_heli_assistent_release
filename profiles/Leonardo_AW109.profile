# Leonardo AW109 (X-Trident). **Nothing here has been verified against a running sim.**
#
# This is a starting point for measuring, not a supported aircraft.
#
# **It is a different add-on developer from the AW139, and that matters more than the two
# type names looking alike.** The first draft of this profile was written on the
# assumption of a shared developer and reasoned from how the AW139's xlua scripts behave.
# That assumption was wrong, and nothing about how this aircraft is *implemented* can be
# inferred from the other — which datarefs it honours, whether writes reach the flight
# model, what its own systems own. Two helicopters from one manufacturer are two
# completely unrelated pieces of software.
#
# Carried across, and deliberately only this much:
#
#   - **The bindings** — which are not AW139 figures at all, but the standard datarefs
#     every profile here uses, and the reason the R22 was chosen as reference in the
#     first place. On this aircraft they are a hypothesis, not a starting point: assume
#     nothing until section 1 of docs/adding-an-aircraft.md has been worked through, in
#     particular that writing prop_ratio reaches the flight model and that
#     prop_speed_rpm index 0 is the main rotor.
#   - **The two raised bounds.** Their error is asymmetric: too small and the assist
#     cannot hold at all — that is the EC130 sliding 86 m downwind with every lamp lit —
#     while too large only grants room it need not use. That asymmetry is a property of
#     the control loop, not of either airframe, which is why it survives the developer
#     being different. Whether this aircraft needs them raised is unmeasured.
#
# Deliberately NOT carried across. The reason is the same each time: here a wrong value is
# worse than none, and zero is what the consumers are written to treat as safe.
#
#   - `cyclic.hover_trim_long/lat` (+6.27 / -1.17). Preloaded as attitude the moment the
#     assist engages. On an airframe that hovers at two degrees, that hands the student a
#     four-degree lie at the handover. Zero costs about 3.3 m of room per degree of trim
#     and nothing else.
#   - `collective.hover_collective` (0.485). The AW109 is less than half the mass, and
#     this value sets the power the lift ramp commands off the ground.
#   - `cyclic.inner_kp` (0.105). Never swept even on the AW139 — chosen by feel and known
#     to be calm, with no measured margin behind it. Passing an unswept value to a second
#     airframe is precisely how the R22's 0.060 travelled to three heavier machines.
#   - `yaw.torque_per_collective`. Nothing to copy — the AW139's is still 0. See
#     docs/adding-an-aircraft.md, which says never to copy it in any case, because its
#     sign follows the rotor's direction of turn and a wrong sign drives the yaw.
#
# Measure it in the order docs/adding-an-aircraft.md gives: feasibility, then the inner
# gain sweep, then the constants, then the sequence.

name      = Leonardo AW109
acf_match = AW109
icao      = A109

# ── Measured constants ───────────────────────────────────────────────────────
# Back to 8.0. The 12.0 that briefly stood here came from a hover flown with the
# aircraft's own AP1 and AP2 running, so what looked like an integrator pinned on
# its stop was two controllers fighting. Flown clean the same evening — AP off,
# wind 0.00 — the integrator settles at 4.342 with 3.66 degrees to spare.
const cyclic.integral_limit_deg = 8.0

# Raised from 10.0 to 13.0 on 2026-10-08 for the assistant's stop. The bound is absolute, not
# from the trim: at +5.3 deg of hover trim 10 left 4.7 deg of nose up, and the stop from 32 m/s
# sat on it for 25 s (target 10.0, the airframe flaring to 11.5 against an inner loop pushing
# the nose down by 0.15), slowing at 0.78 m/s^2 over 40 s (21:15) — as the AW139 did at 3.7.
# 13 gives about 7.7, as the AW139's 14 and the AS350. It bounds the trainer's position hold
# too, both ways. Unflown at 13.
# cyclic.attitude_limit_deg was 13.0, counted from level. Since #78 every limit counts
# from the hover trim, and the generic 7.5 applies (2026-10-14).
# Measured 2026-08-26 in **still air** (wind 0.00 m/s), 53 s of settled hover at
# 104.7 m with all three assists engaged, 2685 kg, 825 m density altitude. Height
# held to 0.65 m over 831 frames, collective steady between 0.685 and 0.687.
#
# The first attempt at this value read 0.511 and was wrong by 0.176, because it
# was flown in 6 m/s of wind: a helicopter parked in wind is flying rather than
# hovering and needs less power. That is why a profile constant measured in wind
# is not a profile constant.
# Swept 2026-08-26, still air, own autopilot off, gains reconstructed from the log
# rather than from bookkeeping (correction / attitude error, exact because
# inner_kd is 0). Roll is the axis that rings; pitch stayed quiet throughout.
#
#   going up    0.180 quiet (roll rate p90 0.04) ... 0.195 (0.11) ... 0.200 breaks
#   coming back 0.190 (0.87)  0.170 (1.65)  0.160 (2.36)  0.150 (2.39)
#               0.140 (2.22)  0.130 (1.02)  0.120 (0.35, settled)
#
# **The onset at 0.200 is not the number that matters here.** The oscillation
# peaks at 0.150-0.160 on the way back down — gains that read 0.02 on the way up,
# a factor of sixty apart at the identical setting. The hysteresis band runs from
# 0.200 to about 0.125, and inside it a disturbance does not decay: in flight a
# gust is the disturbance, so a gain that is only quiet while nothing upsets it is
# not a safe gain.
#
# So the margin is taken from where it settles, not from where it starts:
# 0.125 / 1.3 = 0.096. That is well clear of the band and still 1.6x the generic
# 0.060 it replaces.
#
# The other four airframes do not appear to do this, and that is an observation
# rather than an omission: the pilot watched the way back down on those sweeps too
# and saw nothing of the kind. Their onsets sit between 0.080 and 0.155, so the
# stretch this aircraft rings in was never reachable there — the sweep was over
# long before. A band this wide may simply be what an airframe with this much
# rotor inertia does once it has somewhere to swing.
const cyclic.inner_kp = 0.096

# Measured 2026-08-26 from a deliberate collective sweep, yaw damper on, no
# altitude hold, no forward speed, wind 0.93 m/s. Binned by collective and fitted
# over the working range 0.55 to 0.95:
#
#     pedal = -0.998 * collective + 0.221      r = -0.996, RMS 0.011
#
# The tightest of the five. Cross-check: at hover_collective 0.687 the line
# predicts -0.465 against a measured standing pedal of -0.455.
#
# **The 1.00 bin is excluded and that is not curve-fitting.** It reads -0.531
# where the line wants -0.75, because at full collective the torque stops rising
# linearly — the power limit, not the tail rotor. Including it drags the slope to
# -0.849 and r to -0.889.
#
# A first attempt the same evening gave -0.68 at r = -0.62 and was discarded: 90 %
# of its frames sat between 0.654 and 0.761, a span of 0.107. A slope is only as
# good as the range it was swept over, and holding a steady height — which is what
# felt like flying well — is exactly what leaves nothing to regress.
#
# **The intercept of +0.221 is close to the limit of usability.** The law anchors
# at zero collective, so it only holds while that number stays small; the Cabri's
# -1.868 is why it flies without feedforward at all. This one is just inside,
# alongside the R22 (+0.173) and R66 (+0.098). Issue #20 would remove the concern
# by anchoring at the hover point instead.
const yaw.torque_per_collective = -0.998

# The anchor the slope above is measured against, and the pair is what the law uses:
#
#     feedforward = hover_pedal + slope * (collective - hover_collective)
#
# The standing pedal in a settled hover, measured 2026-08-26 alongside the slope and at
# the same hover collective of 0.687 — three hovers, 1246 / 2145 / 1314 settled frames,
# reading -0.4547, -0.4507 and -0.4550. The number was already in this file as the
# cross-check on the regression; it becomes a constant because the anchored form did not
# exist until 2026-09-12.
#
# **What it buys is measured, not argued.** Without the anchor the law evaluates
# `slope * collective`, which at a hover of 0.666 commands -0.665 against a pedal that
# actually stands at -0.435 — so the yaw integrator carried **+0.230 permanently**, 23 %
# of `yaw.integral_limit`, spent cancelling the feedforward's own intercept (+0.221 from
# the regression). Flown twice on 2026-09-25: +0.2306 and +0.2301, the intercept to within
# 0.009.
#
# **And the pair is robust to conditions, which is the part that was not obvious.**
# 2026-09-25 flew the same hover 400 m lower in density altitude (516 m against 917 m) at
# the same mass: the hover collective came out at 0.666 rather than 0.687 and the standing
# pedal at -0.4348 rather than -0.4550. Both halves drifted — and they drifted *along the
# slope*, so the anchored law built from the 2026-08-26 pair predicts -0.434 for that day.
# Measured -0.4348, off by 0.001. A constant that moves with the weather is still exact as
# long as both halves come from the same flight.
const yaw.hover_pedal = -0.455


const collective.hover_collective = 0.687

# Measured 2026-08-26 in still air, own autopilot off, at the swept inner_kp of
# 0.096, over 91 s of hover at 100 m following an automated entry. The loop is not
# merely stable but motionless: 0.004 m of height across the segment, 0.03 m of
# ground travelled, drift 0.000 on both axes, trim steady to the third decimal.
#
# Preloading these cut the entry sequence's ground track from 13.5 m to **1.32 m**
# — the same factor the other four airframes showed, and it puts this one in their
# range (0.4 to 1.1 m).
#
# **They rose when the gain did** (4.342 at inner_kp 0.060), which is the opposite
# of what the R66 note in CLAUDE.md predicts. On this airframe the integrator sits
# *below* the attitude actually flown — 4.79 against 5.21 degrees — so less droop
# moves it toward the attitude instead of away from it. Worth knowing before
# anyone re-derives a trim from a gain change on faith.
const cyclic.hover_trim_long = 4.792

const cyclic.hover_trim_lat = -1.649

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.096, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 13 flights 2026-08-26 .. 2026-10-15: pitch +5.36
# (+5.08 .. +5.73), roll -1.73 (-2.59 .. -1.19). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = 5.36
const cyclic.hover_attitude_lat  = -1.73

# Design rotor speed, the yardstick of the rig check's overspeed line (issue #47).
# Not from the .acf, which says 284 and would make every flight a 138 % overspeed, but
# the median airborne rotor speed of 20 reference flights, 391.7.
const rotor.design_rpm = 392

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 17.760 ft, times two.
const rotor.diameter_m = 10.83

# Where translational lift goes, for the assistant's floor when slowing down (#54). From the
# level-flight collective of the 24 reference flights above 15 m (tools/assistant_check.py
# power, 2026-10-08): 0.658-0.674 at 0-2 m/s, 0.624 at 3, 0.581 at 4, 0.494 at 5, 0.49-0.53
# from 6 — a step between 3 and 5 m/s, the lowest in the fleet. Unflown.
const collective.assist_lift_lost_below_ms = 4.0
const collective.assist_lift_lost_lead_ms  = 2.0

# sequence.climb_rate_ms is NOT set, and one attempt on 2026-08-27 has to be discounted:
# the take-me-up flown at 4.0 that day read comfortably (4.96 m/s, rotor down 0.56 %,
# 0.175 of collective free) — but AP1 and AP2 were running. Two controllers on the same
# axes do not average, they fight, and the log records the sum without saying so.
#
# This is the second time this airframe has cost a number that way; the integral limit
# above carries the same warning. Whatever else is measured here, the AFCS goes off first
# and gets confirmed in the cockpit.
#
# The generic 2.0 therefore still applies. Re-fly it with AP1 and AP2 off.

# ── Bindings ─────────────────────────────────────────────────────────────────
bind cyclic_pitch = sim/cockpit2/controls/yoke_pitch_ratio | clamp -1 1
bind cyclic_roll = sim/cockpit2/controls/yoke_roll_ratio | clamp -1 1
bind pedal = sim/cockpit2/controls/yoke_heading_ratio | clamp -1 1
bind collective = 000/joy_collective_ratio | clamp 0 1
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
const airframe.vne_kt = 168
bind velocity_east_ms = sim/flightmodel/position/local_vx
bind velocity_south_ms = sim/flightmodel/position/local_vz
bind position_east_m = sim/flightmodel/position/local_x
bind position_south_m = sim/flightmodel/position/local_z
bind rotor_rpm = sim/cockpit2/engine/indicators/prop_speed_rpm[0]
bind engine_rpm = sim/cockpit2/engine/indicators/engine_speed_rpm[0]
bind engine_torque_nm = sim/cockpit2/engine/indicators/torque_n_mtr[0]

# ── Write path ───────────────────────────────────────────────────────────────
write collective = 000/joy_collective_ratio | flag 000/joy_override_collective
