# Quickstart

From a working install to a first print.

## 1. Check the printer is alive

Power the printer on, then open <http://ender3v2.local/>. The dashboard should
show both temperatures near room temperature and no error banner.

The printer's own LCD shows a frozen "Creality" splash. That is normal. Klipper
does not drive the DWIN display.

If Mainsail shows an error instead, see
[user-manual.md](user-manual.md#when-klipper-will-not-connect).

## 2. Calibrate the probe offset

`z_offset` ships as `0`, which tells Klipper the nozzle touches the bed at the
moment the probe triggers. The true figure is a couple of millimetres, so until
this is calibrated Klipper's Z zero sits well above the glass and the printer
extrudes into the air.

Homing is safe at this setting. `z_offset` too low means a nozzle too high; a
value set too large is what drives the nozzle into the bed.

In the Mainsail console:

```
G28
PROBE_CALIBRATE
```

The nozzle moves to the probe point and stops above the bed. Slide a sheet of
paper underneath, then step down with `TESTZ Z=-0.1` until the paper drags with
slight resistance. `TESTZ Z=+0.02` steps back up. Then:

```
ACCEPT
SAVE_CONFIG
```

`SAVE_CONFIG` writes the value into `printer.cfg` and restarts Klipper.

## 3. Level the bed

```
G28
BED_MESH_CALIBRATE
SAVE_CONFIG
```

This probes a 5x5 grid. If a corner reads far off the others, adjust the bed
screws with `BED_SCREWS_ADJUST` and probe again.

## 4. Tune the heaters

The PID values in `printer.cfg` came from Klipper's generic sample, not from
your machine.

```
PID_CALIBRATE HEATER=extruder TARGET=200
PID_CALIBRATE HEATER=heater_bed TARGET=60
SAVE_CONFIG
```

Each run takes several minutes.

## 5. Print

Slice with the printer set to an Ender 3 V2 profile, upload the g-code through
Mainsail, and start it. Nothing in the slicer needs to know about Klipper.

Watch the first layer. If the nozzle is too close or too far, adjust live with
`SET_GCODE_OFFSET Z_ADJUST=0.02 MOVE=1` and fold the correction back into
`z_offset` afterwards.
