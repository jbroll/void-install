# Architecture

## Pieces

Four processes, each with one job.

**Klipper** (`klippy.py`) does the motion planning. It reads `printer.cfg`,
computes step timings on the Pi, and sends them to the printer's MCU over
serial. The MCU runs a small Klipper firmware that does nothing but execute
timed steps. This split is why Klipper can drive faster acceleration than
Marlin on the same 72 MHz STM32: the arithmetic happens on the Pi.

**Moonraker** is the API server. It talks to Klipper over a Unix socket at
`~/printer_data/comms/klippy.sock` and exposes HTTP and WebSocket endpoints. It
also owns the file manager, print history, and the update manager. It binds to
127.0.0.1 only.

**Mainsail** is a static web app. It runs entirely in the browser and reaches
Moonraker over HTTP and a WebSocket. Nothing about it executes on the Pi.

**nginx** serves Mainsail's files and proxies the Moonraker endpoints so both
arrive on port 80 from the browser's point of view. Without it the browser would
face a cross-origin request to port 7125.

## Data flow

```
browser ──http/ws──> nginx :80 ──proxy──> moonraker :7125
                       │                       │
                       │                    unix socket
                    ~/mainsail                 │
                   (static files)          klippy.py
                                               │
                                          serial 250000
                                               │
                                        CH340 ──> STM32F103
```

## Why this shape

**Installed from upstream repos rather than KIAUH.** The host runs Debian 13.
Klipper and Moonraker's helper scripts, and nearly every Ender 3 guide, were
written against Debian 12, which is now oldstable. KIAUH is menu-driven, so a
distro check that fails mid-menu leaves a half-built tree rather than an error
you can act on. Installing each piece directly puts every file at a known path.

**Moonraker on 127.0.0.1.** Everything reaches it through nginx, so binding it
to all interfaces would only widen exposure. The Pi holds a routable IPv6
address, and Mainsail has no login by default, so the only thing standing
between the printer and the open internet is the router's inbound filtering.

**Serial rather than USB in the MCU firmware.** The 4.2.7's USB socket is wired
to a CH340 bridge, which feeds the MCU's USART1. The MCU has no USB peripheral
in this path, so the firmware is built for serial at 250000 baud. A USB build
would produce a board that never enumerates.

## Printer configuration

`~/printer_data/config/printer.cfg` starts from Klipper's
`config/printer-creality-ender3-v2-2020.cfg`, which already carries the correct
pin map for this board, and adds:

- `[bltouch]` with `x_offset: -40.0` and `y_offset: -5.0`, read from the
  printer's own Marlin EEPROM via `M851` before Marlin was replaced, and
  `z_offset` 2.338 from `PROBE_CALIBRATE`.
- Probing at `speed: 5` with `samples: 3` and `samples_result: median`. The
  first attempt used the Neo sample's `speed: 20`, which gave a probe standard
  deviation of 0.032 mm because the trigger point moved with deceleration.
  Dropping to 5 mm/s brought it to 0.0046 mm.
- `[safe_z_home]` homing at nozzle position 157.5, 122.5. That is bed centre
  117.5, 117.5 shifted by the probe offsets, so the probe sits over the middle
  of the bed rather than the nozzle.
- `[bed_mesh]` bounded at 20,20 to 190,210. The limits are the nozzle's travel
  range shifted by the probe offsets: with the probe 40 mm left of the nozzle,
  the probe cannot reach past X 195 before the nozzle hits its own limit.
- `[stepper_z]` using `probe:z_virtual_endstop`, so the probe replaces the Z
  endstop switch.

No `[tmc2209]` or similar sections. The drivers run standalone, with current set
by trimpot rather than software, so Klipper has nothing to configure.

`mainsail.cfg` is symlinked from the `mainsail-config` checkout and supplies the
macros Mainsail expects, such as `PAUSE`, `RESUME` and `CANCEL_PRINT`, plus
`[virtual_sdcard]` and `[display_status]`.

## Identifying the board without opening the case

Recorded because it is reusable. With the printer still on Marlin:

- `lsusb` showing `1a86:7523` means a CH340 bridge, which rules out the later
  revisions that present USB natively.
- `M115` reports the Marlin build and `MACHINE_TYPE`.
- `M503` dumps stored settings. `M906` lines mean the TMC drivers are under UART
  control; their absence means standalone.
- Quiet motors mean silent TMC drivers rather than the 4.2.2's louder ones.

Absence of `M906` plus quiet motors identifies a 4.2.7 running standalone TMCs.
Neither signal alone is conclusive.
