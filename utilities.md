# Utilities
Date: 2024-12-24

## Installed
```
htop-3.4.1_1         # Process viewer
lm_sensors-3.6.0_2   # Hardware monitoring
wget-1.25.0_1        # File downloader
7zip-25.01_1         # Archive tool
p7zip-25.01_1        # 7z compatibility wrapper
tree-2.2.1_1         # Directory listing
jq-1.8.1_1           # JSON processor
ripgrep-15.1.0_1     # Fast grep (rg)
fd-10.3.0_1          # Fast find
tcl-8.6.14_1         # TCL scripting language
tcl-devel-8.6.14_1   # TCL development files
tk-8.6.14_1          # TK GUI toolkit
tk-devel-8.6.14_1    # TK development files
tcllib-1.21_1        # TCL extensions library
critcl-3.3.1         # C Runtime In Tcl (manual install from GitHub)
Img-2.0.1            # Tk image formats (manual install from SourceForge)
xclip-0.13_2         # X11 clipboard CLI
xprop-1.2.8_1        # X11 property displayer (for wider)
wmctrl-1.07_6        # X11 window manager control (for wider)
xwininfo-1.1.6_1     # X11 window info (for wider)
portaudio-devel-190600.20161030_6  # Audio I/O library (for talkie)
peek-1.5.1_3         # Simple animated GIF/WebM/MP4 screen recorder
librsvg-utils-2.59.2_2  # SVG to PNG/PDF converter (rsvg-convert)
shotcut-25.03.29_1    # Video editor (Qt6, MLT framework)
noto-fonts-ttf-2025.12.01_1  # Unicode fonts with symbol coverage
noto-fonts-emoji-2.051_1  # Color emoji font
flatpak-1.16.1_1          # App sandboxing and distribution
netscanner-0.6.3_1        # Network scanner with TUI
vlc-3.0.23_2              # Media player
screen-5.0.1_1            # Terminal multiplexer (sessions)
tmux-3.6a_1               # Terminal multiplexer (modern)
scrot-1.12.1_1            # CLI screenshot utility
espeak-ng-1.52.0_1        # Text-to-speech engine
dialog-1.3.20251001_1     # CLI dialog boxes (menus, forms)
mosh-1.4.0_8              # Mobile shell (UDP, roaming, tolerates packet loss)
graphviz-14.1.4_1         # Graph visualization (dot, neato, fdp, etc.)
rpi-imager-1.8.5_1        # Raspberry Pi SD card imaging utility (GUI)
```

## Flatpak Apps
```
dev.vencord.Vesktop    # Discord client (lighter Electron, better Linux audio/screenshare)
```

### Flatpak Setup
```bash
sudo xbps-install -S flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

### Install Vesktop
Lighter, community Discord client (Vencord). Replaced the official Discord
flatpak to cut Electron memory use on this 16GB laptop.
```bash
flatpak install flathub dev.vencord.Vesktop
```

### Autostart Vesktop
Create `~/.config/autostart/vesktop.desktop` (set `Hidden=false` to enable):
```ini
[Desktop Entry]
Type=Application
Name=Vesktop
Exec=flatpak run dev.vencord.Vesktop
Hidden=true
NoDisplay=false
X-GNOME-Autostart-enabled=true
```

**Note:** Log out and back in after installing Flatpak for Vesktop to appear in the application menu.

## Pre-installed
```
rsync
curl
unzip
```

## Manual Installs

### critcl (C Runtime In Tcl)
```bash
git clone https://github.com/andreas-kupries/critcl.git /tmp/critcl
cd /tmp/critcl && sudo tclsh ./build.tcl install
rm -rf /tmp/critcl
```

### Img (Tk image formats)
Requires: `tcl-devel tk-devel`
```bash
sudo xbps-install -y tcl-devel tk-devel
cd /tmp && curl -L "https://sourceforge.net/projects/tkimg/files/tkimg/2.0/tkimg%202.0.1/Img-2.0.1.tar.gz/download" -o Img-2.0.1.tar.gz
tar xzf Img-2.0.1.tar.gz && cd Img-2.0.1
./configure --with-tcl=/usr/lib --with-tk=/usr/lib --prefix=/usr
make -j4 && sudo make install
sudo rm -rf /tmp/Img-2.0.1*
```

## Not Installed
- `neofetch` - deprecated, use `fastfetch` if needed
- `nmap` - not in Void repos, use `netscanner` or Zenmap flatpak

## Usage
```bash
htop                  # Interactive process viewer
sensors               # Show CPU/GPU temps
rg "pattern" .        # Fast recursive grep
fd "name"             # Fast file finder
jq '.key' file.json   # Parse JSON
7z x archive.7z       # Extract archive
tree -L 2             # Show directory tree
xclip -sel clip       # Copy stdin to clipboard
xclip -sel clip -o    # Paste from clipboard
peek                  # Screen recorder for GIFs/WebM/MP4 (Super+Shift+R)
rsvg-convert -w 256 in.svg -o out.png  # Convert SVG to PNG
shotcut               # Video editor for YouTube demos
flatpak run com.discordapp.Discord  # Launch Discord
flatpak update        # Update all flatpak apps
netscanner            # TUI network scanner (run as root for full features)
vlc video.mp4         # Play media file
screen -S name        # Start named session
tmux new -s name      # Start tmux session
scrot -s screenshot.png   # Screenshot selection
espeak-ng "Hello"     # Text-to-speech
dialog --msgbox "Hi" 10 30  # Display dialog box
mosh user@host             # Connect via mosh (requires mosh on server too)
dot -Tpng input.dot -o output.png  # Render dot graph to PNG
dot -Tsvg input.dot -o output.svg  # Render dot graph to SVG
rpi-imager                         # Write Raspberry Pi OS images to SD card
```

## Swap Configuration

Two-tier swap: **zram** (compressed RAM, preferred) backed by a 16GB disk
`/swapfile` (overflow). zram handles swap traffic in RAM at ~3:1 compression,
which is far faster than the disk file and avoids stutter on this 16GB laptop.

### zram (primary)
```bash
sudo xbps-install -S zramen
sudo ln -s /etc/sv/zramen /var/service/
```

Config at `/etc/sv/zramen/conf`:
```sh
export ZRAM_COMP_ALGORITHM=zstd   # good ratio/speed balance
export ZRAM_SIZE=50               # 50% of RAM
export ZRAM_MAX_SIZE=8192         # cap at 8GB
export ZRAM_PRIORITY=100          # used before the disk swapfile (-2)
```

### Disk swapfile (overflow)
16GB swap file at `/swapfile`, priority -2 (only used after zram fills).
```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=16384 status=progress
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Verify
```bash
swapon --show        # Show active swap (zram0 prio 100, swapfile prio -2)
zramctl              # Show zram device, algorithm, compression
free -h              # Show memory/swap usage
```

## Kernel Tuning

### Swappiness
Lowered from default 60 to 10 to keep pages in RAM/zram rather than eagerly
swapping. Persistent via `/etc/sysctl.d/99-swappiness.conf`:
```bash
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf
sudo sysctl -w vm.swappiness=10
```

## Removed Services (performance)

Disabled/uninstalled unused accessibility daemons:
- **espeakup** — console screen-reader speech (`sudo xbps-remove -R espeakup`)
- **brltty** — braille display daemon; also known to grab USB serial devices
  (interferes with Arduino `/dev/ttyACM*`). Service symlink removed from
  `/var/service/`.
