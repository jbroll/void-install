# Flashing Void Linux to Raspberry Pi 5

## Overview

This procedure downloads and flashes the official Void Linux aarch64 image to a USB/SD card for use with a Raspberry Pi 5.

## Requirements

- USB drive or SD card (8GB minimum, larger recommended)
- Target device: `/dev/sdX` (replace with your actual device)
- Tools: `wget`, `xzcat`, `dd`

## Step 1: Identify Target Device

**WARNING: Double-check the device name. Using the wrong device will destroy data.**

```bash
lsblk
```

Look for your USB/SD card by size. In this example, we use `/dev/sdd`.

## Step 2: Download the Image

Download the latest Void Linux RPi aarch64 image (glibc version):

```bash
cd /tmp
wget https://repo-default.voidlinux.org/live/current/void-rpi-aarch64-YYYYMMDD.img.xz
```

To find the current image filename:
```bash
curl -s https://repo-default.voidlinux.org/live/current/ | grep -oE 'void-rpi-aarch64-[0-9]+\.img\.xz' | head -1
```

For musl libc instead of glibc, use `void-rpi-aarch64-musl-YYYYMMDD.img.xz`.

## Step 3: Flash the Image

Decompress and write directly to the device:

```bash
xzcat void-rpi-aarch64-YYYYMMDD.img.xz | sudo dd of=/dev/sdX bs=4M status=progress oflag=sync
```

## Step 4: Sync and Eject

Ensure all data is written before removing the drive:

```bash
sync
sudo blockdev --flushbufs /dev/sdX
sudo eject /dev/sdX
```

## Step 5: Verify (Optional)

Before ejecting, you can verify the image:

```bash
# Check partition layout
lsblk /dev/sdX

# Check filesystem labels
sudo blkid /dev/sdX*

# Verify RPi 5 device tree exists
sudo mount /dev/sdX1 /mnt
ls /mnt/bcm2712-rpi-5-b.dtb
sudo umount /mnt
```

Expected partitions:
- `/dev/sdX1` - FAT32 boot partition (256MB)
- `/dev/sdX2` - ext4 root partition (auto-expands on first boot)

## Post-Boot Setup

### First Login

- Username: `root`
- Password: `voidlinux`

### Set the Clock

The Pi has no battery-backed RTC, so set the time before updating packages:

```bash
date -s "YYYY-MM-DD HH:MM:SS"
```

### Update the System

```bash
xbps-install -Su
```

### Install RPi 5 Optimized Kernel (Optional)

```bash
xbps-install rpi5-kernel
```

Note: The rpi5-kernel uses 16KB pages. Some software may have compatibility issues.

### Create a User

```bash
useradd -m -G wheel,audio,video,input username
passwd username
```

### Enable Sudo

```bash
xbps-install sudo
visudo  # Uncomment: %wheel ALL=(ALL) ALL
```

### Set Timezone

```bash
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
```

### Enable NTP

```bash
xbps-install chrony
ln -s /etc/sv/chronyd /var/service/
```

### Enable Wi-Fi and Bluetooth

```bash
xbps-install rpi-base
ln -s /etc/sv/dbus /var/service/
```

### Hardware Configuration

Edit `/boot/config.txt` for hardware options:

```bash
# Enable audio
dtparam=audio=on

# Enable I2C
dtparam=i2c_arm=on

# Enable SPI
dtparam=spi=on
```

## References

- [Void Linux Raspberry Pi Handbook](https://docs.voidlinux.org/installation/guides/arm-devices/raspberry-pi.html)
- [Void Linux Downloads](https://repo-default.voidlinux.org/live/current/)
- [Void Linux News - RPi 5 Support](https://voidlinux.org/news/2024/03/new-images.html)
