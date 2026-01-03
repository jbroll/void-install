# Void Linux Installation Notes

Configuration guides for Void Linux on ASUS Zenbook 14 UX3405MA (Intel Meteor Lake).

## Hardware

- **CPU**: Intel Core Ultra 7 155H
- **Audio**: CS35L41 Cirrus Logic amp (kernel 6.16+ required)
- **Touchpad**: Elan ASUE120C

## Documentation

| File | Description |
|------|-------------|
| [PLAN.md](PLAN.md) | Installation checklist |
| [audio.md](audio.md) | PipeWire + CS35L41 fix |
| [suspend.md](suspend.md) | Lid close/resume fix |
| [function-keys.md](function-keys.md) | Fn keys + touchpad |
| [desktop.md](desktop.md) | Xfce configuration |
| [apps.md](apps.md) | Custom Tcl/Tk apps (wider, talkie) |
| [utilities.md](utilities.md) | CLI tools + swap |
| [auto-cpufreq.md](auto-cpufreq.md) | Thermal management |
| [bluetooth.md](bluetooth.md) | BlueZ + Blueman setup |
| [firmware-graphics.md](firmware-graphics.md) | Intel graphics/firmware |
| [printing.md](printing.md) | CUPS printer setup |
| [dev-tools.md](dev-tools.md) | Development environment |
| [kicad.md](kicad.md) | KiCad EDA suite |
| [onedrive.md](onedrive.md) | OneDrive client (built from source) |

## Key Fixes

1. **No audio**: Install kernel 6.16+ for CS35L41 speaker amp timing
2. **Black screen on resume**: Use light-locker + acpid instead of xfce4-screensaver
3. **No tap-to-click**: Remove xf86-input-synaptics, use libinput
