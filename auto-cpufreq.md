# auto-cpufreq Installation
Date: 2024-12-24

## Install from source
```bash
cd /tmp
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq
sudo ./auto-cpufreq-installer --install
```

Installs to: `/usr/local/bin/auto-cpufreq` and `/opt/auto-cpufreq/`

## Create runit service
```bash
sudo mkdir -p /etc/sv/auto-cpufreq

sudo tee /etc/sv/auto-cpufreq/run << 'EOF'
#!/bin/sh
exec /usr/local/bin/auto-cpufreq --daemon
EOF

sudo chmod +x /etc/sv/auto-cpufreq/run
```

## Enable service
```bash
sudo ln -s /etc/sv/auto-cpufreq /etc/runit/runsvdir/default/auto-cpufreq
```

## Verify
```bash
sudo sv status auto-cpufreq
auto-cpufreq --stats  # (requires terminal)
```

## Notes
- Void Linux uses `/etc/runit/runsvdir/default/` for service symlinks (not `/var/service/`)
- Version installed: 2.6.0
