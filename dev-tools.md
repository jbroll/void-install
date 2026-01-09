# Development Tools
Date: 2024-12-24

## Installed Packages

### Core Tools
```
git (pre-installed)
cmake-4.1.2_1
gdb-16.3_2
```

### LLVM/Clang Toolchain
```
clang-21 (via clang21-21.1.7_1)
llvm-21 (via llvm21-21.1.7_1)
compiler-rt21-21.1.7_1
```

### Python
```
python3 (pre-installed, 3.14)
python3-pip
python3-devel
```

## Verify Installation
```bash
git --version
cmake --version
clang --version
gdb --version
python3 --version
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

### LSP Servers (for Claude Code)
```
typescript-language-server (TypeScript/JavaScript)
pyright (Python)
rust-analyzer (Rust, installed via rustup)
```

**Install:**
```bash
# TypeScript LSP
npm install -g typescript-language-server typescript

# Python LSP (via npm since Void uses externally-managed Python)
npm install -g pyright

# Rust LSP
rustup component add rust-analyzer
```

**Verify:**
```bash
which typescript-language-server pyright rust-analyzer
```

## Notes
- LLVM 21 is bleeding edge (alternatives system manages versions)
- Python 3.14 is default in Void
