# Airbus AS350 B (Alpine Studio). The folder ships four variants — B1, B2, B2 VEMD and
# BA — which differ in engine rating and instrumentation, not in how they are steered.
# One profile covers all four; they share the add-on's `alpinestudio/AS350_B1/` dataref
# namespace regardless of which one is loaded.
#
# **Every axis reaches the flight model through the standard datarefs**, so this profile
# carries no AxisWriteBinding at all. Measured on the ground 2026-08-26 with the rotor at
# 385 RPM, each command held rather than written once:
#
#   yoke_heading_ratio  -0.6    tail rotor blade  -7.2 deg, yaw rate to  -41 deg/s
#   yoke_heading_ratio  +0.6    tail rotor blade +12.0 deg, yaw rate to  +34 deg/s
#   yoke_pitch_ratio    -0.5    pitch_ratio -0.49, pitch rate -25 deg/s, aircraft lifted
#   prop_ratio_all       0.25   blade 2.55 deg, torque 2369 Nm (3665 Nm at the lever's 0.375)
#
# The collective reading is exact rather than approximate: acf_min_pitch[0] is -0.6 and
# acf_max_pitch[0] is 12.0, so 0.25 maps to 2.55 degrees and 0.375 to 4.13 — both hit to
# the digit. Worth recording because `probe_aircraft.py --write-test` reports this axis
# as dead. It writes once and waits; without an override X-Plane restores the lever on
# the next frame, so the nudge lasts a frame. The plugin writes every frame and does not
# have that problem. **A single-shot write test cannot answer this question here.**
#
# Three things in the add-on's xlua scripts can take the axes away, and all three are
# pilot-operated switches rather than anything the profile can bind around:
#
#   Commands.lua  Collective lock -> override_prop_pitch, and it drives prop_pitch_deg
#                 itself. With the lock in, the collective assist is decoupled — this is
#                 the 2026-08-22 failure mode, available as a cockpit switch.
#   Commands.lua  Cyclic lock     -> override_joystick_pitch and _roll.
#   autopilot.lua SAS / "artificial stability" plus HDG/NAV/IAS/ALT/VRT.
#
# The SAS is the one to watch: it writes the acf_AS*_rate datarefs rather than an axis,
# so it does not show up as a fight over a control. Measure with stab_level at 0.
#
# Nothing is measured yet. It is registered because the feasibility check passes on every
# axis, not because it is tuned: it flies on R22 starting figures. See
# basis/Airbus_AS350_B.cfg for what to measure and in which order.

# **One profile covers all four variants, and that is settled rather than assumed.**
# Verified on 2026-08-27 by loading AS350BA V1.4/AS350_BA.acf (HB-ZDP): the acf_match below
# recognises it, and it flies on the constants measured on the B2 VEMD.
#
# The four are three airframes, not four — from the .acf files:
#
#   B1        1120 kg empty   2450 kg max   685 shp
#   B2        1200 kg         2500 kg       732 shp
#   B2 VEMD   1200 kg         2500 kg       732 shp   <- measured on this one
#   BA        1120 kg         2250 kg       640 shp
#
# B2 and B2 VEMD are identical in mass and power; they differ only in instruments. B1 and
# BA are lighter and less powerful.
#
# **The obvious way to test whether that matters does not work.** A control hover on the BA
# read collective 0.5226 against the B2's 0.5596 — but at 1644 kg against 1786, and at
# 782 m density altitude against 825. Both differences push the collective the same way and
# together account for the gap. `collective.hover_collective` moves with weight and density
# altitude by definition, so it cannot separate two variants unless both are flown at
# identical mass and weather — and even then the difference would be smaller than half a
# fuel load.
#
# What would differ between variants is inner_kp and the trims, and those follow the rotor
# head and the airframe geometry, which the .acf files show to be the same across all four.

name      = Airbus AS350 B
acf_match = AS350
icao      = AS50

# ── Measured constants ───────────────────────────────────────────────────────
# Measured 2026-08-27 in **still air** (wind 0.00 m/s), over the last 90 s of a
# 177 s hover with all three assists engaged and the pilot's hands off. 1787 kg,
# 825 m density altitude, rotor governed at 390.7 RPM.
#
# The hover is the steadiest in the fleet: collective 0.5574..0.5584 across 1962
# frames, height constant to 0.7 mm, drift standard deviation 0.0005 m/s. There is
# no spread here to argue about.
const collective.hover_collective = 0.558

# Swept twice on 2026-08-27 in still air, gains reconstructed from the log rather
# than from bookkeeping (correction against attitude error, r > 0.98, exact
# because inner_kd is 0). **Pitch is the axis that rings**; roll follows it at
# about half the amplitude and never leads.
#
#   going up    quiet through 0.130 (pitch rate p90 0.37) ... 0.141 (0.59)
#               ... 0.145 breaks into 13.6
#   coming back 0.124 no decay over 8 s | 0.120 decays over 27 s but only to 1.72
#               | 0.115 settles to 0.28 | 0.110 quiet at 0.21
#
# The first sweep used 5 s steps on the way down and read 0.118 as loud; the
# second gave the same gain 15 s and it was quiet. **At the lower edge of a
# hysteresis band the question is whether the oscillation decays, and that cannot
# be answered in five seconds.**
#
# So the margin comes from where it fully recovers, not from where it starts:
# 0.110 / 1.3 = 0.085. Inside the band from 0.145 down to about 0.115 a
# disturbance does not decay, and in flight a gust is the disturbance.
#
# Choosing the low end is nearly free on this airframe, which is why there is no
# case for aiming into the band. The inner loop's standing error is 0.268 deg
# longitudinal at kp 0.060 against the EC130's 1.5, so the whole span from 0.085
# to 0.120 is worth 0.03 deg of lateral authority. On the EC130 the same argument
# ran the other way and was worth doubling it.
const cyclic.inner_kp = 0.085

# ── cyclic.inner_kd: swept 2026-10-08 12:44 ───────────────────────────────────
# reference_flights/Airbus_AS350_B/2026-10-08_12-44-08, assistant Full, still air, 1660 kg,
# 511 m density altitude, up to 42 m and 30 m/s. Three stages as on the 902X, steps logged
# as TUNING events. Rates high-passed (2 s mean removed), deg/s pitch / roll:
#
#   kd      hover          straight >8 m/s   turn > 10 deg
#   0.000   1.12 / 0.54    1.91 / 2.49       1.89 / 2.49
#   0.020   0.38 / 0.04    0.73 / 0.73       0.60 / 0.73
#   0.040   0.27 / 0.03    0.26 / 0.32       0.54 / 1.01
#
# At 0 the pitch rang at ~1.1 s in forward flight (12:17: +-3.5..4 deg/s, only +-0.6 deg of
# attitude, which is why the attitude error alone missed it) — the 902X's ring at half the
# amplitude. 0.040 took it out by a factor of 4-8 and was the pilot's choice in the air,
# as on the 902X. Kd leaves the droop alone, so the trims below stay valid. Open as there:
# inner_kp was swept at kd 0 only.
const cyclic.inner_kd = 0.040

# Measured 2026-08-27 at that gain and valid only there, over the last 45 s of a
# 61 s hover: 783 frames, standard deviation 0.0013 and 0.0004 degrees. The
# attitudes actually flown were +1.917 / +3.430; the remainder is the inner loop's
# standing error, and it came out at 0.189 / 0.104 against 0.189 / 0.103 predicted
# from the kp 0.060 flight. The droop model holds to the third decimal here.
const cyclic.hover_trim_long = 2.106

const cyclic.hover_trim_lat = 3.534

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.085, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 23 flights 2026-08-27 .. 2026-10-21: pitch +1.87
# (+1.37 .. +2.27), roll +3.30 (+2.25 .. +3.87). A state, like the trims: it moves with the load.
const cyclic.hover_attitude_long = 1.87
const cyclic.hover_attitude_lat  = 3.30

# The generic 5.0 leaves this airframe 1.47 degrees of lateral authority against
# weather — below the 1.5 at which the position hold is expected to start giving
# up ground. Longitudinal has 2.89 and is fine; as everywhere, the vulnerable axis
# is a different one per airframe.
#
# **Flown in wind on 2026-08-27 and the size is no longer borrowed.** At 16 to 20 kt from
# 270 degrees, across a take-me-up and a 46 s hover:
#
#   still air        trim_long +2.31   trim_lat +3.55
#   take me up 16 kt trim_long +4.31   trim_lat +4.52, peaking at **5.72**
#   hover      19 kt trim_long +4.57   trim_lat +3.97
#
# The lateral integrator went past 5.0 during the climb, so the generic bound would have
# pinned it exactly where the weather asked for most — and the longitudinal reached 5.01 in
# the same run. At 8.0 neither touches the stop in any of the three flights: 0 % of frames.
#
# What it bought: 2.8 m of ground given up across a 46 s hover in 19 kt, drift p80 0.16 m/s.
# The EC130 on the generic bound once lost 86 m in 159 s at 11 kt with every lamp green.
#
# They move together on purpose: the outer loop's output is clamped to attitude_limit, so
# integral room beyond it cannot be used.
const cyclic.integral_limit_deg = 8.0

# cyclic.attitude_limit_deg was 10.0, counted from level. Since #78 every limit counts
# from the hover trim, and the generic 7.5 applies (2026-10-14).
# Measured 2026-08-27 from a deliberate collective sweep across the full range,
# yaw damper engaged, no altitude hold, no forward speed. 2622 frames with the
# yaw rate settled below 1 deg/s:
#
#     pedal = +1.159 * collective - 0.252     r = +0.971, residual RMS 0.039
#
# Positive like the EC130 and opposite to both Robinsons: this rotor turns the
# other way, torque yaws the nose left, and it is held on right pedal.
#
# The free cross-check agrees: at the measured hover collective of 0.5596 the line
# predicts +0.397 of pedal, and the settled hover sits on +0.4001. The intercept
# of -0.252 is close enough to zero for the law's anchoring to hold — the Cabri's
# -1.868 is what disqualifies a slope, not a quarter.
#
# A second sweep the same session reached only r = +0.776. It was flown against
# the airframe's power limit with the pilot fighting to recover, and the data say
# so; it is in the archive but not in this number.
const yaw.torque_per_collective = 1.159

# The generic 2.0 leaves most of this airframe on the table. Measured 2026-08-27
# against the VEMD's first-limit indicator, sampled over the web API because
# FLIneedle is not a bound parameter (the run is archived beside the flight logs):
#
#   take me up at 2.0 m/s   collective 0.589   FLI 79.8   NG 92.4   rotor 390.7
#   hand climb at FLI 95    collective 0.72    8-9 m/s    NG 97.3   rotor 390.6
#
# **NG is the first limit, not torque** — at FLI above 85 the gas generator sits at
# 97 % while torque is still at 85. And the rotor never droops: 389.6 RPM minimum
# across the whole climb, so rotor_droop_fraction is not the binding constraint
# here as it is on the Cabri.
#
# 3.0 rather than the 8 that fits: FLI would land near 82-85, keeping roughly ten
# points in hand. The measurement was taken at 1786 kg and 900 m density altitude,
# and both of those eat the margin — a figure that spends it is wrong on a warm
# day with a full cabin.
# Flown at 3.0, then at 5.0 on 2026-08-27. At 5.0 the climb-capacity report still
# reads comfortable — rotor down 0.18 %, 0.33 of collective free, collective 0.627
# against the 0.589 it sits at during a 2.0 climb. On the FLI curve measured the
# same day (0.589 -> 80, 0.72 -> 95) that is roughly FLI 84, so the reserve is
# real rather than assumed.
#
# 6.0 is where this stops: it is the top of the settings slider, it lands near
# FLI 87, and beyond it the hand-flown evidence (8 to 9 m/s at FLI 95) leaves no
# margin for a warm day or a full cabin. Measured at 1697 kg and 780 m density
# altitude — both figures that eat into it.
# sequence.climb_rate_ms = 6.0: the trainer's take-me-up climb, not used by the assistant.

# Raised with the take-me-up climb above. This is the ceiling the collective hold never
# exceeds, and at the generic 5.0 it would silently clip a 6.0 request — the pilot
# changes the climb rate and nothing happens, which is exactly the confusion that
# came the other way round when only the ceiling was raised. A ceiling above every
# rate the slider can ask for never binds.
const collective.max_climb_ms = 8.0

# Design rotor speed, the yardstick of the rig check's overspeed line (issue #47).
# From .acf _prop/0/_des_rpm_prp, the same in B1/B2/BA; 21 reference flights hover at 101.4-101.6 %.
const rotor.design_rpm = 385

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 17.552 ft, times two.
const rotor.diameter_m = 10.70

# ── Bindings ─────────────────────────────────────────────────────────────────
bind cyclic_pitch = sim/cockpit2/controls/yoke_pitch_ratio | clamp -1 1
bind cyclic_roll = sim/cockpit2/controls/yoke_roll_ratio | clamp -1 1
bind pedal = sim/cockpit2/controls/yoke_heading_ratio | clamp -1 1
# The collective is read from the blade angle, not from prop_ratio, because this airframe
# is steered through the blade angle (see the write binding below). Under that write
# prop_ratio reports the raw lever on some frames and the command on others, which makes
# hover_collective, the feedforward slope and every before/after comparison unmeasurable.
#
# 'units blade_pitch_deg' takes the range from acf_min_pitch/acf_max_pitch at runtime —
# -0.6 .. 12.0 degrees here, verified on 2026-08-27, and notably not the R22's 0.5 .. 11.5.
# Two airframes with different travel are exactly why the range is read rather than written
# into a profile.
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
const airframe.vne_kt = 155
bind velocity_east_ms = sim/flightmodel/position/local_vx
bind velocity_south_ms = sim/flightmodel/position/local_vz
bind position_east_m = sim/flightmodel/position/local_x
bind position_south_m = sim/flightmodel/position/local_z
bind rotor_rpm = sim/cockpit2/engine/indicators/prop_speed_rpm[0]
bind engine_rpm = sim/cockpit2/engine/indicators/engine_speed_rpm[0]
bind engine_torque_nm = sim/cockpit2/engine/indicators/torque_n_mtr[0]
bind throttle = sim/cockpit2/engine/actuators/throttle_ratio[0] | clamp 0 1

# ── Write targets ────────────────────────────────────────────────────────────
# Cyclic and pedals are steered through X-Plane's standard axes, and saying nothing about
# them means exactly that.
#
# The collective is not, for the reason the R22 established on 2026-08-28: on the standard
# axis the lever wins. With the hold running and the pilot moving the lever, the plugin
# went on commanding while the machine sank — the controller holding a setpoint it could no
# longer actuate. Writing the blade angle every frame ends that. It does not win the axis
# while the lever moves; it ends the fight when the lever stops, and it hands back cleanly.
#
# No flag. `override_prop_pitch` decouples the rotor and puts nothing in its place — 3.0
# written under the flag left the blade at 0.5 degrees and the torque flat, the same 3.0
# with the flag down moved both. On this airframe there is a second reason: Commands.lua
# rewrites that flag from the cockpit collective lock on every frame, so it could not be
# held even if it helped.
#
# The lock itself remains a way to lose the axis, and deliberately so — it is a pilot's
# switch, and with it in the add-on drives the blade angle itself. That is the one case
# where this write is fought, and the pilot is the one who asked for it.
#
# Flown on 2026-08-28, and this airframe holds the axis better than the R22 does. Four hard
# disengagements from gaps of 0.10 to 0.50, both directions: faded in 0.52 to 0.97 s with a
# largest single-frame step of 0.032, which is no step at all. With the hold running the
# lever wins 28 percent of the frames in which it is moving and none in which it rests —
# against the R22's 100 and 3. Why it differs is not measured.
#
# The reading was cross-checked rather than assumed: hover collective 0.5507 and 0.5539
# against the 0.5595 measured through prop_ratio on 2026-08-27, and the two runs are 22 and
# 25 kg lighter at 133 and 47 m less density altitude. Lighter and denser both push the
# figure down, the three runs order monotonically in both, so the difference is the day and
# not the binding.
#
# #71 (2026-10-11): NOT behind override_prop_pitch. Ground test: one engine, prop 1 is the
# tail rotor (-14 .. 18.5 deg), and the main rotor turns clockwise (acf_prop_dir[0] -1) —
# X-Plane computes the tail as mid + 16.2 x pedal, the other way round from the R22 (228
# samples, mean error 0.2 deg); the plugin takes that sign from the sim. Flown behind the
# flag (00:24, fm 4): none of 116 lever changes on the lever, Commands.lua lowering the flag
# lost to the reassert as on the B412 — but at 46-53 m/s with the cyclic at its authority the
# collective swung 0.32-0.59 at ~3 s and pitch rate +-9 deg/s with the lever still. The same
# speed and stick without the flag on 2026-10-09 was calm, and the AW139 behind the flag at
# its authority above 40 m/s was calm too. Back on the plain write until an A/B flight says
# whether the flag is the cause. The lever may take the collective for a frame here.
#
# #75 (2026-10-16): behind the flag again for the A/B. Without it the Saitek's lever flutter
# (24/min at rest) put the lever on the rotor in 951 frames, 140 single-frame jumps over 0.05
# a minute against 20 on the Thrustmaster, and the pilot felt it. The rocking of 10-11 came
# with the cyclic at its authority of 0.30; since #76 the assistant has 0.60 and the AS350
# hardly reaches it. Flown 2026-10-16 on both rigs (16:35 simulator, 16:47 laptop): no frame
# off the command, calmer at speed than without the flag. The flag stays.
write collective = sim/flightmodel/engine/POINT_pitch_deg_use[0] | units blade_pitch_deg | flag sim/operation/override/override_prop_pitch
