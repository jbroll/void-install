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

### Hardware video acceleration (VAAPI)
```bash
sudo xbps-install -S libva-utils
vainfo   # should show "Intel iHD driver" + H264/HEVC/VP9 entrypoints
```
Confirmed working: Intel iHD driver, H.264 / HEVC (8 & 10-bit) / VP9 decode + encode.

**Firefox:** check `about:support` (Media → look for `HW_DECODE`). If video isn't
hardware-decoded, set `media.ffmpeg.vaapi.enabled = true` in `about:config`.
Hardware decode cuts CPU and battery use significantly on video playback.

## Notes
- Void package names differ from Ubuntu:
  - `intel-ucode` → included in `linux-firmware-intel`
  - `firmware-sof-signed` → `sof-firmware`

## Known Issues

### iwlwifi firmware crash (Intel WiFi, Meteor Lake)
Kernel log occasionally shows the WiFi adapter hit a fatal firmware error and
self-reset:
```
iwlwifi 0000:00:14.3: Device error - SW reset
iwlwifi 0000:00:14.3: Not valid error log pointer ... for RT uCode
```
`linux-firmware` is already at the latest packaged version, so the fix path is
running the newest kernel (driver). If crashes/drops persist after a kernel
update + reboot, try a module option as a fallback:
```bash
echo 'options iwlwifi power_save=0' | sudo tee /etc/modprobe.d/iwlwifi.conf
# reboot to apply
```

### i915 "Atomic update failure on pipe A"
Benign missed-vblank warnings in dmesg; related to the Intel graphics resume
quirks already worked around in suspend.md. No action needed.
