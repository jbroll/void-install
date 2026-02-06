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

## Usage

```bash
flatpak run org.openscad.OpenSCAD
```

Or find "OpenSCAD" in the application menu.

## Manifold Backend

The beta version includes the Manifold geometry engine for significantly faster rendering.

To enable: **Preferences > Advanced > 3D Rendering > Backend > Manifold**

Or via command line:
```bash
flatpak run org.openscad.OpenSCAD --backend=manifold
```

## Note

The Void Linux repo version (2021.01) is too old for Manifold support, hence the Flatpak installation.
