# Printing Setup
Date: 2024-12-24

## Installed Packages
```
cups-2.4.13_1
cups-filters-2.0.1_1
system-config-printer-1.5.18_5
ghostscript-10.06.0_1
```

## Service
```bash
# Enabled with:
sudo ln -s /etc/sv/cupsd /var/service/

# Check status:
sudo sv status cupsd
```

## Usage
- Web interface: http://localhost:631
- GUI: `system-config-printer`
- Add printer via Settings or web interface

## Network Printer Discovery
Avahi provides mDNS/DNS-SD for automatic network printer discovery:
```bash
sudo xbps-install -S avahi
sudo ln -s /etc/sv/avahi-daemon /var/service/
```

Restart Firefox after enabling avahi for printers to appear in print dialog.
