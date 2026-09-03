# Backlog

## First layer offset not yet confirmed on a print

`z_offset` came from the paper test, which resolves to roughly ±0.05 mm.
`PROBE_ACCURACY` also showed the probe triggering an average 0.027 mm below the
calibrated zero. Neither is worth chasing on the bench. Print a single-layer
test square, tune live with `SET_GCODE_OFFSET Z_ADJUST=±0.01 MOVE=1`, then fold
the result into `z_offset`.

## Bed has a front-edge tilt

The 5x5 mesh spans 0.195 mm, and nearly all of it is one tilt: the front row
reads about 0.15 mm high while the middle and back are flat within 0.07 mm. The
mesh compensates, but `BED_SCREWS_ADJUST` would remove the cause.

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
