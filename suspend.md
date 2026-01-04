# Suspend Fix
Date: 2024-12-24

## Problem
Screen stays black or input broken after lid close/open resume on Intel Meteor Lake (Core Ultra 7 155H).
`loginctl suspend` works fine, but lid-triggered suspend fails.

## Root Causes
1. **xfce4-power-manager** was registering a "block" inhibitor for lid-switch events
2. **xfce4-screensaver** lock dialog fails to render on resume (Intel graphics issue)

## Solution

### 1. Use light-locker instead of xfce4-screensaver for locking
```bash
sudo xbps-install -y light-locker
```

Disable xfce4-screensaver locking:
```bash
xfconf-query -c xfce4-screensaver -p /lock/sleep-activation/enabled -s false
xfconf-query -c xfce4-screensaver -p /lock/enabled -s false -t bool -n
pkill -f xfce4-screensaver
```

Start light-locker (add to session autostart):
```bash
light-locker &
```

### 2. xfce4-power-manager settings
Defer lid handling to elogind:
```bash
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-ac -s 0 -t int -n
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-battery -s 0 -t int -n
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/logind-handle-lid-switch -s true -t bool -n
```
Then restart xfce4-power-manager.

### 3. elogind configuration
Edit `/etc/elogind/logind.conf`:
```
HandleLidSwitch=ignore
```
Then reload: `sudo pkill -HUP elogind`

### 4. acpid service
Enable acpid to handle ACPI events:
```bash
sudo ln -s /etc/sv/acpid /var/service/
```

### 5. acpid handler
Edit `/etc/acpi/handler.sh` lid section to call `loginctl suspend`:
```bash
button/lid)
    case "$3" in
        close)
            logger "LID closed, suspending..."
            loginctl suspend
            ;;
        open)
            logger "LID opened"
            ;;
    esac
    ;;
```

### 6. Sleep hook
`/usr/lib/elogind/system-sleep/lid-resume.sh`:
```bash
#!/bin/sh
case $1 in
    pre)
        # Restore power management before suspend
        for card in /sys/class/drm/card*/; do
            echo "auto" > "${card}device/power/control" 2>/dev/null
        done
        ;;
    post)
        sleep 1

        # Force display power on
        for card in /sys/class/drm/card*/; do
            echo "on" > "${card}device/power/control" 2>/dev/null
        done

        # Force DisplayPort re-detection
        for dp in /sys/class/drm/card*-DP-*/status; do
            echo "detect" > "$dp" 2>/dev/null
        done
        ;;
esac
```

This hook fixes:
- DisplayPort monitors not powering off during suspend (pre: restore auto power management)
- DisplayPort monitors not being recognized after suspend (post: force re-detection)

### 7. Disable DP MST for DPMS wake fix

DisplayPort monitors fail to wake after DPMS power-save mode on Intel graphics. The DP link training fails to re-establish. See [freedesktop bug #23500](https://bugs.freedesktop.org/show_bug.cgi?id=23500) (open since 2010).

Symptoms: Monitor appears connected (mouse moves off laptop screen) but backlight stays off after idle timeout.

**Fix**: Disable Multi-Stream Transport (MST) via kernel parameter. Edit `/etc/default/grub`:
```
GRUB_CMDLINE_LINUX_DEFAULT="... i915.enable_dp_mst=0"
```

Then regenerate GRUB config and reboot:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
```

With MST disabled, DPMS should work correctly. MST is only needed for daisy-chaining multiple monitors over a single DP connection.

**Note**: This fix reduces but doesn't fully eliminate the problem on all systems. See section 9 for auto-recovery if DP wake still fails.

Verify the parameter is active after reboot:
```bash
cat /proc/cmdline | grep -o 'i915.enable_dp_mst=[0-9]'
# Should show: i915.enable_dp_mst=0
```

### 8. Prevent GPU runtime suspend for DP monitor wake

Even with MST disabled, extended idle (~1 hour) can cause the GPU to enter runtime suspend, breaking the DP link. The DP monitor stays on but shows a black screen because the GPU stops sending signal.

**Fix**: Keep GPU power "on" during normal operation via udev rule.

`/etc/udev/rules.d/99-gpu-power.rules`:
```
ACTION=="add", SUBSYSTEM=="drm", KERNEL=="card0", ATTR{device/power/control}="on"
```

Create the rule:
```bash
sudo mkdir -p /etc/udev/rules.d
echo 'ACTION=="add", SUBSYSTEM=="drm", KERNEL=="card0", ATTR{device/power/control}="on"' | sudo tee /etc/udev/rules.d/99-gpu-power.rules
```

This works with the sleep hook (section 6):
- **Boot**: udev sets GPU power → "on"
- **Normal idle**: GPU stays "on", DP link maintained, DPMS works
- **Suspend**: sleep hook sets GPU → "auto" (allows power saving)
- **Resume**: sleep hook sets GPU → "on"

Verify current setting:
```bash
cat /sys/class/drm/card0/device/power/control
# Should show: on
```

## Event Chain
1. Lid closes -> ACPI event generated
2. xfce4-power-manager: defers to elogind (no inhibitor blocking)
3. elogind: ignores lid events (allows acpid to handle)
4. acpid: catches event, runs handler.sh
5. handler.sh: calls `loginctl suspend`
6. light-locker: locks session before suspend
7. System suspends (s2idle)
8. On resume: lightdm greeter shown for authentication

## Verification
```bash
# Check no lid-switch inhibitors:
busctl call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager ListInhibitors | grep lid-switch
# Should return nothing

# Check light-locker running:
pgrep light-locker

# Check suspend mode:
cat /sys/power/mem_sleep
# Should show [s2idle]
```

### 9. DP monitor auto-recovery daemon

If DP wake still fails after DPMS idle, use this daemon to automatically recover.

**Manual recovery** (run if external display goes black):
```bash
xrandr --output DP-1 --auto --right-of eDP-1
```

**Auto-recovery script** (`~/.local/bin/dp-wake-monitor.sh`):
```bash
#!/bin/sh
# Monitors for failed DP wake after DPMS and auto-recovers
# Only acts when: DPMS is On (user active) but DP has no active mode

while true; do
    sleep 5

    # Check if DPMS is in "On" state (user is active, not idle)
    dpms_on=$(xset q 2>/dev/null | grep -c "Monitor is On")
    [ "$dpms_on" -eq 0 ] && continue

    # Check if DP-1 is connected but has no active resolution
    dp_status=$(xrandr --query 2>/dev/null | grep "^DP-1 connected")
    [ -z "$dp_status" ] && continue

    # If connected but no resolution shown (no * in the mode list)
    has_active=$(xrandr --query 2>/dev/null | sed -n '/^DP-1 connected/,/^[A-Z]/p' | grep -c '\*')
    if [ "$has_active" -eq 0 ]; then
        logger "dp-wake-monitor: DP-1 connected but inactive, recovering..."
        xrandr --output DP-1 --auto --right-of eDP-1
    fi
done
```

**Install and enable**:
```bash
mkdir -p ~/.local/bin
# Create script (content above)
chmod +x ~/.local/bin/dp-wake-monitor.sh
```

**Autostart** (`~/.config/autostart/dp-wake-monitor.desktop`):
```ini
[Desktop Entry]
Type=Application
Name=DP Wake Monitor
Exec=/home/john/.local/bin/dp-wake-monitor.sh
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
```

The daemon checks every 5 seconds. It only runs xrandr when:
1. DPMS state is "On" (user has moved mouse/pressed key)
2. DP-1 is connected but has no active mode

This respects intentional screen blanking during idle.
