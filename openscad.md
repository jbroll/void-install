# OpenSCAD

Solid 3D CAD modeller using a programming language to define models.

## Installation (Flatpak Beta)

Installed via Flatpak to get Manifold geometry backend support (requires development snapshot 2024.09.28+).

```bash
# Add flathub-beta repository
sudo flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo

# Install OpenSCAD beta
sudo flatpak install flathub-beta org.openscad.OpenSCAD
```

## Wrapper Script

A wrapper script in `~/bin/openscad` allows running the Flatpak as a regular command:

```bash
#!/bin/sh
exec flatpak run org.openscad.OpenSCAD "$@"
```

## Usage

```bash
openscad                    # Launch GUI
openscad model.scad         # Open file in GUI
```

Or find "OpenSCAD" in the application menu.

## CLI Usage

Render models without the GUI:

```bash
openscad -o output.stl model.scad             # Export to STL
openscad -o output.png model.scad             # Render to PNG
openscad -D 'size=20' -o out.stl model.scad   # With variables
openscad --backend=manifold -o out.stl model.scad  # Use Manifold
```

Supported export formats: stl, off, wrl, amf, 3mf, csg, dxf, svg, pdf, png, pov

## Manifold Backend

The beta version includes the Manifold geometry engine for significantly faster rendering.

To enable: **Preferences > Advanced > 3D Rendering > Backend > Manifold**

Or via command line:
```bash
flatpak run org.openscad.OpenSCAD --backend=manifold
```

## Note

The Void Linux repo version (2021.01) is too old for Manifold support, hence the Flatpak installation.
