# Robinson R22 Beta II (Laminar default)
#
# Every path here was read back from a running X-Plane 12.4.3 over the Web API — see the
# dataref table in CLAUDE.md. Index 0 of the engine arrays is the main rotor; index 1 is
# the tail rotor.

name      = Robinson R22 Beta II
acf_match = Robinson_R22
icao      = R22

# ── Measured constants ───────────────────────────────────────────────────────
# Measured 2026-08-22 in still air, see CLAUDE.md.
const collective.hover_collective = 0.418
const yaw.torque_per_collective   = -1.112

# Inner loop gain, found in flight 2026-08-25: this airframe starts rocking at 0.080 and is
# unusable from 0.090 up. 0.060 sits a factor 1.33 below the onset.
#
# Written here even though it equals the generic default, because that is the point: **the
# default was never generic.** It is this aircraft's figure, set when this aircraft was the
# only one, and it travelled to three heavier machines that each tolerate more than twice
# as much — the EC130 rocks at 0.155, the R66 at 0.145, and both carried more than a degree
# of avoidable standing attitude error because of it. Exactly the failure CLAUDE.md
# describes: with a single aircraft the mistake is invisible.
#
# Recording it here also means the R22 no longer follows if the default is ever raised for
# an unmeasured airframe.
const cyclic.inner_kp = 0.060

# ── cyclic.inner_kd: set BY FEEL 2026-10-08, not swept ────────────────────────
# The pilot set 0.040 in the air (reference_flights/Robinson_R22_Beta_II/2026-10-08_13-17-38,
# assistant Full, still air) after the same value took the pitch ringing out of the 902X and
# the AS350 in forward flight. One stage only, no 0 / 0.020 comparison on this airframe:
# hover q/p rms 0.11 / 0.30, straight 0.20 / 0.44, turn 0.25 / 0.73 deg/s (high-passed).
# That flight also showed kd on the body rate pulling the nose 3 deg down in a 22 deg turn
# (kd · q / kp, largest here because kp is the fleet's smallest) — fixed by damping the
# attitude rates (util/attitude_rates.hpp). A sweep would make this a measurement.
const cyclic.inner_kd = 0.040

# Standing hover attitude, measured 2026-08-24 from the settled climb. The lateral figure
# is translating tendency — the tail rotor pushing sideways, so the aircraft hangs left wing
# low — and it is why this airframe was the worst affected by the old 3.0 integral clamp.
#
# Alone among the four, these were measured at the gain this airframe actually wants, so
# they need no re-flying. Seeded on engage so the loop does not relearn it on every
# take-off: it took 21.6 s to wind up to and cost 14.0 m of sideways travel in the low
# hover.
const cyclic.hover_trim_long = 1.21
const cyclic.hover_trim_lat  = -3.98

# The attitude it actually hovers in, for Natural's spring (cyclic.hover_attitude_*, 2026-11-01):
# median of the held Full hovers at inner_kp 0.06, both sticks centred, wind below 0.5 m/s, below
# 1 m/s, rates below 1.5 deg/s - 13 flights 2026-08-28 .. 2026-10-11: pitch -1.19
# (-1.73 .. -0.63), roll -1.18 (-1.87 .. -0.75). A state, like the trims: it moves with the load.
# On X-Plane 12.4.4 at the same mass (487-499 kg) it hovers 1.5 deg nose higher: released, below
# 0.5 m/s, no wind, Full 2026-11-01 21:47 pitch +0.53 roll +0.33, Natural 22:20 pitch +0.33 roll
# -0.27 (laptop-thrustmaster); Natural's drift hold sat at +1.3 .. +2 deg nose up in every still
# hover, near its limit. Rounded to the two:
const cyclic.hover_attitude_long = 0.4
const cyclic.hover_attitude_lat  = 0.0

# Design rotor speed, the yardstick of the rig check's overspeed line (issue #47).
# From .acf _prop/0/_des_rpm_prp; 14 reference flights hover at 101.9 %.
const rotor.design_rpm = 520

# Main rotor diameter: where ground effect ends for the assistant's lever band (#54).
# From .acf _blad/0/_semilen_SEG 12.600 ft, times two.
const rotor.diameter_m = 7.68

# Where translational lift goes, slowing down: the collective held level out of ground
# effect steps from 0.28 at 8 m/s to 0.40 at 7 m/s (2026-10-08, four Full flights, 1 m/s bins).
const collective.assist_lift_lost_below_ms = 8.0

# ── Pilot controls ───────────────────────────────────────────────────────────
bind cyclic_pitch = sim/cockpit2/controls/yoke_pitch_ratio   | clamp -1 1
bind cyclic_roll  = sim/cockpit2/controls/yoke_roll_ratio    | clamp -1 1
bind pedal        = sim/cockpit2/controls/yoke_heading_ratio | clamp -1 1
# The blade angle itself, mapped back onto 0..1 over acf_min_pitch[0]..acf_max_pitch[0]
# (0.5 .. 11.5 degrees), rather than prop_ratio.
#
# prop_ratio stopped telling the truth the moment this aircraft started steering its
# collective through the blade angle. Measured in the 2026-08-28 hold, it alternated
# frame by frame between the plugin's command and the raw inverted lever — coll + pilot
# summing to exactly 1.000 in every other row — which makes hover_collective, the
# feedforward sweep and any before/after comparison unmeasurable on this airframe.
#
# 'units blade_pitch_deg' is the same option the write line carries, and it reads the range
# from acf_min_pitch/acf_max_pitch at runtime. It replaced a hand-computed scale and offset
# for the R22's 0.5 .. 11.5 degrees: those were correct for this airframe and would have
# had to be recomputed for every further one, against numbers the sim already knows.
bind collective   = sim/flightmodel2/engines/prop_pitch_deg[0] | units blade_pitch_deg | clamp 0 1

# ── Rates and attitude ───────────────────────────────────────────────────────
bind roll_rate_deg_s  = sim/flightmodel/position/P
bind pitch_rate_deg_s = sim/flightmodel/position/Q
bind yaw_rate_deg_s   = sim/flightmodel/position/R
bind sideslip_deg     = sim/flightmodel/position/beta

# Attitude, degrees: the setpoint of the Stage 2 cyclic cascade's inner loop.
bind pitch_deg = sim/flightmodel/position/theta | clamp -90 90
bind roll_deg  = sim/flightmodel/position/phi   | clamp -180 180
# True heading, 0…360. Used by the Stage 2 heading hold.
bind heading_deg = sim/flightmodel/position/psi

# ── Position and motion ──────────────────────────────────────────────────────
bind vertical_speed_ms = sim/flightmodel/position/vh_ind
# Height above ground: the reference for the Stage 2 collective hold.
bind altitude_agl_m = sim/flightmodel/position/y_agl
bind altitude_msl_m = sim/flightmodel/position/elevation
# #76: indicated airspeed, for the assistant's VNE. Its never-exceed speed, from the .acf
# (P acf/_Vne_kts, read 2026-10-11).
# The Mariner (floats) sets 92 kt and is recognised as this profile; 102 is the skids.
bind indicated_airspeed_kt = sim/flightmodel/position/indicated_airspeed
const airframe.vne_kt = 102
# Recorded only: X-Plane's artificial-stability channel and the total that reaches the
# rotor. On the R22 nothing writes the first, so it reads X-Plane's own (zero with
# art_stab off); the columns exist so a log of this airframe can be held against an
# add-on that mixes into the controls (EC135 2026-11-02).
bind artstab_pitch = sim/joystick/artstab_pitch_ratio
bind artstab_roll  = sim/joystick/artstab_roll_ratio
bind artstab_yaw   = sim/joystick/artstab_heading_ratio
bind total_pitch   = sim/cockpit2/controls/total_pitch_ratio
bind total_roll    = sim/cockpit2/controls/total_roll_ratio
bind total_yaw     = sim/cockpit2/controls/total_heading_ratio
# World-axis ground velocity: +x east, +z south. Turned into body axes by the Stage 2
# cyclic hold.
bind velocity_east_ms  = sim/flightmodel/position/local_vx
bind velocity_south_ms = sim/flightmodel/position/local_vz
# Verified 2026-08-22 against the running sim: doubles in metres, same axes as the
# velocities above (x east, z south).
bind position_east_m  = sim/flightmodel/position/local_x
bind position_south_m = sim/flightmodel/position/local_z

# ── Engine and rotor ─────────────────────────────────────────────────────────
bind rotor_rpm        = sim/cockpit2/engine/indicators/prop_speed_rpm[0]
bind engine_rpm       = sim/cockpit2/engine/indicators/engine_speed_rpm[0]
bind engine_torque_nm = sim/cockpit2/engine/indicators/torque_n_mtr[0]
bind throttle         = sim/cockpit2/engine/actuators/throttle_ratio[0] | clamp 0 1
# A piston engine has a manifold, so this reading means something. On a turbine the same
# dataref reports ambient pressure and is deliberately left unbound.
bind manifold_in_hg = sim/cockpit2/engine/indicators/MPR_in_hg[0]

# The pedals and cyclic are steered entirely through X-Plane's standard axes, and saying
# nothing about them here means exactly that.
#
# The collective is the exception, and it is the open question behind the axis being lost
# whenever the pilot moves the lever. X-Plane recomputes the blade angle from the lever
# every frame, so a hold writing prop_ratio is outvoted the moment the lever moves:
# measured in flight, the loop commanded 0.908 while the aircraft sank at 5.65 m/s.
#
# This writes the blade angle itself instead — one step closer to the rotor than
# prop_ratio, and the 0..1 command is mapped onto acf_min_pitch[0]..acf_max_pitch[0]
# (0.5 to 11.5 degrees here, so the measured hover collective of 0.418 lands at 5.10).
#
# **No flag, deliberately.** override_prop_pitch does not make this axis steerable, it
# decouples the rotor from the blade angle and puts nothing in its place: measured on the
# ground 2026-08-28, POINT_pitch_deg held at 3.0 under the flag left the actual blade angle
# at 0.5 and engine torque flat at 85 Nm. Lowering the flag with the same value standing
# moved the blade to 3.0 and the torque to 150. The flag is the thing that blocks.
#
# Whether writing every frame beats the lever here is what this is for. Held at 10 Hz over
# the web API it does not — the blade angle tracked the lever across 0.67..5.24 while a
# constant 3.0 was being written — but that test cannot answer the question at 60 Hz, which
# is the mistake that cost two installs on 2026-08-28. The plugin writes every frame.
#
# It flew on 2026-08-28. Two hard disengagements from a wide gap, both directions: command
# 0.382 with the lever at 1.000 faded over 1.07 s, command 0.388 with the lever at 0.000
# over 0.81 s, no step in either. That is the failure of 2026-08-22 — a 0.4 jump in the
# collective, twice ending on the ground — measured as gone.
#
# What it does not do is win the axis. While the lever moves, X-Plane restores it in all
# 305 frames measured; while it rests, the command holds in 97 percent. The fight is
# shortened rather than won, and it now always ends, and it ends safely.
#
# The read binding above had to follow: under this write prop_ratio reports the lever.
# #71 (2026-10-10): behind override_prop_pitch now, writing POINT_pitch_deg_use — the one the
# flag hands over. The "no flag" paragraphs above stand corrected: 2026-08-28 wrote
# POINT_pitch_deg under the flag, which X-Plane does not read then. The flag freezes the tail
# rotor too (prop 1, -9.5 .. 18.5 deg here); the plugin writes it from the total pedal as
# X-Plane does — ground-tested 2026-10-10, mean error 0.15 deg, no lag. Without the flag every
# hardware lever change flew one frame on the lever.
write collective = sim/flightmodel/engine/POINT_pitch_deg_use[0] | units blade_pitch_deg | flag sim/operation/override/override_prop_pitch
