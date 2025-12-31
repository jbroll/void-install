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

### 7. Disable DPMS for DisplayPort monitors

DPMS (Display Power Management Signaling) has a long-standing bug with Intel + DisplayPort where the monitor fails to wake after entering power-save mode. The DisplayPort link training fails to re-establish. See [freedesktop bug #23500](https://bugs.freedesktop.org/show_bug.cgi?id=23500) (open since 2010).

Symptoms: Monitor appears connected (mouse moves off laptop screen) but backlight stays off after idle timeout.

Disable DPMS:
```bash
xset -dpms
```

Add to session autostart (`~/.config/autostart/disable-dpms.desktop`):
```ini
[Desktop Entry]
Type=Application
Name=Disable DPMS
Exec=xset -dpms
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
```

Light-locker still blanks and locks the screen - it just won't send the DPMS signal that breaks DisplayPort wake.

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
