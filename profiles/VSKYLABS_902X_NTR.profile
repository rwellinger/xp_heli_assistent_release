# VSKYLABS 902X-NTR (VSL, v1.1.2) — MD 902 Explorer
#
# The second MD 902 in the fleet and an unrelated program: the JRX profile beside this one
# says nothing about it. Different blade range (-1 .. +14 deg here, -4 .. +7 there), live
# artificial stability here and zeroed there, a NOTAR modelled with X-Plane's puffers here.
# The type name is the only thing the two share. VSKYLABS also built the Cabri G2 and the
# R66 — a lead for the control chain, never a conclusion.
#
# Read from a running X-Plane 12.4.4 over the Web API on 2026-10-05, on the skids with
# the rotor governed at 395.7 RPM. Script findings are from plugins/xlua/scripts/*.lua.
#
# ── No script holds an override flag ─────────────────────────────────────────
# None of the fourteen xlua scripts touches override_joystick*, override_prop_pitch or any
# copilot dataref. All four flags read 0 on the ground. So the standard axes are the way
# in, and on this airframe they are the ONLY right way in for the pedals — see NOTAR below.
#
# ── NOTAR: the anti-torque is computed from the pilot's pedal ────────────────
# notar_init.lua, after_physics(), every frame:
#   - puffers_on is forced to 1. The fan is engine 2 (a JET_2SPOOL), its throttle is
#     throttle_ratio[2] = |yoke_heading_ratio| * (250 - IAS) / 160, capped at 0.9.
#   - acf_puffN (the Coanda force) is 15000 in the air while yoke_heading_ratio < 0, and
#     ZERO otherwise. Left pedal gets the Coanda force, centre or right pedal gets none.
#   - On the ground the fan throttle is fixed at 0.1 and puffN scales with torque only
#     (400 .. 8000), whatever the pedals do.
#   - acf_rudd_tab is set to -0.1 every frame, which is why total_heading_ratio reads
#     -0.100 with the pedals centred.
#
# Two consequences:
#   1. Yaw authority has a step at pedal = 0. The hover sits on the left side (prop_dir +1,
#      below), so the yaw damper works in the region with the Coanda force on. A right-yaw
#      demand that crosses zero loses it at once. Expect a yaw damper tuned on any other
#      airframe to behave differently near centre.
#   2. The script reads yoke_heading_ratio. Under override_joystick_heading that dataref
#      carries the assist's command, so the NOTAR follows the assist. A copilot channel
#      (the JRX route) would steer X-Plane's yaw and leave the fan and the Coanda force at
#      the pilot's centred feet. Do not move the pedal write to the copilot channel.
#
# The ground write test is NOT evidence about the pedal: -0.6 held 100 % of passes and the
# yaw rate stayed at 0.000, because the ground branch above ignores the pedal. Whether the
# pedal steers is answered by the first hover, not by the skids.
#
# ── Stabilisation: X-Plane's own, live, and a forced yaw damper ──────────────
# Unlike the JRX 902 the artificial-stability constants are non-zero:
#     acf_ASh_lo_rate 0.0217   acf_ASp_lo_rate 0.005   acf_ASmaxr_lo 30.0
# with artificial_stability_on = 1. No script writes that switch.
# vscs_init.lua writes yaw_damper_on = 1 on EVERY frame — it cannot be switched off from
# the cockpit. The VSCS switches (vskylabs/902x/l_vscs_onoff, r_vscs_onoff) only set the
# throw of the two tail fins (acf_rudd_lr/rr, acf_rud2_lr/rr: 20 deg on, 0 off), which
# work with airspeed. So in forward flight X-Plane's yaw damper moves the fins beside this
# plugin's coordination loop: two controllers on one axis, and the log records the sum.
# Every constant here is conditional on artificial_stability_on as found (1) and on the
# yaw damper the add-on forces. Say so before comparing a number with another airframe.
#
# ── An autopilot that works: switch it off before measuring ───────────────────
# The G1000 carries X-Plane's own autopilot, and it flies: HDG and ALT engage and hold
# (pilot report 2026-10-05; speed is left to the collective). No script implements it —
# acf/_custom_autopilot reads 1 and did NOT mean X-Plane's AP is disabled, as was assumed
# here before trying it. It is a second controller on the axes this plugin commands:
# AP or assists, never both. Every measurement in this file was taken with
# autopilot_mode at 0.

# ── The collective: blade angle, index 0 only ────────────────────────────────
# Three engines: 0 and 1 the two turbines, 2 the NOTAR fan. prop_ratio on the ground with
# the lever down read [0.0, 0.5, 0.5]: the rotor is index 0, the other two indices carry
# 0.5 and are not the collective. prop_ratio_all reads their AVERAGE, 0.333.
#
# That cost an aircraft its heading on 2026-10-05. probe_aircraft.py --write-test
# restored the collective by writing back what prop_ratio_all had read, which put 0.333 of
# collective on the rotor with nobody on the pedals: lifted light on the skids and spun
# right at 17 deg/s until the pilot took it. The tool now restores index by index.
#
# The plugin's standard collective target is prop_ratio_all, which on this airframe also
# writes engine 1 and the fan. So the fleet route is used instead: blade angle, index 0,
# every frame, no flag. Range from acf_min_pitch / acf_max_pitch [0] = -1.0 .. +14.0,
# read back on the ground as -1.0 with the lever down, POINT_pitch_deg[0] identical.
# The +0.15 nudge through prop_ratio_all took torque 77.6 -> 119.0 Nm and held 100 %.
# UNFLOWN: the write through POINT_pitch_deg[0] is the fleet's proven path, but on this
# airframe it has not yet lifted anything.
#
# The lever is configured reversed on this rig: joy_mapped_axis_value[5] reads 1.0 with
# the lever down. AxisOrientationDetector finds that on its own.

name      = VSKYLABS 902X-NTR
# Covers both models in the folder, deliberately: "VSL 902eX.acf" is the extended-range
# variant, and against "VSL 902X.acf" its rotor, engine, control and stability entries are
# identical — only _m_fuel_max_tot (2755 lb against 1025) and _m_max (6770 lb against 6500)
# differ, and it runs the same scripts. Excluding it would not work anyway: the folder
# name matches any fragment, and both carry ICAO EXPL. Only the 902X has been on the skids.
acf_match = VSL 902
icao      = EXPL

# ── What is measured, and what is still not ──────────────────────────────────
# First complete take-me-up 2026-10-05 18:03 (reference_flights/VSKYLABS_902X_NTR/
# 2026-10-05_18-03-11), still air, 2641 kg, density altitude 610 m, inner_kp 0.060.
# The learner took a settled hover at 100 m (507 frames over 30 s):
#
#     collective.hover_collective = 0.4664    cyclic.hover_trim_long = +6.10
#     yaw pedal in that hover     = -0.269    cyclic.hover_trim_lat  = +0.24
#
# hover_collective goes in below. ALT had already held 0.464 at 22.9 m in the aborted
# run an hour earlier, so two flights agree.
# Repeated 18:18 with the learned trim preloaded (2624 kg): 0.4639 / +6.13 / +0.24 —
# three flights within 0.003 of collective and 0.04 deg of trim. The take-me-up then
# settled 0.07 m from its lift-off point (0.57 m at most), against 19.8 m without trim.
#
# The trims do NOT go in yet. They are attitude plus droop and hang on inner_kp, which
# has not been swept; they would be wrong the moment it is. On this rig they arrive from
# learned_VSKYLABS_902X_NTR.cfg anyway. Measured at the generic gain for what it
# shows: the 902X needs 6.1 deg of longitudinal trim in still air, in the upper third of
# the fleet's shipped trims (-0.1 .. 10.7). Without it the take-me-up walked 19.8 m between lift-off and handover
# — 6.1 deg x 3.3 m/deg is 20 m, so the documented rule held to the metre.
#
# Pedal -0.269 is LEFT, as _prop_dir +1 and the NOTAR script predicted. yaw.hover_pedal
# stays out until the collective sweep gives its slope: the two are a pair.
#
# The trims went in on 2026-10-06, measured at the swept gain — see below inner_kp.

const collective.hover_collective = 0.466

# .acf _prop/0/_des_rpm_prp 392; the 100 m hover above ran at a median of 393.1 RPM
# (100.3 %), so the .acf is right. The peak of the flight was 410.3 (104.7 %), for half a
# second while the pilot moved the lever under ALT and the command fell 0.55 -> 0.37.
const rotor.design_rpm = 392

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 16.910 ft, times two.
const rotor.diameter_m = 10.31

# Where translational lift goes, slowing down: the collective held level out of ground
# effect, 0.27 at 10 m/s, 0.38 at 9, 0.42 at 8 (2026-10-08 13:14, 1 m/s bins).
const collective.assist_lift_lost_below_ms = 9.0

# ── Torque feedforward: swept 2026-10-05 19:10 ────────────────────────────────
# reference_flights/VSKYLABS_902X_NTR/2026-10-05_19-10-02: ALT off at 100 m, yaw damper
# and cyclic hold on, lever by hand 0.19 .. 0.88, still air, 2624 kg. Pedal against
# collective, pedal off its stop, |R| < 1 deg/s, speed < 1 m/s: slope -0.393 .. -0.422 over
# six filters, r = -0.94; halves -0.354 / -0.466. Climbing and sinking shift the pedal at
# the same collective (0.40-0.45: -0.185 sinking, -0.167 level, -0.136 climbing) because
# torque follows the inflow — pedal against torque is r = -0.91.
#
# The anchor is the level-flight pedal from the same recording, -0.19 at 0.45-0.50. NOT the
# -0.266 the settled ALT hover read at 0.463 a minute earlier: this airframe has shown two
# hover states at the same collective — ~+5.3 deg nose-up on -0.27 of pedal, ~+7.4 on
# -0.18 — and the sweep was flown entirely in the second (see aircraft-findings). The
# integrator covers the difference; the feedforward is capped at 90 % anyway.
# Sign NEGATIVE, as _prop_dir +1 predicted before the first flight.
const yaw.torque_per_collective = -0.40
const yaw.hover_pedal           = -0.19

# ── sequence.climb_rate_ms: 4.0 ──────────────────────────────────────────────
# Two take-me-ups, still air, ~2630 kg (report_climb_capacity):
#   18:03  2.34 m/s for 48 s   rotor droop 0.27 %   collective 0.501, 0.49 of it left
#   18:18  4.62 m/s for 26 s   rotor droop 1.24 %   collective 0.537, 0.41 of it left
# The airframe's ceiling was not reached, so the usual "half of what it demonstrates"
# cannot be applied; 4.0 sits below a rate flown comfortably, with 0.41 of lever spare.
# Raised from the generic 2.0 at the pilot's request on 2026-10-05.
# sequence.climb_rate_ms = 4.0: the trainer's take-me-up climb, not used by the assistant.

# ── cyclic.inner_kp: swept 2026-10-05 18:28 ───────────────────────────────────
# reference_flights/VSKYLABS_902X_NTR/2026-10-05_18-28-40, hover at 107 m, still air,
# 2605 kg, all three assists on, hands off. Steps logged as TUNING events, 0.005 apart.
#
#   up    0.060 .. 0.230  quiet (roll rate p90 <= 0.16 deg/s); pitch lifts a little from
#                         0.200 (p90 0.31 against <= 0.17 below)
#   up    0.240, 17 s     ROLL grows: p90 0.22 -> 0.92 -> 4.6 -> 10.5 deg/s, peak 13.4
#   down  0.235 .. 0.185  ringing, steps too short (0.1-2 s) to judge
#   down  0.180, 17 s     DECAYS: 10.4 -> 4.9 -> 2.0 -> 0.8 -> 0.37 deg/s, ~3 s constant
#   down  0.160 .. 0.140  quiet, roll p90 0.07-0.11
#
# The margin is taken from where it settles on the way down (the AW109's rule), not from
# the rising onset: 0.180 / 0.140 = 1.29. Against the rising onset it is 1.71. One sweep
# only — section 4a asks for two and the lower reading; the 17 s decay at 0.180 is the
# evidence this rests on. _rotor_mi_rat 0.360 said "sweep past 0.15", and it was right.
#
# The trims below the learned layer were taken at 0.060 and are void at this gain; the
# learner refuses them now and measures again.
const cyclic.inner_kp = 0.140

# ── cyclic.inner_kd: swept 2026-10-07 21:36 ───────────────────────────────────
# reference_flights/VSKYLABS_902X_NTR/2026-10-07_21-36-06, assistant Full, still air,
# 2365 kg, ~12 m. Three stages, each flown hover -> 15-20 m/s -> turn at up to 25 deg ->
# release and stop; steps logged as TUNING events. Rates high-passed (2 s mean removed):
#
#   kd      hover q_rms   straight >8 m/s q / p   turn q / p    cyclic corr rms (fwd)
#   0.000   1.84          3.27 / 1.37             3.43 / 2.81   0.099
#   0.020   0.42          0.93 / 0.66             1.82 / 2.00   0.028
#   0.040   0.21          0.41 / 0.51             0.69 / 1.22   0.013
#
# At 0 the pitch rang at ~1.4 s in every level and in the hover too, twice as hard in
# forward flight — "like a horse at a gallop" (pilot); without the assistant the period was
# absent. 0.040 took it out by a factor of 5-9, with no new ringing in roll, and was the
# pilot's choice in the air. Kd does not change the standing droop, so the trims below
# stay valid. Open: CLAUDE.md wants a Kd sweep as a Kp sweep on each Kd stage — inner_kp
# was swept at kd 0 only, and with this damping its ringing onset may sit higher.
const cyclic.inner_kd = 0.040

# Hover trim, MEASURED AT cyclic.inner_kp = 0.140: the learner, 2026-10-05 18:36, still air,
# 2587.69 kg, 617 m density altitude, 491 samples over 30.05 s (0.4571 / +7.36 / -1.90).
# Change the gain and these are void — they are attitude plus droop.
#
# In with a known reservation: the hover attitude wandered by about 2 deg between flights
# of the same mass in still air (+5.3/-0.5 at 18:18, +7.4/-2.2 at 18:28), cause open — see
# docs/aircraft-findings.md. 2 deg is ~6.6 m of take-me-up offset at 3.3 m/deg, against the
# 19.8 m measured with no trim at all, and in the assistant mode (#51) it is a little held
# stick rather than a walking aircraft: centred stick there IS this trim. Until now the
# trims reached only the rig that had learned them; the simulator machine had none.
const cyclic.hover_trim_long = 7.36
const cyclic.hover_trim_lat  = -1.90

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.14, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 20 flights 2026-10-05 .. 2026-10-15: pitch +7.01
# (+4.79 .. +8.06), roll -1.48 (-2.22 .. -0.50). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = 7.01
const cyclic.hover_attitude_lat  = -1.48

# ── Cyclic limits: each raise showed the next binding one ────────────────────
# Flight 1, 2026-10-05 17:53 (32 s at 110-120 m, still air, yaw + cyclic on, ALT off):
# cyclic_target_pitch_deg sat on 6.000, the generic attitude_limit_deg, for the whole
# recording, with the airframe at 6.55 deg nose-up and 2.66 m/s forward in a 0.35 m/s
# climb. Not the hover attitude — an equilibrium at that speed — but the setpoint was
# capped, so the cascade could not ask for more. Raised to 10.0 (AS350, AW109, AW139).
#
# Flight 2, 17:58, take-me-up from the skids: the attitude setpoint peaked at 6.6, so 10.0
# no longer binds. The integrator did instead: cyclic_trim_long reached 5.000, the generic
# integral_limit_deg, at 24.4 s in the low hover and stayed there to the end, leaving
# 0.45 m/s of forward drift; after 10 s of that below the clearance the sequence aborted
# with assist_at_limit at 23 m, as designed. Raised to 8.0, the AS350's value for the
# same reason.
#
# Flight 3, 18:03: take-me-up complete, integrator peak 6.92 against 8.0, learned
# hover_trim_long 6.10. Both limits PROVISIONAL — 1.9 deg over the trim is thin for wind.
#
# These two lines must stay: the learned trim of 6.10 is preloaded through the integral
# limit, so without them the generic 5.0 puts the cyclic hold on its stop at engage and
# the take-me-up aborts with assist_at_limit. That happened once, when an edit dropped
# them (2026-10-05, evening).
#
# Flight 5, 19:02, take-me-up with the wind from behind (reference_flights/.../
# 2026-10-05_19-02-07): ~6 m/s tail and 5 m/s from the left at the aircraft, 7-10 m/s
# gusts. cyclic_trim_long reached 8.000 at 29.8 s in the low hover and stayed there; the
# sequence aborted with assist_at_limit at 49 m, as designed. Barely saturated — drift
# stayed at 0.07-0.10 m/s, so the airframe needed about 8.2 deg. Into the wind (18:56,
# 8 m/s head, 6 m/s from the right) it had needed 3.95 and never touched the stop. The
# lateral axis sat at -3.3 against 8: the longitudinal axis is the one that binds.
#
# Raised to 11 / 13: the integrator by the margin a stronger tailwind needs, the attitude
# limit with it, because the setpoint is trim plus the outer P term and 10 would bind next.
# The JRX 902 ended at 11 / 14 for the same reason — another program, not evidence, but a
# size the fleet has flown. PROVISIONAL until the same tailwind flies without frames on
# the stop. No consumption per m/s is given: with the still-air trim wandering between
# 6.1 and 7.4 (see the findings), it computes to anything from 0.13 to 0.35.
#
# Flight 6, 19:05, the same tailwind again (6-8 m/s behind, 5-7 from the left, gusts to
# 10.6), learned trims preloaded: take-me-up complete, 5.0 m lift-off to handover. Trim
# peaked at 8.53 long / -3.39 lat, the attitude setpoint at 8.81 — 0 frames at either
# limit, 2.5 deg of longitudinal integrator left. That retires the PROVISIONAL above for
# this wind; a stronger tailwind has not been flown.
# cyclic.attitude_limit_deg was 13.0, counted from level. Since #78 every limit counts
# from the hover trim, and the generic 7.5 applies (2026-10-14).
const cyclic.integral_limit_deg = 11.0

# Mass on the ramp as loaded: 2662 kg (empty 3375 lb / 1531 kg, MTOW 6500 lb / 2948 kg).

# ── Pilot controls ───────────────────────────────────────────────────────────
# The pilot's axes, not total_*_ratio: the assist writes these same datarefs under their
# override flags, so they carry the command; the totals would add the live artificial
# stability and the -0.1 rudder trim on the heading axis.
bind cyclic_pitch = sim/cockpit2/controls/yoke_pitch_ratio   | clamp -1 1
bind cyclic_roll  = sim/cockpit2/controls/yoke_roll_ratio    | clamp -1 1
bind pedal        = sim/cockpit2/controls/yoke_heading_ratio | clamp -1 1

# Same option as the write line below, so read and write share one range.
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
const airframe.vne_kt = 140
bind velocity_east_ms  = sim/flightmodel/position/local_vx
bind velocity_south_ms = sim/flightmodel/position/local_vz
bind position_east_m   = sim/flightmodel/position/local_x
bind position_south_m  = sim/flightmodel/position/local_z

# ── Engine and rotor ─────────────────────────────────────────────────────────
# Two turbines (TRB_FRE), index 0 read: 6280 RPM, torque 77.6 Nm at idle beside 79.5 on
# engine 1. Index 2 is the NOTAR fan (320 RPM on the ground) and is not bound.
bind rotor_rpm        = sim/cockpit2/engine/indicators/prop_speed_rpm[0]
bind engine_rpm       = sim/cockpit2/engine/indicators/engine_speed_rpm[0]
bind engine_torque_nm = sim/cockpit2/engine/indicators/torque_n_mtr[0]
bind throttle         = sim/cockpit2/engine/actuators/throttle_ratio[0] | clamp 0 1
# Manifold pressure unbound: 29.92 inHg is ambient, a turbine has no manifold.

# ── Write access ─────────────────────────────────────────────────────────────
# Pedal and cyclic: the standard axes with their standard flags (nothing said here).
#
# #71 (2026-10-10): behind override_prop_pitch. Without it the lever took the collective
# for a frame on nearly every change (simulator 2026-10-09: 901 of 906, 333 of 337; the
# rotor shook). Ground test: the main rotor is the only prop — index 1 has a range of
# 0 .. 0 and does not turn, so the plugin's tail-rotor write refuses it (collapsed range);
# the NOTAR fan is engine 2, a jet, its throttle set by notar_init.lua and untouched by the
# flag (0.1 throughout). Over the Web API the flag held 10 s at 20 Hz, the blade stood at
# the written 1.0 deg with the lever at -1.0, torque 85 -> 116 Nm, yaw rate under 0.03.
# Flown 2026-10-10 18:30 (laptop, Full, 632 s): 244 lever changes in the air, none on the
# lever, the blade angle equal to the command in every frame.
write collective = sim/flightmodel/engine/POINT_pitch_deg_use[0] | units blade_pitch_deg | flag sim/operation/override/override_prop_pitch
