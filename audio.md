# Audio Setup
Date: 2024-12-24

## Status
Audio packages already installed with base system. Only sof-firmware was missing (installed with firmware step).

## Installed Packages
```
pipewire-1.4.9_1          # Core audio server
wireplumber-0.5.12_1      # Session manager
alsa-pipewire-1.4.9_1     # ALSA compatibility
alsa-lib-1.2.14_1         # ALSA library
alsa-utils-1.2.14_1       # ALSA utilities
alsa-ucm-conf-1.2.14_1    # Use Case Manager configs
sof-firmware-2025.05_1    # Intel Sound Open Firmware (for Meteor Lake audio)
```

## No Additional Install Needed
Void's base Xfce install included PipeWire + Wireplumber.

## Issue: No Sound Cards Detected
Before reboot, `/proc/asound/cards` showed "no soundcards" because sof-firmware was just installed and kernel hasn't loaded it yet.

## Fix
**Reboot required** to load sof-firmware and initialize Intel audio hardware.

## After Reboot
PipeWire/Wireplumber auto-start with desktop session. Verify with:
```bash
# Check sound cards
cat /proc/asound/cards

# Check PipeWire status
pactl info

# Test audio
speaker-test -c 2
```

## Fix: PipeWire Not Auto-Starting (XDG Autostart)

**Problem**: After login, no PulseAudio server running (`pactl info` fails).

**Cause**: Missing XDG autostart symlinks for wireplumber and pipewire-pulse.

**Diagnosis**:
```bash
# Check if processes are running
pgrep -a pipewire
pgrep -a wireplumber

# Check autostart entries
ls /etc/xdg/autostart/*pipewire* /etc/xdg/autostart/*wireplumber*
```

**Fix**: Create missing symlinks:
```bash
sudo ln -s /usr/share/applications/wireplumber.desktop /etc/xdg/autostart/
sudo ln -s /usr/share/applications/pipewire-pulse.desktop /etc/xdg/autostart/
```

**Required autostart entries** (all three needed):
```
/etc/xdg/autostart/pipewire.desktop        -> /usr/share/applications/pipewire.desktop
/etc/xdg/autostart/pipewire-pulse.desktop  -> /usr/share/applications/pipewire-pulse.desktop
/etc/xdg/autostart/wireplumber.desktop     -> /usr/share/applications/wireplumber.desktop
```

**Start manually** (without logout):
```bash
pipewire &
pipewire-pulse &
wireplumber &
```

## CS35L41 Speaker Amp Fix (ASUS Zenbook 14 UX3405MA)

**Problem**: After reboot, no audio output despite PipeWire running correctly.

**Symptoms** in `dmesg`:
```
cs35l41-hda spi0-CSC3551:00-cs35l41-hda.0: Failed waiting for CS35L41_PUP_DONE_MASK: -110
cs35l41-hda spi0-CSC3551:00-cs35l41-hda.1: Failed waiting for CS35L41_PUP_DONE_MASK: -110
```

**Cause**: Kernel 6.12.x has issues with CS35L41 Cirrus Logic speaker amplifier power-up timing.

**Solution**: Install kernel 6.16+ (Ubuntu 6.16.9 worked; Void linux6.16-6.16.12_1 works):
```bash
sudo xbps-install -Sy linux6.16
# GRUB updates automatically, then reboot
```

**Hardware details**:
- Subsystem ID: 10431A63 (ASUS)
- Firmware: `/lib/firmware/cirrus/cs35l41-dsp1-spk-prot-10431a63*`
- Both L/R speaker amps on SPI bus

## Notes
- Void uses PipeWire by default (not PulseAudio)
- `alsa-pipewire` provides ALSA app compatibility
- Firefox uses PipeWire directly for audio
- No separate pulseaudio-pipewire package needed in Void
