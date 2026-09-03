# Install

Building the host from a blank SD card. This records what was actually done, so
it can be repeated after a card failure.

## Requirements

- Raspberry Pi Zero 2 W and a 16 GB or larger card
- A second SD card, 32 GB or smaller, for flashing printer firmware
- Micro-USB male to USB-A female adapter, plus the printer's USB cable
- Ender 3 V2 with a Creality 4.2.x board

## 1. Raspberry Pi OS

Write Raspberry Pi OS to the card. This install runs Raspbian 13 (trixie),
32-bit armv7l.

Configure the card before first boot. Either use Raspberry Pi Imager's
customization, or edit the card directly:

- `/boot/firmware/network-config` carries a netplan `wifis:` stanza for `wlan0`
  with the SSID, passphrase and `regulatory-domain: US`. This image runs
  cloud-init seeded from `/boot/firmware`, so cloud-init owns the network and a
  hand-placed NetworkManager profile alone is not enough.
- `/boot/firmware/meta-data` needs a fresh `instance_id` whenever you change
  `network-config`, otherwise cloud-init treats the boot as a repeat and skips
  network rendering.
- An empty file named `ssh` in `/boot/firmware` turns on sshd.
- `/etc/hostname` and `/etc/hosts` set to `ender3v2`.
- `~/.ssh/authorized_keys` for the user, mode 600.
- `/etc/systemd/journald.conf.d/` with `Storage=persistent`, so a failed boot
  leaves logs you can read from the card.

The last point matters. Without it the journal is volatile and a Pi that boots
but fails to join the network leaves nothing behind to diagnose.

## 2. USB host mode

The printer connects over USB, so the Pi's single data port must be a host, not
a peripheral. Leave `dwc2` alone. If `config.txt` contains
`dtoverlay=dwc2,dr_mode=peripheral` or `cmdline.txt` contains
`modules-load=dwc2,g_ether`, remove them and reboot.

Confirm with `lsusb`. A working host shows a root hub; with the printer on it
also shows `1a86:7523 QinHeng Electronics CH340 serial converter`.

## 3. System packages

```sh
sudo apt-get update
sudo apt-get install -y git build-essential python3-dev python3-venv \
  python3-virtualenv libffi-dev libncurses-dev libusb-1.0-0-dev pkg-config \
  gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi \
  libopenjp2-7 libsodium-dev zlib1g-dev libjpeg-dev libcurl4-openssl-dev \
  libssl-dev liblmdb-dev wireless-tools curl unzip nginx
```

The ARM toolchain is the bulk of the download and takes a while on a Zero 2 W.

## 4. Klipper

```sh
git clone --depth 200 https://github.com/Klipper3d/klipper.git ~/klipper
mkdir -p ~/printer_data/{config,logs,gcodes,comms,systemd}
python3 -m venv ~/klippy-env
~/klippy-env/bin/pip install --upgrade pip wheel
~/klippy-env/bin/pip install -r ~/klipper/scripts/klippy-requirements.txt
```

`greenlet` has no armv7 wheel and compiles from source.

`printer.cfg` goes in `~/printer_data/config/`. See
[architecture.md](architecture.md#printer-configuration) for what it contains.

`/etc/systemd/system/klipper.service`:

```ini
[Unit]
Description=Klipper 3D Printer Firmware host
After=network-online.target
Wants=udev.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
User=john
WorkingDirectory=/home/john/klipper
ExecStart=/home/john/klippy-env/bin/python /home/john/klipper/klippy/klippy.py /home/john/printer_data/config/printer.cfg -I /home/john/printer_data/comms/klippy.serial -l /home/john/printer_data/logs/klippy.log -a /home/john/printer_data/comms/klippy.sock
Restart=always
RestartSec=10
```

## 5. Moonraker

```sh
git clone --depth 200 https://github.com/Arksine/moonraker.git ~/moonraker
python3 -m venv ~/moonraker-env
~/moonraker-env/bin/pip install --upgrade pip wheel
~/moonraker-env/bin/pip install -r ~/moonraker/scripts/moonraker-requirements.txt
```

`moonraker.conf` goes in `~/printer_data/config/`. It binds to 127.0.0.1:7125
and lists trusted client ranges.

`trusted_clients` must include the LAN's IPv6 prefix, not only the IPv4 ranges.
Browsers and `curl` will reach `ender3v2.local` over IPv6 when the network
offers it, and Moonraker answers 401 for a source address it does not recognise.
The prefix is delegated by the ISP and will stop matching if it rotates.

`/etc/systemd/system/moonraker.service`:

```ini
[Unit]
Description=API Server for Klipper SV1
Requires=network-online.target
After=network-online.target klipper.service

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
User=john
WorkingDirectory=/home/john/moonraker
ExecStart=/home/john/moonraker-env/bin/python /home/john/moonraker/moonraker/moonraker.py -d /home/john/printer_data
Restart=always
RestartSec=10
```

## 6. Mainsail

```sh
git clone https://github.com/mainsail-crew/mainsail-config.git ~/mainsail-config
ln -sf ~/mainsail-config/mainsail.cfg ~/printer_data/config/mainsail.cfg
mkdir -p ~/mainsail && cd ~/mainsail
curl -fsSL -o mainsail.zip \
  https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip
unzip -o -q mainsail.zip && rm mainsail.zip
chmod 755 /home/john
```

The `chmod` is required. nginx runs as `www-data` and cannot traverse a home
directory with mode 700.

The nginx site lives at `/etc/nginx/sites-available/mainsail`, symlinked into
`sites-enabled`, with the stock `default` site removed. It serves `~/mainsail`
and proxies `/websocket`, `/printer`, `/api`, `/access`, `/machine` and
`/server` to 127.0.0.1:7125. `gzip` is off deliberately: on this CPU
compression costs more than the LAN bandwidth it saves.

The API location sets `proxy_read_timeout 3600`. Without it nginx returns 504
after 60 seconds on `PID_CALIBRATE` and `BED_MESH_CALIBRATE`, which run for
minutes. Klipper carries on regardless, so the 504 is misleading rather than
fatal, but it leaves you without the result.

## 7. Printer firmware

See [user-manual.md](user-manual.md#rebuilding-and-flashing-firmware).

## Upgrade

Moonraker's update manager handles Klipper, Moonraker, Mainsail and
mainsail-config from Mainsail's Machine tab. It cannot install system packages
or restart services until Moonraker's `set-policykit-rules.sh` has been run,
which is deliberately not done here. See [backlog.md](backlog.md).

Updating Klipper's host code does not reflash the MCU. When a Klipper update
changes the MCU protocol version, Mainsail reports a version mismatch and the
firmware has to be rebuilt and reflashed.
