# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a documentation repository for a Void Linux installation on an ASUS Zenbook 14 UX3405MA (Intel Meteor Lake, Core Ultra 7 155H). It contains configuration guides, troubleshooting notes, and setup instructions - not executable code.

## Hardware Context

- **Laptop**: ASUS Zenbook 14 UX3405MA
- **CPU**: Intel Meteor Lake (Core Ultra 7 155H)
- **Audio**: CS35L41 Cirrus Logic speaker amplifier (requires kernel 6.16+)
- **Touchpad**: Elan ASUE120C:00 04F3:32D8

## File Structure

| File | Purpose |
|------|---------|
| `PLAN.md` | Master installation checklist and status |
| `audio.md` | PipeWire/CS35L41 speaker amp configuration |
| `suspend.md` | Lid close/resume fix (light-locker + acpid) |
| `function-keys.md` | Brightness/volume keys and touchpad tap-to-click |
| `desktop.md` | Xfce panel config, screenshot tool, Firefox Alt-key shortcuts |
| `apps.md` | Custom Tcl/Tk applications (wider, talkie) |
| `utilities.md` | Installed CLI tools and swap configuration |
| `auto-cpufreq.md` | Thermal management service setup |
| `bluetooth.md` | BlueZ installation commands |
| `firmware-graphics.md` | Intel graphics/firmware packages |
| `printing.md` | CUPS setup |
| `dev-tools.md` | Development environment |
| `xfce4-panel.xml` | Panel configuration backup |

## Void Linux Specifics

**Package management:**
```bash
sudo xbps-install -S <package>    # Install package
xbps-query -Rs <term>             # Search packages
xbps-query -l                     # List installed
```

**Service management (runit):**
```bash
sudo ln -s /etc/sv/<service> /var/service/   # Enable service
sudo sv status <service>                      # Check status
sudo sv start/stop/restart <service>          # Control service
```

**Configuration tool:**
```bash
xfconf-query -c <channel> -p <property> -s <value>   # Set Xfce config
xfconf-query -c <channel> -lv                        # List all properties
```

## Key Workarounds Documented

1. **Audio**: Kernel 6.16+ required for CS35L41 speaker amp timing fix
2. **Suspend**: Uses light-locker + acpid instead of xfce4-screensaver (rendering issues with Intel graphics on resume)
3. **Touchpad**: Must remove xf86-input-synaptics to use libinput tap-to-click
