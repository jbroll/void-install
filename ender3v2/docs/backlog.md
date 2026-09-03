# Backlog

## Where this stands

The printer runs Klipper and is calibrated: `z_offset` 2.338, both heaters
tuned, bed mesh saved, probe repeatability 0.0046 mm. Mainsail is at
<http://ender3v2.local/> and reports ready. Nothing has been printed yet.

Two threads are open, in this order.

**Resume here.** Wire the ADXL345 per the table in
[user-manual.md](user-manual.md#wiring), `INT1` and `INT2` unconnected. Then:

```sh
ssh john@ender3v2.local
# uncomment [include adxl345.cfg] in ~/printer_data/config/printer.cfg
```

```
FIRMWARE_RESTART
ACCELEROMETER_QUERY
```

`ACCELEROMETER_QUERY` should return roughly 9.8 m/s² on one axis. Then
`TEST_RESONANCES AXIS=X` with the sensor on the head, remount to the bed, and
`TEST_RESONANCES AXIS=Y`.

**Then the first print.** OrcaSlicer 2.4.2 is installed on the laptop and can
upload to Moonraker directly. A single-layer test square settles the first-layer
offset, which the paper test could only get to about ±0.05 mm.

## First layer offset not yet confirmed on a print

`z_offset` came from the paper test, which resolves to roughly ±0.05 mm.
`PROBE_ACCURACY` also showed the probe triggering an average 0.027 mm below the
calibrated zero. Neither is worth chasing on the bench. Print a single-layer
test square, tune live with `SET_GCODE_OFFSET Z_ADJUST=±0.01 MOVE=1`, then fold
the result into `z_offset`.

## ADXL345 not yet wired

Everything else for input shaping is in place: SPI enabled with `/dev/spidev0.0`
present, `klipper-mcu.service` running and providing `/tmp/klipper_host_mcu`,
numpy 2.5.2 importing, and `adxl345.cfg` written. `printer.cfg` has the include
commented out so Klipper stays startable while the sensor is absent.

Klipper does not use `INT1` or `INT2`; it reads the FIFO over SPI and
`[adxl345]` has no interrupt setting.

## Bed has a front-edge tilt

The 5x5 mesh spans 0.195 mm, and nearly all of it is one tilt: the front row
reads about 0.15 mm high while the middle and back are flat within 0.07 mm. The
mesh compensates, but `BED_SCREWS_ADJUST` would remove the cause.

## PackageKit not installed

`set-policykit-rules.sh` has been run, so service management, shutdown and
reboot work from Mainsail. The PackageKit actions remain unregistered because
PackageKit itself is not installed, so apt updates through the update manager
still fail. `sudo apt install packagekit` enables them.

## trusted_clients hardcodes an ISP-delegated IPv6 prefix

`moonraker.conf` lists `2600:4040:5656:b00::/64` so browsers reaching the Pi over
IPv6 are accepted. That prefix is delegated by the ISP. If it rotates, Mainsail
starts returning 401 and the line needs updating.

A stable fix would be to stop nginx forwarding the client address, so Moonraker
sees 127.0.0.1 and the LAN check happens at nginx instead. That trades away
per-client logging.

## The router is the only thing keeping Mainsail private

Checked on 2026-09-02 from an external host with working IPv6: `ping6` to the
Pi's global address lost 3 of 3 packets and HTTP to port 80 timed out with no
response. The router drops unsolicited inbound IPv6.

That is a single layer. The Pi runs no firewall, the nftables ruleset is empty,
iptables is not installed, and nginx listens on `[::]:80`. Mainsail has no login
and Moonraker grants service, reboot and shutdown rights through PolicyKit. If
the router policy ever changes, all of that is directly exposed.

Defence in depth would be a host firewall on the Pi allowing port 80 only from
the LAN, or `force_logins: True` in Moonraker's `[authorization]`.

## Stock firmware not yet downloaded

The rollback image, Creality's 4.2.7 build with BLTouch support, has not been
fetched. Creality serves it through a JavaScript download centre, so it needs a
browser. Until it exists there is no way back to Marlin.

## Leftover first-boot warning on SSH login

Every SSH login prints "Please note that SSH may not work until a valid user has
been set up." It comes from Raspberry Pi OS's first-boot user check, which still
looks for the original `pi` account. Cosmetic. The source was not tracked down;
`/etc/profile.d/sshpwd.sh` is a different message and not the culprit.
