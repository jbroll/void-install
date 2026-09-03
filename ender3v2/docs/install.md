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

## 7. Firewall

`/etc/nftables.conf` accepts traffic from the LAN and drops everything else,
loaded at boot by `nftables.service`. The router already drops unsolicited
inbound IPv6; this is the second layer, so a change in router policy does not
put Mainsail on the internet.

```
chain input {
    type filter hook input priority filter; policy drop;
    ct state established,related accept
    ct state invalid drop
    iif lo accept
    ip protocol icmp accept
    ip6 nexthdr ipv6-icmp accept
    ip saddr 192.168.1.0/24 accept
    ip6 saddr fe80::/10 accept
    ip6 saddr <ISP prefix>::/64 accept
}
```

ICMP and ICMPv6 are accepted without a source match because neighbour discovery
and router advertisement arrive that way, and filtering them by source breaks
IPv6 address configuration.

Apply it behind a timed revert, or a bad rule locks you out of a machine you can
only reach over the network:

```sh
sudo nft -c -f /etc/nftables.conf
sudo systemd-run --on-active=120 --unit=nft-revert /usr/sbin/nft flush ruleset
sudo nft -f /etc/nftables.conf
# verify with a NEW ssh session, not the one already open: an established
# connection survives a ruleset that would refuse a fresh one
sudo systemctl stop nft-revert.timer
sudo systemctl enable --now nftables
```

The ISP-delegated IPv6 prefix appears here as well as in `moonraker.conf`. If it
rotates, both need updating.

## 8. Accelerometer for input shaping

The ADXL345 hangs off the Pi's SPI0, which means Klipper needs a second MCU
process running on the Pi itself to reach the bus.

Enable SPI by uncommenting `dtparam=spi=on` in `/boot/firmware/config.txt` and
rebooting. `/dev/spidev0.0` should appear.

Build the Linux MCU with its own config file so the printer's STM32 build is not
overwritten:

```sh
cd ~/klipper
echo CONFIG_MACH_LINUX=y > config.linux
make KCONFIG_CONFIG=config.linux OUT=out-linux/ olddefconfig
make KCONFIG_CONFIG=config.linux OUT=out-linux/
sudo install -m 755 out-linux/klipper.elf /usr/local/bin/klipper_mcu
sudo install -m 644 scripts/klipper-mcu.service /etc/systemd/system/
sudo systemctl enable --now klipper-mcu
```

The service creates `/tmp/klipper_host_mcu` and is ordered before
`klipper.service`.

Resonance analysis needs numpy in the Klipper venv:

```sh
~/klippy-env/bin/pip install numpy
sudo apt-get install -y libopenblas0
```

piwheels supplies a prebuilt armv7 wheel, so this is a download rather than a
half-hour compile. The `libopenblas0` package is not optional: without it the
wheel imports and fails with `libopenblas.so.0: cannot open shared object file`.

`adxl345.cfg` holds the `[mcu rpi]`, `[adxl345]` and `[resonance_tester]`
sections. `printer.cfg` carries its include commented out, because Klipper
refuses to start when the sensor is configured but absent. Uncomment it after
wiring.

## 9. Workstation

Slicing happens on the laptop, not the Pi. Void packages no slicer, so
OrcaSlicer comes from Flathub:

```sh
sudo flatpak install -y flathub com.orcaslicer.OrcaSlicer
```

It uploads g-code to Moonraker directly and generates its own calibration
prints. Klipper also ships test models in `~/klipper/docs/prints/`, including
`ringing_tower.stl` and `square.stl`.

## 10. Printer firmware

See [user-manual.md](user-manual.md#rebuilding-and-flashing-firmware).

## Upgrade

Moonraker's update manager handles Klipper, Moonraker, Mainsail and
mainsail-config from Mainsail's Machine tab. It cannot install system packages
or restart services until Moonraker's `set-policykit-rules.sh` has been run,
which is deliberately not done here. See [backlog.md](backlog.md).

Updating Klipper's host code does not reflash the MCU. When a Klipper update
changes the MCU protocol version, Mainsail reports a version mismatch and the
firmware has to be rebuilt and reflashed.
