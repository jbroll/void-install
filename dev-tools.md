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

## Not Yet Installed
- Node.js (install via nvm)
- Embedded toolchain (cross-arm-none-eabi-gcc)
- Rust/Cargo

## Notes
- LLVM 21 is bleeding edge (alternatives system manages versions)
- Python 3.14 is default in Void
