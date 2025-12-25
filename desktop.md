# Desktop Setup (Xfce)
Date: 2024-12-24

## Status
Xfce pre-installed with Void Linux live image. Additional customizations below.

## Panel Configuration

Config file: `~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml`
Backup: `~/Install/xfce4-panel.xml`

### Panel-1 (Top bar)
- Position: top (p=6), full width
- Size: 32px, auto-hide
- Plugins: app menu, tasklist, pager, systray, clock (2x), power manager, actions

### Panel-2 (Dock)
- Position: left side (p=5), deskbar mode
- Size: 48px, always hidden until hover (autohide=2)
- Plugins: show desktop, launchers, directory menu

### Restore from backup
```bash
cp ~/Install/xfce4-panel.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/
xfce4-panel -r  # restart panel
```

## Installed Packages
```
xfce4-screenshooter-1.11.2_1    # Screenshot tool
light-locker-1.9.0_3            # Screen locker (replaces xfce4-screensaver for locking)
firefox-146.0_1                 # Web browser (pre-installed)
```

## Screenshot Tool

### Panel Launcher
1. Right-click Xfce panel → Panel → Add New Items
2. Add "Launcher"
3. Right-click launcher → Properties → Add `xfce4-screenshooter`

### Keyboard Shortcuts (Settings → Keyboard → Application Shortcuts)
| Key | Command | Action |
|-----|---------|--------|
| `Print` | `xfce4-screenshooter -f` | Fullscreen |
| `Shift+Print` | `xfce4-screenshooter -r` | Select region |
| `Alt+Print` | `xfce4-screenshooter -w` | Active window |

### Useful Options
- `-d N` - Delay N seconds before capture
- `-c` - Copy to clipboard instead of save dialog
- `-s /path/` - Save directly to directory

## Not Installed
- `xfce4-whiskermenu-plugin` - Alternative app menu (not needed, default menu is fine)
- `flameshot` - Qt-based screenshot tool (removed to avoid Qt dependencies)

## Screen Locker (light-locker)
light-locker replaces xfce4-screensaver for screen locking (xfce4-screensaver has rendering issues on resume with Intel Meteor Lake graphics).

### Configuration
xfce4-screensaver locking disabled:
```bash
xfconf-query -c xfce4-screensaver -p /lock/sleep-activation/enabled -s false
xfconf-query -c xfce4-screensaver -p /lock/enabled -s false -t bool -n
```

light-locker autostart: `~/.config/autostart/light-locker.desktop`

On suspend/resume, light-locker locks the session and lightdm greeter handles authentication.

See `suspend.md` for full suspend/resume configuration.

## Terminal Configuration (xfce4-terminal)

### Alt as Copy/Paste Keys
Configured via Edit → Preferences → Shortcuts, or by editing `~/.config/xfce4/terminal/accels.scm`:

```scheme
(gtk_accel_path "<Actions>/terminal-window/copy" "<Alt>c")
(gtk_accel_path "<Actions>/terminal-window/paste" "<Alt>v")
```

CLI method (close terminal first):
```bash
sed -i 's/^; (gtk_accel_path "<Actions>\/terminal-window\/copy".*)/(gtk_accel_path "<Actions>\/terminal-window\/copy" "<Alt>c")/' ~/.config/xfce4/terminal/accels.scm
sed -i 's/^; (gtk_accel_path "<Actions>\/terminal-window\/paste".*)/(gtk_accel_path "<Actions>\/terminal-window\/paste" "<Alt>v")/' ~/.config/xfce4/terminal/accels.scm
```

## Firefox Configuration

### Alt as Accelerator Key
Firefox configured to use Alt instead of Ctrl for keyboard shortcuts:
- Alt-C = Copy
- Alt-V = Paste
- Alt-X = Cut
- Alt-A = Select All
- Alt-T = New Tab
- Alt-W = Close Tab
- etc.

Configuration in `~/.mozilla/firefox/hdea4m4c.default-default/user.js`:
```javascript
user_pref("ui.key.accelKey", 18);  // 18 = Alt key
```

Restart Firefox after changing user.js.

## Notes
- Void Xfce includes `xfce4-pulseaudio-plugin` by default
- PipeWire handles audio (not PulseAudio), but the plugin works via pipewire-pulse
