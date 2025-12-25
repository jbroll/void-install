# Void Linux Installation Plan
Generated: 2024-12-24

## Status
- [x] Base system installed
- [x] auto-cpufreq (thermal management)
- [x] Firmware & Graphics
- [x] Desktop (Xfce)
- [x] Audio (kernel 6.16+ for CS35L41)
- [x] Printing
- [x] Development tools
- [x] Utilities
- [x] Suspend/resume (see suspend.md)

---

## 1. NECESSARY

### Firmware & Graphics (DONE)
```bash
sudo xbps-install -Sy linux-firmware linux-firmware-intel sof-firmware
sudo xbps-install -Sy mesa mesa-dri mesa-vulkan-intel mesa-vaapi intel-media-driver vulkan-loader
```

### Audio (PipeWire) - ALREADY INSTALLED
Pre-installed with Xfce base:
- pipewire, wireplumber, alsa-pipewire, alsa-utils
- sof-firmware installed with firmware step
- **Reboot required** to load Intel audio firmware

### Desktop (Xfce)
```bash
sudo xbps-install -S xfce4 lightdm lightdm-gtk3-greeter
sudo ln -s /etc/sv/lightdm /etc/runit/runsvdir/default/
# Extras
sudo xbps-install -S xfce4-whiskermenu-plugin xfce4-pulseaudio-plugin xfce4-screenshooter
```

### Printing
```bash
sudo xbps-install -S cups cups-filters system-config-printer
sudo ln -s /etc/sv/cupsd /etc/runit/runsvdir/default/
```

---

## 2. CONVENIENT

### Development - Base
```bash
sudo xbps-install -S git cmake clang gdb llvm
sudo xbps-install -S python3 python3-pip python3-devel
```

### Development - Embedded
```bash
sudo xbps-install -S cross-arm-none-eabi-gcc cross-arm-none-eabi-newlib
# arduino-cli: download from https://arduino.github.io/arduino-cli/
```

### Node.js (via NVM) - DONE
```bash
# Installed: Node v22.21.1, NPM 10.9.4
# NVM in ~/.config/nvm
```

### Browser & Apps (DONE)
Firefox pre-installed. Configured Alt as accelerator key (Alt-C/V/X for copy/paste/cut).
See `desktop.md` for configuration.

### Utilities (DONE)
```bash
sudo xbps-install -S htop lm_sensors rsync curl wget unzip p7zip
sudo xbps-install -S neofetch tree jq ripgrep fd
sudo xbps-install -S tcl tk tcllib xclip
```

---

## 3. EXTRA (as needed)

### Custom Apps (DONE)
- wider - Window layout save/restore (see `apps.md`)
- talkie - Speech-to-text (see `apps.md`)
- Added to panel-2 dock

### From Backup ~/bin
Copy custom scripts from backup:
- Table utilities (table, column, sorttable, etc.)
- arduino-cli, ds9
- Custom shell scripts

### AppImages
Copy from backup:
- `Avogadro2-x86_64.AppImage`
- `UltiMaker-Cura-5.7.2-linux-X64.AppImage`

### Manual Installs
| Tool | Source | Notes |
|------|--------|-------|
| pnpm | get.pnpm.io | Node package manager |
| protoc | GitHub releases | Protocol buffers |
| sherpa-onnx | GitHub releases | Speech recognition (if needed) |

### NOT NEEDED (removed from Ubuntu)
- snap, snapd (no Void support)
- cloud-init services
- Ubuntu-specific: apport, kerneloops, ubuntu-advantage
- Virtualization: qemu, libvirt, containerd, docker
- Ollama (can add later if needed)

---

## Services Summary

### Enable after install:
```bash
# Already enabled:
# - NetworkManager
# - auto-cpufreq
# - chronyd
# - dbus
# - lightdm
# - acpid (for lid suspend)
# - cupsd (printing)

# Add these if not enabled:
sudo ln -s /etc/sv/cupsd /var/service/
sudo ln -s /etc/sv/acpid /var/service/
```

### Check status:
```bash
sudo sv status /var/service/*
```

---

## Environment Setup

### ~/.bashrc additions
```bash
# NVM (auto-added by installer)
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Cargo/Rust
. "$HOME/.cargo/env"

# Pico SDK (if using)
export PICO_SDK_PATH=~/pkg/pico-sdk

# Path
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
```
