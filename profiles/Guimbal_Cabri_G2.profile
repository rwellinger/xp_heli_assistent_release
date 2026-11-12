# Guimbal Cabri G2 (VSKYLABS). Designed as a modern replacement for the R22 in flight
# training: same class, same piston engine, but a three-blade rotor with far more
# inertia and a fenestron instead of an open tail rotor. Closer to the R22 in physics
# than the EC130 is, and reportedly far more forgiving.
#
# Unlike the EC130 this one has a real manifold pressure — a Lycoming O-360 has a
# manifold. Bound accordingly.
#
# Its rotor turns the other way from the R22's: the torque is held with RIGHT pedal, so
# the feedforward is positive here. Measured, not inferred from the manufacturer's
# nationality — and confirmed by `_prop/0/_prop_dir` = -1 in the .acf.

name      = Guimbal Cabri G2
acf_match = Cabri
icao      = G2CA

# ── Measured constants ───────────────────────────────────────────────────────
const collective.hover_collective = 0.659

# Where this airframe runs out, measured 2026-08-22 over 1789 airborne frames.
# The rotor is healthy up to 0.70 of collective and collapses past it:
#
#     0.60 .. 0.65   lowest rotor 512 RPM
#     0.65 .. 0.70   lowest rotor 509 RPM
#     0.70 .. 0.75   lowest rotor 477 RPM
#     0.75 .. 0.80   lowest rotor 473 RPM
#
# Manifold pressure sat at a median of 27.8 against a ceiling of 28.1 and the
# throttle at 0.925 — it hovers with almost nothing in hand. The generic
# lift_margin of 0.10 would put the ramp at 0.759, which is squarely inside the
# droop; 0.04 stops it at 0.699, just below the knee.
const sequence.lift_margin = 0.04

# The pilot's own median climb was 1.8 m/s and the rotor was already suffering,
# so the generic 2.0 asks for more than this airframe has.
# sequence.climb_rate_ms = 1.0: the trainer's take-me-up climb, not used by the assistant.

# The same limit for every climb the collective hold flies, the assistant's lever included.
# 2026-10-08 20:31, assistant Full, lever pulled to the stop at 22 m: the generic 5 m/s asked
# for collective 0.90, the climb reached 4.5 m/s and the rotor fell from 530 to 465 RPM, under
# the 509 knee for 6.5 s. 1.5 sits between take-me-up's 1.0 and the 1.8 m/s the pilot's own
# climb already drooped at. Unflown at 1.5.
const collective.max_climb_ms = 1.5

# And the guard bites earlier than the generic 0.92 (which would wait until
# 488 RPM). The knee is at 509, so 0.95 catches it going over rather than after.
const sequence.rotor_droop_fraction = 0.95

# ── Torque feedforward, and why it took until 2026-09-12 to switch on ─────────
#
# Measured 2026-08-22 over a deliberate collective sweep:
#
#     pedal = 3.781 * collective - 1.868      r = +0.995
#
# A sound regression — the best correlation of the fleet — and it was unusable for
# thirteen months of flying, because the law anchored the line at collective zero and
# fed forward the slope alone. At this airframe's hover collective of 0.659 that asks
# for 2.49 of pedal against a full travel of 1.0. Flown: the aircraft turned at
# 163 deg/s for forty seconds, the loop answered with its entire -1.0, and the pilot's
# own pedal did nothing either. The value was correct; the formula around it was not.
#
# Every other airframe got away with the same formula because its intercept is small —
# the R22's is +0.173, the EC130's -0.224, the AS350's -0.252. The Cabri's is -1.868,
# and it is the only one where the extrapolation from zero is longer than the thing
# being measured.
#
# The law now anchors at the hover instead: it is given the pedal standing there and
# the collective it stands at, and the slope is only responsible for the change away
# from that point. Anchored, this same 3.781 asks for the +0.637 that was measured.
#
# The hover pedal is the anchor, and it is the number without which the slope must not
# be switched on. The regression predicts +0.624 at 0.659 of collective against the
# +0.637 the settled hover actually stood on — thirteen thousandths, which is the
# cross-check docs/measurements.md asks for before any slope is believed.
const yaw.torque_per_collective = 3.781
const yaw.hover_pedal = 0.637

# Standing hover attitude, measured 2026-08-24. Remarkably small — 0.56 degrees
# total against the R22's 4.16 — which is the whole reason this airframe leaves the
# low hover within a metre of where it lifted off while the others walk 9 to 15 m.
# It is not better controlled, it simply has almost nothing to trim out.
# Inner loop gain, swept in flight 2026-08-25 in still air. The wobble is on the
# roll axis here, not pitch: roll rate p90 runs 0.05 .. 0.13 up to 0.120, is
# clearly raised at 0.130 (0.19) and rings at 0.140 (0.96, still 1.58 while
# decaying after the gain came back down). Pitch stays quiet throughout.
#
# 0.100 is a factor 1.30 below that onset, the margin the other three carry.
#
# A second sweep the same evening put the onset higher — quiet through 0.150,
# then roll rate p90 at **16.45** by 0.160 — and 0.100 is kept against the lower
# of the two readings. When two measurements of a limit disagree, the limit is the
# smaller one. That sweep also showed how slowly it lets go: back down at 0.130
# the roll rate was still 16.24, and only 0.120 settled it.
#
# It also breaks the tidy story that the ceiling follows mass: at 616 kg this
# airframe is barely heavier than the R22's 539 and tolerates 0.130 where the R22
# rocks at 0.080. A three-blade fully articulated head against a two-blade
# teetering one is the likelier explanation, and it is a reminder that four
# measurements are four measurements, not a law.
const cyclic.inner_kp = 0.100

# Rate damping for the assistant, 2026-10-08. kd 0 (20:31, Full): lively everywhere, hover
# 1.62/1.65 deg/s at 0.7 s, straight 2.46/1.97, turn 2.64/2.15 (rate RMS pitch/roll). kd 0.020
# (20:52, 21:06): hover 0.53-0.55/0.07-0.47, straight 0.83-0.85/0.33-0.71, turn 0.83/1.39. The pilot's choice;
# 0.040 not flown. kd leaves the trims alone.
const cyclic.inner_kd = 0.020

# Hover trim, measured directly at inner_kp 0.100 in still air, 2026-08-25. The
# attitude actually flown is -0.75 / +0.87.
#
# These replace interpolated values, and the comparison is worth keeping: the
# longitudinal figure was predicted at -0.08 against -0.082 measured, the lateral
# at +0.41 against +0.50. So droop x kp = constant holds well enough to plan with
# and not well enough to ship — the lateral attitude itself had moved from +0.80
# to +0.87 between the two flights, and no arithmetic over the old data could
# have known that.
const cyclic.hover_trim_long = -0.08

const cyclic.hover_trim_lat = 0.50

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.1, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 11 flights 2026-08-25 .. 2026-10-16: pitch -0.96
# (-1.57 .. -0.31), roll +0.69 (+0.54 .. +1.28). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = -0.96
const cyclic.hover_attitude_lat  = 0.69

# Design rotor speed, the yardstick of the rig check's overspeed line (issue #47).
# From .acf _prop/0/_des_rpm_prp; 13 reference flights hover at 100.0-100.6 %.
const rotor.design_rpm = 530
# The add-on's own rotor annunciator (plugins/xlua/scripts/g2_barc_annun/g2_barc_annun.lua,
# v4.1.1): HIGH flashes above 540 RPM (101.9 %) and is steady above 594 (112.1 %); LOW flashes
# below 515 (97.2 %) and is steady below 466 (87.9 %). The assistant's overspeed guard
# (105-110 %) keeps the steady HIGH away — 575 peak in the stop of 2026-10-08 20:52 against
# 596 at 20:37 — but not the flashing one, which a stop from speed reaches before the guard
# starts.

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 11.800 ft, times two.
const rotor.diameter_m = 7.19

# ── Bindings ─────────────────────────────────────────────────────────────────
bind cyclic_pitch = sim/cockpit2/controls/yoke_pitch_ratio | clamp -1 1
bind cyclic_roll = sim/cockpit2/controls/yoke_roll_ratio | clamp -1 1
bind pedal = sim/cockpit2/controls/yoke_heading_ratio | clamp -1 1
# #89: read the blade angle, with the same option as the write line below, so read and write
# share one range. Ground test 2026-10-15: prop_ratio[0] and prop_pitch_deg[0] normalised over
# acf_min/max_pitch (-2 ... 12.5 deg) agree to 0.0000 at 0.25/0.50/0.75, so hover_collective and
# the feedforward anchor keep their values.
bind collective = sim/flightmodel2/engines/prop_pitch_deg[0] | units blade_pitch_deg | clamp 0 1
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
bind manifold_in_hg = sim/cockpit2/engine/indicators/MPR_in_hg[0]

# #71/#89: behind override_prop_pitch. Without the flag the lever reached the rotor for a frame
# on 1111 of 1630 lever changes (Saitek, 2026-10-15 17:38) and 229 of 264 (laptop, 10-16 00:06),
# and on those frames the pedal feedforward jumped (#86). Ground test 2026-10-15: the Fenestron
# (prop 1) follows 7.5 + 14.5 x total_heading_ratio to three decimals at four points, sign from
# prop_dir[0] = -1; with pedals centred the Cabri itself puts 0.15 on total_heading_ratio,
# carried over as it should be. Not yet flown behind the flag: both rigs before the merge.
write collective = sim/flightmodel/engine/POINT_pitch_deg_use[0] | units blade_pitch_deg | flag sim/operation/override/override_prop_pitch
