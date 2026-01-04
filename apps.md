# Custom Applications
Date: 2024-12-24

## wider
Window layout save/restore utility.

**Location:** `~/src/wider/`

**Dependencies:**
```bash
sudo xbps-install -y tcl tk xprop wmctrl xwininfo
```

**Desktop file:** `~/.local/share/applications/wider.desktop`
```ini
[Desktop Entry]
Type=Application
Name=Wider
Comment=Window layout save/restore utility
Exec=wish /home/john/src/wider/wider.tcl
Icon=/home/john/src/wider/wider.svg
Terminal=false
Categories=Utility;
```

**Panel launcher:** Added to panel-2 (dock)

---

## talkie
Real-time speech-to-text application with keyboard simulation.

**Location:** `~/src/talkie/`

**Dependencies:**
```bash
sudo xbps-install -y tcl tk portaudio-devel
```
- `~/src/jbr.tcl/` - Tcl utility library collection
- Speech recognition models in `~/src/talkie/models/`

**Desktop file:** `~/.local/share/applications/talkie.desktop`
```ini
[Desktop Entry]
Version=1.0
Name=Talkie
Comment=Real-time speech-to-text application with keyboard simulation
GenericName=Speech Recognition
Exec=/home/john/src/talkie/src/talkie.sh
Icon=/home/john/src/talkie/icon.svg
Terminal=false
Type=Application
Categories=AudioVideo;Audio;Accessibility;Utility;
StartupNotify=true
Keywords=speech;recognition;voice;transcription;accessibility;
StartupWMClass=Talkie
```

**Panel launcher:** Added to panel-2 (dock)

---

## Pinta (Flatpak)
Simple image editor similar to Paint.NET.

**Install:**
```bash
flatpak install -y flathub com.github.PintaProject.Pinta
```

**Run:**
```bash
flatpak run com.github.PintaProject.Pinta
```

---

## Adding to Panel

Desktop files copied to `~/.local/share/applications/` and launchers added to panel-2:
```bash
cp ~/src/wider/wider.desktop ~/.local/share/applications/
cp ~/src/talkie/talkie.desktop ~/.local/share/applications/

# Launchers configured as plugins 23 (wider) and 24 (talkie)
xfconf-query -c xfce4-panel -p /panels/panel-2/plugin-ids
# [11,12,13,14,15,16,23,24,17,18]
```
