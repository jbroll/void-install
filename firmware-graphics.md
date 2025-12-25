# Firmware & Graphics Installation
Date: 2024-12-24

## Firmware
```bash
sudo xbps-install -Sy linux-firmware linux-firmware-intel sof-firmware
```

Installed:
- linux-firmware-20251111_1
- linux-firmware-intel (already present)
- sof-firmware-2025.05_1
- alsa-ucm-conf-1.2.14_1

## Graphics (Intel Arc - Meteor Lake)
```bash
sudo xbps-install -Sy mesa mesa-dri mesa-vulkan-intel mesa-vaapi intel-media-driver vulkan-loader
```

Installed:
- mesa, mesa-dri, vulkan-loader (already present)
- mesa-vulkan-intel-25.1.9_1
- mesa-vaapi-25.1.9_1
- intel-gmmlib-22.8.1_1
- intel-media-driver-25.2.6_1

## Verification
```bash
lspci | grep VGA
# 0000:00:02.0 VGA compatible controller: Intel Corporation Meteor Lake-P [Intel Arc Graphics] (rev 08)
```

## Notes
- Void package names differ from Ubuntu:
  - `intel-ucode` → included in `linux-firmware-intel`
  - `firmware-sof-signed` → `sof-firmware`
