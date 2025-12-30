# Printing Setup
Date: 2024-12-30

## Installed Packages
```
cups-2.4.13_1
cups-filters-2.0.1_1
system-config-printer-1.5.18_5
ghostscript-10.06.0_1
gutenprint-5.3.4_1
sane-1.3.1_2
sane-airscan-0.99.36_1
simple-scan-46.0_1
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

## Canon MX450 Network Printer

The Canon MX450 inkjet supports IPP with URF (Apple Raster) and JPEG formats. Standard drivers (Gutenprint, generic PCL) fail due to Ghostscript rendering issues with borderless mode.

### Working Setup: Driverless Printing

Generate a PPD directly from the printer's IPP capabilities:
```bash
# Discover printer
avahi-browse -r -t _ipp._tcp | grep Canon
# Shows: address = [192.168.1.238], port = [631], rp = ipp/print

# Generate driverless PPD
driverless ipp://192.168.1.238:631/ipp/print > /tmp/canon-driverless.ppd

# Add printer with generated PPD
sudo lpadmin -p Canon-MX450 -E \
  -v "ipp://192.168.1.238:631/ipp/print" \
  -P /tmp/canon-driverless.ppd \
  -L "Network" -D "Canon MX450 series"

# Set as default with Letter paper
sudo lpadmin -d Canon-MX450
lpoptions -d Canon-MX450 -o PageSize=Letter -o MediaType=Stationery
```

### Why Driverless Works

The generated PPD uses direct passthrough filters:
```
cupsFilter2: "image/urf image/urf 0 -"
cupsFilter2: "image/jpeg image/jpeg 0 -"
```

This bypasses the Ghostscript CUPS raster pipeline that fails with "Page drawing error" on this printer. Data is converted to URF format and sent directly.

### Verify Setup
```bash
lpstat -p -d                    # Check printer status
echo "Test" | lp -d Canon-MX450 # Test print
```

## Canon MX450 Network Scanning

The MX450 scanner is automatically detected by SANE via both the pixma backend and sane-airscan (WSD).

### Install SANE
```bash
sudo xbps-install -S sane sane-airscan simple-scan
```

### Verify Scanner Detection
```bash
scanimage -L
# Shows:
# device `pixma:MX450_192.168.1.238' is a CANON Canon PIXMA MX450 Series
# device `airscan:w1:Canon MX450 series' is a WSD Canon MX450 series
```

### Command Line Scanning
```bash
# Scan to JPEG at 150dpi
scanimage -d 'pixma:MX450_192.168.1.238' --resolution 150 --format=jpeg -o scan.jpg

# Scan to PDF at 300dpi
scanimage -d 'pixma:MX450_192.168.1.238' --resolution 300 --format=pdf -o scan.pdf
```

### GUI Scanning
Run `simple-scan` for a graphical interface. The Canon MX450 appears automatically in the device list.
