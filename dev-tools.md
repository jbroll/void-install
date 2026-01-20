# Development Tools
Date: 2024-12-24

## Installed Packages

### Core Tools
```
base-devel-20181003_2     # Build essentials meta-package
git-2.51.2_1              # Version control
git-filter-repo-2.34.0_5  # Git history rewriting
git-lfs-3.6.1_1           # Git Large File Storage
github-cli-2.83.2_1       # GitHub CLI (gh command)
cmake-4.1.2_1             # Build system generator
gdb-16.3_2                # Debugger
shellcheck-0.11.0_1       # Shell script linter
```

### LLVM/Clang Toolchain
```
clang-21_3                # C/C++/ObjC compiler
llvm-21_3                 # LLVM toolchain
clang-tools-extra-21_3    # clangd, clang-tidy, clang-format
```

**clangd** is the C/C++ language server for IDE features (completions, diagnostics, go-to-definition).

For clangd to understand your project, generate a `compile_commands.json`:
```bash
# CMake projects
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .

# Make projects (install Bear first)
sudo xbps-install -y Bear
bear -- make
```

### GCC Toolchain
```
gcc-14.2.1+20250405_4         # GNU C/C++ compiler
gcc-fortran-14.2.1+20250405_4 # GNU Fortran compiler
```

### Other Compilers
```
ldc-1.39.0_1              # D language compiler (LLVM-based)
```

### Python
```
python3-3.14.2_2          # Python interpreter
python3-pip-25.3_2        # Package installer
python3-devel-3.14.2_2    # Development headers
python3-setuptools-80.9.0_2  # Build tools
```

### Development Libraries
```
openblas-devel-0.3.30_1   # Optimized BLAS/LAPACK
sqlite-devel-3.50.4_1     # SQLite development files
cairo-devel-1.18.4_2      # 2D graphics library
libcurl-devel-8.17.0_1    # HTTP client library
gobject-introspection-1.86.0_2  # GObject introspection
```

## Verify Installation
```bash
git --version
cmake --version
clang --version
gcc --version
gdb --version
python3 --version
ldc2 --version
gh --version
shellcheck --version
```

### Arduino CLI
```
arduino-cli-1.4.0_1
```

**Setup:**
```bash
# Add user to dialout group for serial port access
sudo usermod -a -G dialout $USER
# Log out and back in for group change to take effect

# Initialize config and update core index
arduino-cli config init
arduino-cli core update-index
```

**Teensy boards (third-party):**
```bash
arduino-cli config add board_manager.additional_urls https://www.pjrc.com/teensy/package_teensy_index.json
arduino-cli core update-index
arduino-cli core install teensy:avr
```

**Other board cores:**
```bash
arduino-cli core install arduino:avr      # Uno, Mega, etc.
arduino-cli core install arduino:samd     # Zero, MKR boards
arduino-cli core install esp32:esp32      # ESP32 boards
```

### PlatformIO
```
platformio-6.1.18_2
python3.13-3.13.5_3       # Required by PlatformIO (not compatible with 3.14)
uv-1.2.2_1                # Fast Python package manager
```

**Install:**
```bash
sudo xbps-install -y platformio python3.13 uv
```

**Usage:**
```bash
pio init                  # Initialize project
pio run                   # Build project
pio run -t upload         # Upload to board
pio device list           # List connected devices
pio device monitor        # Serial monitor
```

**Serial monitor reset fix:**

Void Linux keeps stricter POSIX TTY defaults than Ubuntu. The `hupcl` (hang-up on close) setting causes DTR to be held low when opening serial ports, which holds MCU boards in reset state during `pio device monitor`.

A udev rule fixes this automatically:

```
/etc/udev/rules.d/99-serial-noreset.rules
```

```bash
# Disable HUPCL on CDC ACM devices to prevent DTR from holding MCUs in reset
KERNEL=="ttyACM*", ACTION=="add", RUN+="/bin/stty -F /dev/%k -hupcl"
```

Apply without reboot:
```bash
sudo udevadm control --reload
sudo udevadm trigger
```

Verify after plugging in a board:
```bash
stty -F /dev/ttyACM0 -a | grep hupcl
# Should show: -hupcl (with minus prefix)
```

### Rust (via rustup)
```
rustup (toolchain manager)
rustc (compiler)
cargo (package manager)
```

**Install:**
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

**Usage:**
```bash
rustup update                         # Update toolchain
rustup default stable                 # Use stable (default)
rustup default nightly                # Use nightly
rustup component add clippy rustfmt   # Add linter and formatter
```

### Node.js (via nvm)
```
nvm (Node Version Manager)
node v22.21.1
npm
```

**Install:**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install --lts
```

**Usage:**
```bash
nvm ls                    # List installed versions
nvm install <version>     # Install specific version
nvm use <version>         # Switch version
```

### LSP Servers

See [claude-code.md](claude-code.md) for Claude Code LSP configuration and installation.

### Container Tools
```
podman-5.6.1_1            # Docker-compatible container runtime
skopeo-1.16.0_3           # Container image inspection
crane-3.6.1_5             # Container registry tool
umoci-0.4.7_4             # OCI image manipulation
proot-5.2.0_1             # User-space chroot
```

**Usage:**
```bash
podman run -it alpine sh        # Run container
podman images                   # List images
skopeo inspect docker://alpine  # Inspect remote image
crane ls alpine                 # List tags
umoci unpack --image oci:img bundle  # Unpack OCI image
proot -r rootfs /bin/sh         # Chroot without root
```

## Notes
- LLVM 21 is bleeding edge (alternatives system manages versions)
- Python 3.14 is default in Void
- Container tools are rootless-capable (podman)
