# OneDrive Client Installation
Date: 2026-01-02

## Why build from source
The Void Linux repo has v2.4.25 which is obsolete and has broken web authentication. Building v2.5.9 from source fixes this.

## Install build dependencies
```bash
sudo xbps-install -S ldc libcurl-devel dbus-devel sqlite-devel
```

## Build from source
```bash
cd /tmp
curl -LO https://github.com/abraunegg/onedrive/archive/refs/tags/v2.5.9.tar.gz
tar xzf v2.5.9.tar.gz
cd onedrive-2.5.9
./configure
make
sudo make install
```

Installs to: `/usr/local/bin/onedrive`

## Authenticate
```bash
onedrive
```

This displays a URL. Open it in a browser, sign in to your Microsoft account, then copy the redirect URL from the address bar and paste it back into the terminal.

## Create runit service
```bash
sudo mkdir -p /etc/sv/onedrive

sudo tee /etc/sv/onedrive/run << 'EOF'
#!/bin/sh
export HOME=/home/john
exec chpst -u john /usr/local/bin/onedrive --monitor
EOF

sudo chmod +x /etc/sv/onedrive/run
```

## Enable service
```bash
sudo ln -s /etc/sv/onedrive /var/service/
```

## Verify
```bash
sudo sv status onedrive
```

## Notes
- Service runs as user `john` (change in run script if needed)
- `--monitor` mode watches for file changes and syncs continuously
- Default sync directory: `~/OneDrive`
- Config file: `~/.config/onedrive/config`
- Version installed: 2.5.9
