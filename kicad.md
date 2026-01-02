# KiCad
Date: 2026-01-02

Electronic design automation (EDA) suite for schematic capture, PCB layout, and 3D visualization.

## Installed Packages
```
kicad-9.0.6_2              # Main application
kicad-library-9.0.6_1      # Meta-package for all libraries
kicad-symbols-9.0.6_1      # Schematic symbol libraries
kicad-footprints-9.0.6_1   # PCB footprint libraries
kicad-packages3D-9.0.6_1   # 3D model libraries
kicad-templates-9.0.6_1    # Project templates
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
~/.config/kicad/9.0/      # User configuration
~/Documents/KiCad/        # Default project location
/usr/share/kicad/         # System libraries and templates
```

## Library Paths
The libraries are installed to `/usr/share/kicad/`:
- `symbols/` - Schematic symbol libraries (.kicad_sym)
- `footprints/` - PCB footprint libraries (.pretty directories)
- `3dmodels/` - 3D models (.step, .wrl)
- `template/` - Project templates
