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
flowblade-2.16.3_1    # Non-linear video editor (GTK, MLT framework)
```

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
flowblade             # Video editor for YouTube demos
```

## Swap Configuration

16GB swap file configured at `/swapfile`.

### Setup Commands
```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=16384 status=progress
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Verify
```bash
swapon --show        # Show active swap
free -h              # Show memory/swap usage
```
