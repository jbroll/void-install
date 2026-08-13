# KiCad
Date: 2026-08-13

Electronic design automation (EDA) suite for schematic capture, PCB layout, and 3D visualization.

## Installed Packages
```
kicad-10.0.3_1             # Main application
kicad-library-10.0.3_1     # Meta-package for all libraries
kicad-symbols-10.0.3_1     # Schematic symbol libraries
kicad-footprints-10.0.3_1  # PCB footprint libraries
kicad-packages3D-10.0.3_1  # 3D model libraries
kicad-templates-10.0.3_1   # Project templates
```

## Installation
```bash
sudo xbps-install -S kicad kicad-library
```

## Components
- **Schematic Editor** - Draw circuit schematics with symbols
- **PCB Editor** - Design printed circuit board layouts
- **3D Viewer** - Visualize boards with 3D component models
- **Symbol Editor** - Create/edit schematic symbols
- **Footprint Editor** - Create/edit PCB footprints
- **Gerber Viewer** - View manufacturing files
- **Calculator Tools** - Track width, via size, attenuators, etc.

## Launch
```bash
kicad                     # Main project manager
```

## Key Directories
```
~/.config/kicad/10.0/     # User configuration
~/Documents/KiCad/        # Default project location
/usr/share/kicad/         # System libraries and templates
```

## Library Paths
The libraries are installed to `/usr/share/kicad/`:
- `symbols/` - Schematic symbol libraries (.kicad_sym)
- `footprints/` - PCB footprint libraries (.pretty directories)
- `3dmodels/` - 3D models (.step, .wrl)
- `template/` - Project templates

## Headless and Scripted Use

`.kicad_sch` and `.kicad_pcb` are s-expression text, so they diff and edit
cleanly. `kicad-cli` gives the checks and outputs without opening the GUI.

```bash
kicad-cli sch erc --format json -o erc.json board.kicad_sch
kicad-cli pcb drc --format json --severity-all --exit-code-violations -o drc.json board.kicad_pcb
kicad-cli sch export netlist -o board.net board.kicad_sch
kicad-cli sch export bom -o bom.csv board.kicad_sch
kicad-cli pcb export gerbers -o gerbers/ board.kicad_pcb
kicad-cli pcb export drill -o gerbers/ board.kicad_pcb
kicad-cli pcb export step -o board.step board.kicad_pcb
kicad-cli pcb export stats board.kicad_pcb
kicad-cli jobset run --file fab.kicad_jobset board.kicad_pro
```

`--exit-code-violations` makes DRC usable as a gate in a script. A jobset saved
from the GUI runs a whole fab-output set in one command.

Other entry points:
- `pcbnew` - system Python module (`/usr/lib/python3.14/site-packages`), board
  read/write. No venv needed, and no KiCad running.
- `kipy` - IPC API bindings, drives an already-running KiCad over a socket.
  Requires the API server enabled in Preferences.
- `ngspice` - installed separately, runs the simulations KiCad's simulator drives.

### Python environment

```bash
python3 -m venv --system-site-packages ~/venv/kicad
~/venv/kicad/bin/pip install kicad-python skidl
```

`--system-site-packages` is what makes the system `pcbnew` importable inside the
venv; it cannot be pip-installed.

Installed: `kicad-python` 0.7.1 (the `kipy` module), `skidl` 2.3.0, plus
`kinet2pcb`, `netlist_to_skidl`, and `skidl-part-search` scripts.

SKiDL describes a circuit in Python and emits a netlist. It only knows library
env vars up to KiCad 8, so point the v8 variables at the v10 libraries. The v10
variables are what the library tables below expand, and the rest only silence
warnings from SKiDL's other version modules:

```bash
export KICAD8_SYMBOL_DIR=/usr/share/kicad/symbols
export KICAD8_FOOTPRINT_DIR=/usr/share/kicad/footprints
export KICAD10_SYMBOL_DIR=/usr/share/kicad/symbols
export KICAD10_FOOTPRINT_DIR=/usr/share/kicad/footprints
export KICAD_SYMBOL_DIR=/usr/share/kicad/symbols
export KICAD7_SYMBOL_DIR=/usr/share/kicad/symbols
export KICAD9_SYMBOL_DIR=/usr/share/kicad/symbols
```

```python
from skidl import *
set_default_tool(KICAD8)
r1, r2 = 2 * Part("Device", "R", TEMPLATE, value="10k",
                  footprint="Resistor_SMD:R_0805_2012Metric")
vin, gnd, out = Net("VIN"), Net("GND"), Net("OUT")
vin += r1[1]; out += r1[2], r2[1]; gnd += r2[2]
generate_netlist(file_="divider.net")
```

### Library tables

The global symbol and footprint tables are normally written on first GUI run.
They can be installed straight from the templates instead:

```bash
cp -n /usr/share/kicad/template/{fp,sym}-lib-table ~/.config/kicad/10.0/
cp -n /usr/share/kicad/template/{fp,sym}-lib-table ~/.config/kicad/
```

The second copy is for SKiDL. It looks in `~/.config/kicad/<major>.0` for the
tool version in use (KiCad 8 here) and falls back to bare `~/.config/kicad`,
so it never finds the `10.0` copy. Without it, SKiDL warns that footprints are
unavailable and emits the netlist with no footprint fields.

The tables reference `${KICAD10_FOOTPRINT_DIR}`, which KiCad defines internally
but SKiDL expands from the environment, hence the v10 exports above.
