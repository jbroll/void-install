# Ender 3 V2 on Klipper

Klipper, Moonraker and Mainsail on a Raspberry Pi Zero 2 W driving a Creality
Ender 3 V2. The printer is controlled from a browser; its own LCD no longer
works, which is expected once Marlin is replaced.

Open <http://ender3v2.local/>.

## Hardware

- **Host**: Raspberry Pi Zero 2 W, hostname `ender3v2`, Raspbian 13 (trixie)
- **Printer**: Ender 3 V2 with a Creality 4.2.7 board (STM32F103, 28 KiB
  bootloader, silent TMC drivers in standalone mode)
- **Probe**: CR Touch, offsets X -40.0, Y -5.0
- **Link**: CH340 USB serial bridge, USART1 at 250000 baud

## Documentation

| File | Description |
|------|-------------|
| [docs/quickstart.md](docs/quickstart.md) | First print, starting from a working install |
| [docs/install.md](docs/install.md) | Building the host from a blank SD card |
| [docs/user-manual.md](docs/user-manual.md) | Daily operation, calibration, rebuilding firmware |
| [docs/architecture.md](docs/architecture.md) | How the pieces fit and why |
| [docs/backlog.md](docs/backlog.md) | Outstanding work |

## Firmware currently flashed

| Field | Value |
|-------|-------|
| Filename | `fw0902a.bin` |
| Klipper commit | `f0892d8` |
| md5 | `9f14fe903e5d7ecb04f13845e3cbcab0` |
| Flashed | 2026-09-02 |

Each reflash needs a filename the bootloader has not seen before. Add a row here
when you flash.
