# Backlog

## Probe Z offset is uncalibrated

`z_offset` in `[bltouch]` is `0`, a placeholder. Homing Z or starting a print
with that value drives the nozzle into the bed. Run `PROBE_CALIBRATE` before any
Z move. See [quickstart.md](quickstart.md#2-calibrate-the-probe-offset).

## PID values are generic

The `[extruder]` and `[heater_bed]` PID constants came from Klipper's sample
config, not this machine. Marlin's stored values could not be reused; Klipper
scales its constants differently. Run `PID_CALIBRATE` for both heaters.

## Bed mesh has never been probed

`BED_MESH_CALIBRATE` has not run, so there is no mesh to load.

## CR Touch pin assignment is unverified

`[bltouch]` uses `sensor_pin: ^PB1` and `control_pin: PB0`, taken from Klipper's
Ender 3 V2 Neo sample. The offsets are confirmed from Marlin's EEPROM, but the
pins are an assumption about how the probe is wired. If the probe does not
deploy or never triggers, this is the first thing to check.

## Moonraker cannot manage system services

Moonraker logs PolicyKit warnings at startup: service management, shutdown,
reboot and package updates through Mainsail are all disabled. Its
`scripts/set-policykit-rules.sh` enables them. Not run, because it grants the
Moonraker process the right to restart services and reboot the machine.

Decide whether that trade is worth making.

## trusted_clients hardcodes an ISP-delegated IPv6 prefix

`moonraker.conf` lists `2600:4040:5656:b00::/64` so browsers reaching the Pi over
IPv6 are accepted. That prefix is delegated by the ISP. If it rotates, Mainsail
starts returning 401 and the line needs updating.

A stable fix would be to stop nginx forwarding the client address, so Moonraker
sees 127.0.0.1 and the LAN check happens at nginx instead. That trades away
per-client logging.

## IPv6 exposure is unassessed

The Pi holds a routable IPv6 address and Mainsail has no login. Whether port 80
is reachable from outside the LAN depends on the router's inbound IPv6 filtering,
which has not been checked.

## Stock firmware not yet downloaded

The rollback image, Creality's 4.2.7 build with BLTouch support, has not been
fetched. Creality serves it through a JavaScript download centre, so it needs a
browser. Until it exists there is no way back to Marlin.

## Leftover first-boot warning on SSH login

Every SSH login prints "Please note that SSH may not work until a valid user has
been set up." It comes from Raspberry Pi OS's first-boot user check, which still
looks for the original `pi` account. Cosmetic. The source was not tracked down;
`/etc/profile.d/sshpwd.sh` is a different message and not the culprit.
