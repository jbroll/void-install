# Klipper + Mainsail on a Pi Zero 2 W for the Ender 3 V2

Design document. Working file, to be deleted in the commit that lands the work
once its contents are folded into `ender3v2/README.md` and `ender3v2/docs/`.

## Goal

Run Klipper on an Ender 3 V2, hosted on a Raspberry Pi Zero 2 W, controlled
through Mainsail in a browser at `http://ender3v2.local/`.

## Hardware and starting state

| Thing | Value |
|-------|-------|
| Host | Raspberry Pi Zero 2 W, hostname `ender3v2` |
| OS | Raspbian GNU/Linux 13 (trixie), 32-bit armv7l, kernel 6.18.34+rpt-rpi-v7 |
| Memory | 425 MB usable, 424 MB zram swap |
| Disk | 14 GB card, 12 GB free |
| User | `john`, uid 1000, in `dialout`, passwordless sudo, SSH key auth only |
| Printer | Ender 3 V2, Creality 4.2.7 mainboard |
| MCU | STM32F103 with the 28 KiB Creality bootloader |
| Drivers | Silent TMC drivers (TMC2208/2225 class) in standalone mode |
| Probe | CR Touch, Marlin offsets X -40.00, Y -5.00 |
| Link | CH340 USB serial bridge, `/dev/ttyUSB0` |

The board was identified without opening the case. `lsusb` reports a CH340
(`1a86:7523`), which rules out the later native-USB revision. `M503` returns no
`M906` lines, so the drivers are not under UART control, and the motors run
quiet, which means silent TMC drivers wired standalone. That combination is the
4.2.7. Which TMC part it carries varies by batch and does not matter here,
because standalone drivers need no Klipper configuration of their own.

`M115` reports `Marlin V1.0.7 (Oct 25 2022)`, `MACHINE_TYPE:Ender-3 V2`. Steps
per unit are stock: `M92 X80.00 Y80.00 Z400.00 E92.60`.

## Accepted trade-off

Flashing Klipper replaces Marlin, and Klipper does not drive the Ender 3 V2's
DWIN display. After the flash the screen goes dark and the printer is operated
only from Mainsail. This was raised and accepted.

## Approach

Install Klipper, Moonraker and Mainsail directly from their upstream repos and
releases rather than through KIAUH.

The reason is trixie. The helper scripts and nearly every Ender 3 guide were
written against Bookworm, which is now oldstable, and KIAUH is menu-driven, so a
distro check that bails out mid-menu leaves a half-built tree instead of a clear
error. Installing each piece directly means every file lands at a known path and
each step either succeeds or fails visibly.

## Host layout

Everything under `/home/john`, using Klipper's current data-directory
convention:

```
~/klipper/                  Klipper3d/klipper checkout
~/klippy-env/               Klipper's Python venv
~/moonraker/                Arksine/moonraker checkout
~/moonraker-env/            Moonraker's Python venv
~/mainsail/                 Mainsail release zip, unpacked static files
~/printer_data/
  config/printer.cfg
  config/moonraker.conf
  logs/
  gcodes/
  comms/
```

Two systemd units, `klipper.service` and `moonraker.service`, both running as
`john`. Moonraker listens on 127.0.0.1:7125 and is not exposed directly.

nginx serves `~/mainsail` on port 80 and proxies `/websocket`, `/printer`,
`/api`, `/access`, `/machine` and `/server` to Moonraker.

## Printer link

`printer.cfg` points at `/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0`.

The CH340 reports no serial number, so this path is stable only while it is the
only CH340 attached to the Pi. If a second one is ever added, both by-id paths
collide and the config needs a udev rule keyed on USB port instead.

## MCU firmware

Built in `~/klipper` with:

- Micro-controller: STMicroelectronics STM32
- Processor model: STM32F103
- Bootloader offset: 28 KiB
- Communication interface: Serial (on USART1 PA10/PA9)
- Baud rate: 250000

USB on the 4.2.7 reaches the MCU through the CH340 rather than natively, which
is why this is a serial build and not a USB one.

The build produces `out/klipper.bin`. Flashing means copying it to a FAT32 SD
card under a filename not used before and power-cycling the printer. Creality's
bootloader skips a filename it has already flashed, so each reflash needs a new
name. The convention here is `firmware-YYYYMMDD-N.bin`.

## Printer config

Derived from Klipper's `config/printer-creality-ender3-v2-2020.cfg`, with:

- `[bltouch]` carrying `x_offset: -40`, `y_offset: -5`, and a `z_offset`
  established by calibration, not carried over from Marlin.
- `[safe_z_home]` and `[bed_mesh]`.
- No `[tmc2209]` sections, since the drivers are standalone.

## Rollback

The existing Marlin image cannot be read off the board. Creality's stock 4.2.7
firmware for the Ender 3 V2, the BLTouch variant, gets downloaded before the
first flash so there is a way back.

It is kept off the SD card. The bootloader flashes whatever `.bin` it finds on
the card, so a second binary present at flash time is ambiguous. The rollback
image goes onto the card only when rolling back, and alone.

## Risks

- Moonraker's Python dependencies are built against trixie's Python 3.13 rather
  than the Bookworm 3.11 upstream tests on. Wheel builds may need system
  packages the install docs do not list.
- 425 MB of RAM. Compiling Python extensions in the Moonraker venv is the
  tightest moment; zram swap covers it but slowly.
- `z_offset` must be calibrated by hand after the first Klipper boot. The
  printer will crash into the bed if it is left unset or guessed.

## Documentation

Permanent docs live in `Install/ender3v2/`, separate from the laptop's Void
documentation, with its own `README.md` and `docs/` following the usual layout.
