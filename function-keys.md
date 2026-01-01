# Function Keys & Touchpad
Date: 2025-12-25

## Hardware
ASUS Zenbook 14 UX3405MA (Intel Meteor Lake)
Touchpad: ASUE120C:00 04F3:32D8 (Elan)

## Status
- Brightness and volume function keys working with OSD popups
- Touchpad tap-to-click enabled

## Brightness Keys

### Driver
ASUS WMI modules loaded automatically:
```
asus_nb_wmi
asus_wmi
```

Backlight interface: `/sys/class/backlight/intel_backlight`

### Configuration
xfce4-power-manager handles brightness keys. Must enable:
```bash
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/brightness-switch -s 1
```

Verify setting:
```bash
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/brightness-switch
# Should return: 1
```

## Volume Keys

### Configuration
Two components work together:

1. **Keyboard shortcuts** (change the volume):
```bash
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/XF86AudioRaiseVolume" -n -t string -s "pactl set-sink-volume @DEFAULT_SINK@ +5%"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/XF86AudioLowerVolume" -n -t string -s "pactl set-sink-volume @DEFAULT_SINK@ -5%"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/XF86AudioMute" -n -t string -s "pactl set-sink-mute @DEFAULT_SINK@ toggle"
```

2. **xfce4-pulseaudio-plugin** (shows OSD popup):
   - Add to panel: Right-click panel → Panel → Add New Items → "PulseAudio Plugin"
   - The plugin detects volume changes and displays the OSD

### Verify shortcuts
```bash
xfconf-query -c xfce4-keyboard-shortcuts -lv | grep XF86Audio
```

## Restore Commands
If function keys stop working after update/reinstall:

```bash
# Brightness
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/brightness-switch -s 1

# Volume
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/XF86AudioRaiseVolume" -n -t string -s "pactl set-sink-volume @DEFAULT_SINK@ +5%"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/XF86AudioLowerVolume" -n -t string -s "pactl set-sink-volume @DEFAULT_SINK@ -5%"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/XF86AudioMute" -n -t string -s "pactl set-sink-mute @DEFAULT_SINK@ toggle"
```

## Touchpad

### Driver
Uses `xf86-input-libinput`. The synaptics driver (`xf86-input-synaptics`) must NOT be installed or it will take precedence and ignore the libinput config.

```bash
# Ensure synaptics is not installed
xbps-query xf86-input-synaptics  # Should return "not installed"

# If installed, remove it:
sudo xbps-remove xorg-input-drivers xf86-input-synaptics
```

### Configuration
Config file: `/etc/X11/xorg.conf.d/30-touchpad.conf`

```
Section "InputClass"
    Identifier "touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "TappingButtonMap" "lrm"
EndSection
```

Options:
- `Tapping` - enables tap-to-click
- `TappingButtonMap` - 1-finger=left, 2-finger=right, 3-finger=middle

### Restore
```bash
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/30-touchpad.conf << 'EOF'
Section "InputClass"
    Identifier "touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "TappingButtonMap" "lrm"
EndSection
EOF
```

Requires logout/login or reboot to take effect.

### Verify
```bash
# Check X11 tapping state (after login)
xinput list-props "ASUE120C:00 04F3:32D8 Touchpad" | grep "Tapping Enabled"
# libinput Tapping Enabled (381):	1

# Note: libinput list-devices shows the default state, not X11 overrides
```

## Caps Lock Remapped to Escape

Caps Lock is remapped to Escape (useful for vim):

```bash
setxkbmap -option caps:escape
```

### Autostart
File: `~/.config/autostart/caps-to-escape.desktop`
```
[Desktop Entry]
Type=Application
Name=Caps Lock to Escape
Exec=setxkbmap -option caps:escape
```

### Alternative mappings
```bash
setxkbmap -option caps:none           # Disable completely
setxkbmap -option caps:ctrl_modifier  # Make it Ctrl
setxkbmap -option caps:backspace      # Make it Backspace
```

## Notes
- PipeWire handles audio via pipewire-pulse compatibility layer
- xfce4-pulseaudio-plugin works with PipeWire (uses pactl)
- The plugin's "Enable keyboard shortcuts" option is not required; external shortcuts trigger the OSD
