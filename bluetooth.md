# Bluetooth Setup
Date: 2024-12-28

## Status
Bluetooth working with BlueZ and Blueman GUI.

## Installed Packages
```
bluez              # Bluetooth protocol stack
bluez-utils        # CLI utilities (bluetoothctl)
blueman            # GTK Bluetooth manager
```

## Install
```bash
sudo xbps-install -S bluez bluez-utils blueman
```

## Enable Service
```bash
sudo ln -s /etc/sv/bluetoothd /var/service/
sudo sv start bluetoothd
```

## Verify
```bash
sudo sv status bluetoothd
bluetoothctl show    # Check adapter info
```

## Usage
- Launch Blueman from app menu or `blueman-manager`
- CLI: `bluetoothctl` for pairing/connecting
