# Airbus EC135 (rotorsim "EC 135 V5", v5.36, freeware mode) — twin turbine with FADEC,
# four-blade bearingless main rotor, Fenestron (modelled as a conventional prop 1)
#
# Read from a running X-Plane 12.4.4 over the Web API on 2026-11-02, on the skids with the
# rotor governed at 387 RPM (design 395), lever down, 2815 kg (461 kg fuel), still air,
# 3.5 m MSL.
#
# ── The add-on ───────────────────────────────────────────────────────────────
# A compiled plugin (plugins/ec135/mac.xpl), nothing readable; only its dataref strings and
# its log (ec135v5.log: "Overriding Flight Controls", "Stability Augmentation System
# installed", "Own controls preferences established: sns 0, 0, 0; stb 0, 0, 0").
# As found it holds override_flightcontrol, override_prop_pitch and override_throttles (its
# FADEC); every override_joystick_* stood at 0. It writes POINT_pitch_deg_use for BOTH
# rotors itself, reads the hardware lever from joy_mapped_axis_value and the stick and pedal
# from yoke_*_ratio, and writes artstab_*_ratio and servo_*_ratio.
# AFCS: rotorsim/ec135/afcs_line_yp and _yr read "OFF" (pitch and roll) throughout; not yet
# known which cockpit switch the pilot uses to turn the "enhanced autopilot" off — it must be
# off, confirmed in the cockpit, before any measurement (adding-an-aircraft.md §1).
#
# ── From the .acf ────────────────────────────────────────────────────────────
#   _prop/0/_prop_dir      +1     -> left pedal, NEGATIVE yaw.torque_per_collective
#   acf/_tail_with_coll    0      -> the sign rule applies
#   acf/_rotor_mi_rat      0.29   -> under 0.3: sweep inner_kp past 0.15
#   _prop/0 pitch          0 .. 17.3 deg (runtime acf_min/max_pitch[0] agree)
#   _prop/1 pitch          -16.8 .. 34.2 deg (tail)
#   _prop/0/_des_rpm_prp   395    -> 387 on the skids, governed (98 %)
#   two engines, two props; empty 3320 kg, max 6504 kg
#
# ── Ground tests 2026-11-02, on the skids, hands off ─────────────────────────
# Pedal: yoke_heading_ratio under override_joystick_heading, value and flag held 100 %. The
# tail blade (POINT_pitch_deg_use[1], the add-on's write) followed: -0.6 -> 18.7 deg, +0.6 ->
# -1.3, rest 8.8. total_heading_ratio read +-0.39 for +-0.6 (factor 0.65), and the blade is
# 8.7 - 25.5 x total_heading_ratio — X-Plane's formula with prop_dir +1, the one the plugin
# writes behind the flag. On the skids at idle the aircraft barely turned (friction).
# Cyclic: +-0.3 on pitch and roll, value and flag held 100 %, rotorsim/ec135/stick_anim
# followed. The add-on adds artstab_*_ratio in the SAME sense as the stick, so
# total_pitch_ratio = 1.64 x stick, total_roll_ratio = 2.13 x stick (artstab ~0 at rest).
# A control gain, not (on the ground) a damper — whether it carries rate damping in flight
# is for the first log to say.
# Collective: NOT reachable over the Web API. prop_ratio[0] +0.15 held 0 % (the add-on
# rewrites it), POINT_pitch_deg[0] = 4 held 0 %, POINT_pitch_deg_use[0] = 4 held 0 %
# (blade stayed 0.0). In flight the plugin wins: 2026-11-02 11:45 the lift ramp
# lifted it, and over 3666 held frames `collective` stayed within 0.014 of
# `collective_commanded` with the lever a median 0.13 away; the touchdown handed back
# cleanly (first seen 11:31, that log not kept). Its write before the flight
# model (AxisOverride::reassert_owned) lands after the add-on's.

name      = Airbus EC135
acf_match = EC 135
icao      = EC35

# ── Measured constants ───────────────────────────────────────────────────────
# Standard load since 2026-11-05: livery HB-ZJD Lions air (its config.ini holds the equipment),
# pilot alone, 250 kg fuel, fixed in Output/preferences/ec135v5.ini: 2098 kg at load. The hover
# constants below are still from 2429 kg (pilot, copilot, 480 kg), to be measured at this load.
# Hover 2026-11-04 20:23 (laptop, Full, 180 ft, still air, 2429 kg, density altitude 429 m,
# 38-65 s, halves agree): collective 0.497, pedal -0.212, attitude +5.45 / -4.11, trims
# +5.43 / -4.27. The learner, later the same flight at 870 ft: 0.500, trims +4.82 / -3.82, the
# longitudinal 0.6 deg apart and unexplained.
# Before, heavier: hover 2026-11-02 11:45 (laptop, fm 8, 25 fps), assistant Full, 117 ft AGL (3.5 rotor
# diameters), still air, 2777 kg, density altitude 4 m. Yaw axis off, feet still, heading
# steady (yaw rate SD 0.05 deg/s, 145-166 s): collective 0.522-0.523, pedal -0.258 — left,
# as prop_dir +1 predicts. The learner wrote nothing: the yaw axis rang the whole time it
# was on (yaw rate SD 6.4 deg/s, 1.08 s period, roll following one frame later).
const collective.hover_collective = 0.497
# The anchor half of the feedforward pair.
const yaw.hover_pedal = -0.212
# The slope: collective swept by hand, ALT off, yaw hold on, 2026-11-02 14:00 (laptop, 2690 kg,
# 660-3300 ft, no wind), frames with the pedal off its stop and yaw rate under 3 deg/s,
# collective 0.26-0.73: pedal = -1.665 x collective + 0.608, r -0.981 (918 frames) - negative,
# as prop_dir +1 says, and through -0.263 at 0.523, the anchor above. Halves: pulling up
# -1.91, lowering -1.53. The left pedal runs out at about 0.70-0.75 collective (900 Nm): twice
# on its stop with the nose going right, the second time (0.88 to stop a 3300 ft/min sink, rotor
# down to 343 RPM) a spin of 120-200 deg/s that only lowering the collective could end.
const yaw.torque_per_collective = -1.665

# Inner loop gain, swept 2026-11-02 13:46 (laptop, Full, hover 725 ft, still air, kd 0, steps
# 3-10 s): calm up to 0.135, roll rocks at 0.140 (period 0.4 s, pitch quiet) and kept growing
# to +-30 deg/s RMS while stepping back through 0.130; decaying at 0.120, calm at 0.110 and
# below. Second climb: 0.140 again, gone by 0.100. Onset on the way back 0.13; 0.100 sits a
# factor 1.3 under it. Roll first, as onboarding prediction 3 said; the onset is not under 0.12.
# With speed the onset drops: at 0.100 the roll buzzed from about 12 kt (2026-11-02 16:29,
# 0.4-0.5 s, high-passed roll rate 2-3.5 deg/s straight, 3.3 in a turn, strongest at 15-25 kt).
# The pilot set 0.075 (16:58, Full): straight 2.2 deg/s at 1.1 s - the hand, not the loop -
# 35-45 kt 0.02 deg/s, hover calm. A choice by feel at two stages, not a cruise sweep.
const cyclic.inner_kp = 0.075

# It hovers nose up and left wing low: 2026-11-02 13:46, 85-100 s, Full, 725 ft, still air,
# drift 0.06 m/s, pitch +5.24 roll -3.87. The longitudinal integrator sat on the generic
# integral_limit_deg 5.0 for the whole flight (trim 5.00 / -4.06), so the learner refused
# every frame ("a loop is at its limit"). 8, as on the other airframes that hover past 5.
# Wind 2026-11-02 22:55 (laptop, Full, 165 ft, 16-18 kt from all four sides, settled medians):
# tail 6.94 / -3.87, from the left 4.65 / -5.80, head 3.91 / -2.64, from the right 6.10 / -1.81;
# no frame on the stop, drift 0.3-0.6 m/s. Per m/s: longitudinal 0.16 loaded (tail), 0.21
# relieved (head); lateral 0.19 loaded (left), 0.23 relieved (right). At 8 the tailwind stop
# is about 15 m/s (29 kt), the left one about 20 m/s.
const cyclic.integral_limit_deg = 8.0
# The trims, learned at inner_kp 0.075 (2026-11-02 22:55 LEARNED, laptop, 2805 kg, density
# altitude 48 m, no wind, 153 ft): the cold start. At 0.100 they were 5.13 / -4.08 (13:55), so
# the gain's droop is about +0.5 deg longitudinal and nothing lateral. States, like
# hover_collective; re-learn if inner_kp moves.
const cyclic.hover_trim_long = 5.43
const cyclic.hover_trim_lat  = -4.27
# The attitude it hovers in, for Natural's spring - the same hover, a state, not a property.
const cyclic.hover_attitude_long = 5.45
const cyclic.hover_attitude_lat  = -4.11
# Natural adds no rate damping of its own: the add-on's artstab already damps every axis
# (roll 1.4 x stick - 0.019 x roll rate, pitch 0.8 x stick - 0.020 x pitch rate, R2 > 0.99,
# 2026-11-02 13:46 and 16:09). With the generic 0.023 on top the roll rocked from lift-off,
# 0.26 s period, +-18 deg/s, our output banging +-0.27 on the 0.25 damping cap (16:09, 16:14,
# both rigs); cyclic off, gone in 2 s. At 0 (16:21, Natural, 725 ft): roll rate SD 0.02 deg/s.
const cyclic.assist_natural_damping_per_deg_s = 0.0
# Light's damping (inner_kp x assist_damping_s, 0.075 x 0.3) is the same term: studio rig
# 2026-11-02 22:23, Light, roll rocked from lift-off at 0.25 s, up to 29 deg/s, our output on
# the 0.10 cap. Off: Light's cyclic is the add-on's own damper. Flown at 0 on the studio rig
# (22:34, Light: our output is the stick alone, the rest is the hand at 8 ft; 22:36, Natural:
# hover and straight calm, roll 1.0 / 1.1 deg/s).
const cyclic.assist_damping_s = 0.0
#
# cyclic.inner_kd stays 0: 0.020 set in a hover (2026-11-02, Web API recording) started a
# roll oscillation of +-40 deg/s within seconds, the add-on's artstab_roll on its +-1.0 stop.
# The add-on doubles every roll command (2.13 on the ground); kd has to be swept, not taken.

# No floor against losing translational lift: the level-flight collective is a slope (0.51 to
# 7 m/s, 0.39 at 12-13), and no stop sank - three Full stops from 30-82 kt at 1.3-1.4 m/s^2
# climbed +9.6, +4.1 and 0 m (2026-11-02 23:08). As on the Lama, assist_lift_lost_below_ms
# stays 0 (the tool's starting value: 9 / 8).

# The hold's ceiling at the pedal's limit. Engaged in a
# 2900-3300 ft/min sink (2026-11-02 23:05, twice) the generic 0.35 commanded 0.865 in one frame:
# rotor 416 -> 317 RPM (80 %), torque 970 Nm, left pedal on its stop, a right spin to 89 deg/s.
# The left pedal runs out at 0.70-0.75 collective (14:00). Slower to stop a sink, no spin.
# Only the ceiling: max_offset 0.18 also put the floor at 0.343, level flight took 0.341 at
# 2766 kg (23:08), and at 2265 kg the aircraft climbed 390 ft/min with the lever full down
# (2026-11-04 16:49). The floor stays generic. A collective, not an offset: as hover + 0.18 it
# came down to 0.636 with hover 0.4556 learned, and stood there at 117-124 kt (17:36).
const collective.max_command = 0.70

# Design rotor speed, the yardstick of the rig check's overspeed line (#47).
# From .acf _prop/0/_des_rpm_prp; 387 on the skids, governed (2026-11-02). Check against
# the first hover log.
const rotor.design_rpm = 395

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 16.73 ft, times two.
const rotor.diameter_m = 10.20

# ── Pilot controls ───────────────────────────────────────────────────────────
bind cyclic_pitch = sim/cockpit2/controls/yoke_pitch_ratio   | clamp -1 1
bind cyclic_roll  = sim/cockpit2/controls/yoke_roll_ratio    | clamp -1 1
bind pedal        = sim/cockpit2/controls/yoke_heading_ratio | clamp -1 1
# The blade angle, mapped back onto 0..1 over acf_min_pitch[0]..acf_max_pitch[0] (0 .. 17.3).
# prop_ratio[0] is the add-on's copy of the lever, not the rotor.
bind collective   = sim/flightmodel2/engines/prop_pitch_deg[0] | units blade_pitch_deg | clamp 0 1

# ── What the add-on adds, recorded only ──────────────────────────────────────
# The add-on writes X-Plane's artificial-stability channel itself: with the stick, and with
# the pilot's hardware pedal when the plugin does not hold the yaw axis (yoke_heading 0,
# artstab_heading -0.28 = the pilot's foot). total_* is what reaches the rotor.
bind artstab_pitch = sim/joystick/artstab_pitch_ratio
bind artstab_roll  = sim/joystick/artstab_roll_ratio
bind artstab_yaw   = sim/joystick/artstab_heading_ratio
bind total_pitch   = sim/cockpit2/controls/total_pitch_ratio
bind total_roll    = sim/cockpit2/controls/total_roll_ratio
bind total_yaw     = sim/cockpit2/controls/total_heading_ratio

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
# #76: never-exceed speed from the .acf (P acf/_Vne_kts).
bind indicated_airspeed_kt = sim/flightmodel/position/indicated_airspeed
const airframe.vne_kt = 155

# Bank in Full, from the hover trim, so about 31 right and 35 left with the lateral trim near -4. The
# generic 25 gave 21 right and 25 left at full stick (all logs to 2026-11-04 18:52): 2200 ft
# radius at 100 kt, where Natural banks past 40. As the AW139. Not flown yet.
const cyclic.assist_bank_limit_deg = 35
bind velocity_east_ms  = sim/flightmodel/position/local_vx
bind velocity_south_ms = sim/flightmodel/position/local_vz
bind position_east_m   = sim/flightmodel/position/local_x
bind position_south_m  = sim/flightmodel/position/local_z

# ── Engine and rotor ─────────────────────────────────────────────────────────
# Free turbine: engine_speed_rpm reads the gas side (5806 on the skids), not the rotor.
bind rotor_rpm        = sim/cockpit2/engine/indicators/prop_speed_rpm[0]
bind engine_rpm       = sim/cockpit2/engine/indicators/engine_speed_rpm[0]
bind engine_torque_nm = sim/cockpit2/engine/indicators/torque_n_mtr[0]
bind throttle         = sim/cockpit2/engine/actuators/throttle_ratio[0] | clamp 0 1
# Turbine: manifold pressure reads ambient (29.92) and stays unbound.

# #71: the add-on already holds override_prop_pitch and writes POINT_pitch_deg_use[0] from
# the hardware lever every frame; the plugin's write before the flight model wins (header). Tail rotor: the add-on's own blade matches the plugin's formula
# (8.7 - 25.5 x total_heading_ratio, see the header), so both write the same value.
write collective = sim/flightmodel/engine/POINT_pitch_deg_use[0] | units blade_pitch_deg | flag sim/operation/override/override_prop_pitch
