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
| [utilities.md](utilities.md) | CLI tools + swap |
| [bluetooth.md](bluetooth.md) | BlueZ + Blueman setup |

## Key Fixes

1. **No audio**: Install kernel 6.16+ for CS35L41 speaker amp timing
2. **Black screen on resume**: Use light-locker + acpid instead of xfce4-screensaver
3. **No tap-to-click**: Remove xf86-input-synaptics, use libinput
