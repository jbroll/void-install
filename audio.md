# Audio Setup
Date: 2024-12-24
Updated: 2026-01-27 (WirePlumber no-suspend config, PipeWire crash recovery monitor)

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

## Auto-Start Configuration

Void provides XDG autostart `.desktop` files that start PipeWire automatically on login:
```
/etc/xdg/autostart/pipewire.desktop
/etc/xdg/autostart/pipewire-pulse.desktop
/etc/xdg/autostart/wireplumber.desktop
```

**Important**: Do NOT create `~/.config/autostart/` overrides with `Hidden=true` - this disables autostart.

**Verify**:
```bash
# Check PulseAudio emulation is working
pactl info

# Check processes
ps aux | grep -E "(pipewire|wireplumber)" | grep -v grep
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

## Disable WirePlumber Node Suspend (CS35L41 Idle Fix)

**Problem**: Audio stops working after the computer sits idle (even without suspend). Screen blanks via DPMS, and when you return, audio is locked up.

**Cause**: WirePlumber suspends idle audio nodes after 5 seconds by default. The CS35L41 amp doesn't recover properly from this node suspend.

**Symptoms**: No audio output, but PipeWire appears to be running. May see CS35L41 errors in `dmesg`.

**Solution**: Disable audio node suspend timeout.

`~/.config/wireplumber/wireplumber.conf.d/no-suspend.conf`:
```
monitor.alsa.rules = [
  {
    matches = [
      { node.name = "~alsa_output.*" }
    ]
    actions = {
      update-props = {
        session.suspend-timeout-seconds = 0
      }
    }
  }
]
```

Create with:
```bash
mkdir -p ~/.config/wireplumber/wireplumber.conf.d
cat > ~/.config/wireplumber/wireplumber.conf.d/no-suspend.conf << 'EOF'
monitor.alsa.rules = [
  {
    matches = [
      { node.name = "~alsa_output.*" }
    ]
    actions = {
      update-props = {
        session.suspend-timeout-seconds = 0
      }
    }
  }
]
EOF
```

Apply by restarting WirePlumber:
```bash
pkill wireplumber
# Auto-restarts via XDG autostart
```

Verify the setting is active:
```bash
wpctl status
```

## PipeWire Crash Recovery Monitor

PipeWire can crash unexpectedly, leaving the system without audio. This monitor script detects when PipeWire dies and automatically restarts the audio stack.

`~/.local/bin/audio-monitor.sh`:
```bash
#!/bin/sh
# PipeWire monitor - restarts audio stack if it dies
# Uses XDG autostart for session integration

stop_audio() {
    pkill -9 -x wireplumber 2>/dev/null
    pkill -9 -x pipewire 2>/dev/null
    sleep 2
    # Clean stale sockets after killing processes
    rm -f "$XDG_RUNTIME_DIR"/pipewire-0* 2>/dev/null
    rm -f "$XDG_RUNTIME_DIR"/pulse/native "$XDG_RUNTIME_DIR"/pulse/pid 2>/dev/null
}

start_audio() {
    pgrep -x pipewire >/dev/null || { pipewire & sleep 2; }
    pgrep -x pipewire >/dev/null || return 1
    pgrep -f "pipewire-pulse.conf" >/dev/null || { pipewire -c pipewire-pulse.conf & sleep 2; }
    pgrep -x wireplumber >/dev/null || { wireplumber & }
}

# Wait for session to settle on login
sleep 5

while true; do
    if ! pgrep -x pipewire >/dev/null; then
        logger "audio-monitor: restarting PipeWire"
        stop_audio
        start_audio
        sleep 5
    fi
    sleep 5
done
```

`~/.config/autostart/audio-monitor.desktop`:
```ini
[Desktop Entry]
Type=Application
Name=Audio Monitor
Exec=/home/john/.local/bin/audio-monitor.sh
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
```

**Manual recovery** (if monitor isn't running):
```bash
pkill -x wireplumber; pkill -x pipewire
rm -f /run/user/1000/pipewire-0* /run/user/1000/pulse/native
pipewire &
sleep 2; pipewire -c pipewire-pulse.conf &
sleep 2; wireplumber &
```

## Notes
- Void uses PipeWire by default (not PulseAudio)
- `alsa-pipewire` provides ALSA app compatibility
- Firefox uses PipeWire directly for audio
- No separate pulseaudio-pipewire package needed in Void
- `pipewire-pulse` provides PulseAudio compatibility layer (emulation)
