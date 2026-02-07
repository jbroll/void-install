# mdview - Markdown Viewer

A lightweight Tcl/Tk markdown viewer using the thtmlview widget.

## Components

| Path | Description |
|------|-------------|
| `~/bin/mdview` | Launch script |
| `~/pkg/thtmlview/` | thtmlview widget (cloned from GitHub) |
| `~/pkg/tcl9-compat/` | Patched tcllib packages for Tcl 9 |
| `~/.local/share/applications/mdview.desktop` | Desktop entry |

## Dependencies

**System packages:**
```bash
sudo xbps-install -S tcllib tklib
```

**From source:**
```bash
git clone https://github.com/mittelmark/thtmlview ~/pkg/thtmlview
```

## Tcl 9 Compatibility

Void Linux ships Tcl 9.x, but tcllib packages require Tcl 8.x. The following packages are patched in `~/pkg/tcl9-compat/`:

- `snit2.tcl` - Snit object system
- `markdown.tcl` - Markdown to HTML converter
- `tabify.tcl` - Text tabification utilities
- `repeat.tcl` - String repeat utilities

Each patch removes the `package require Tcl 8.x` version check that fails with Tcl 9.

## Installation

1. Install system packages:
   ```bash
   sudo xbps-install -S tcllib tklib
   ```

2. Clone thtmlview:
   ```bash
   git clone https://github.com/mittelmark/thtmlview ~/pkg/thtmlview
   ```

3. Create patched tcllib packages:
   ```bash
   mkdir -p ~/pkg/tcl9-compat

   # Copy and patch snit2
   cp /usr/lib/tcllib1.21/snit/snit2.tcl ~/pkg/tcl9-compat/
   sed -i 's/package require Tcl 8.5/# Patched for Tcl 9/' ~/pkg/tcl9-compat/snit2.tcl

   # Copy and patch markdown
   cp /usr/lib/tcllib1.21/markdown/markdown.tcl ~/pkg/tcl9-compat/
   sed -i 's/package require Tcl 8.5/# Patched for Tcl 9/' ~/pkg/tcl9-compat/markdown.tcl

   # Copy and patch textutil
   cp /usr/lib/tcllib1.21/textutil/tabify.tcl ~/pkg/tcl9-compat/
   cp /usr/lib/tcllib1.21/textutil/repeat.tcl ~/pkg/tcl9-compat/
   sed -i 's/package require Tcl 8.2/# Patched for Tcl 9/' ~/pkg/tcl9-compat/tabify.tcl
   sed -i 's/package require Tcl 8.2/# Patched for Tcl 9/' ~/pkg/tcl9-compat/repeat.tcl
   sed -i 's/package require textutil::repeat/# Loaded by mdview/' ~/pkg/tcl9-compat/tabify.tcl
   ```

4. The launch script `~/bin/mdview` and desktop file are already in place.

5. Update desktop database:
   ```bash
   update-desktop-database ~/.local/share/applications/
   ```

## File Associations

Markdown files are associated via `~/.config/mimeapps.list`:

```ini
[Default Applications]
text/markdown=mdview.desktop
text/x-markdown=mdview.desktop
```

Double-clicking `.md` files in Thunar will open them in mdview.

## Usage

**Command line:**
```bash
mdview file.md
mdview file.html
```

**Keyboard shortcuts:**
| Key | Action |
|-----|--------|
| Ctrl+O | Open file |
| Ctrl+Q | Quit |

## Features

- Renders Markdown with heading styles, lists, code blocks, links
- Table support
- Navigation toolbar (back/forward/home)
- Search within document
- HTML file support
