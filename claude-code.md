# Claude Code Setup
Date: 2024-12-24

## Installation

Claude Code is Anthropic's official CLI for Claude AI.

**Install:**
```bash
npm install -g @anthropic-ai/claude-code
```

**Run:**
```bash
claude
```

## LSP Configuration

LSP servers provide real-time code intelligence (type errors, go-to-definition, completions).

**Settings file:** `~/.claude/settings.json`

```json
{
  "enabledPlugins": {
    "typescript-lsp@claude-plugins-official": true,
    "pyright-lsp@claude-plugins-official": true,
    "rust-lsp@claude-plugins-official": true,
    "clangd-lsp@claude-plugins-official": true
  }
}
```

## Required LSP Servers

| Plugin | Server | Install |
|--------|--------|---------|
| typescript-lsp | typescript-language-server | `npm install -g typescript-language-server typescript` |
| pyright-lsp | pyright | `npm install -g pyright` |
| rust-lsp | rust-analyzer | `rustup component add rust-analyzer` |
| clangd-lsp | clangd | `sudo xbps-install -S clang-tools-extra` |

**Install all:**
```bash
# TypeScript LSP
npm install -g typescript-language-server typescript

# Python LSP (via npm since Void uses externally-managed Python)
npm install -g pyright

# Rust LSP
rustup component add rust-analyzer

# C/C++ LSP
sudo xbps-install -S clang-tools-extra
```

**Verify:**
```bash
which typescript-language-server pyright rust-analyzer clangd
```

## Hooks Configuration

PostToolUse hooks run automatic lint/format checks after file edits.

**Hook script:** `~/.claude/hooks/post-tool-lint.sh`

**Behavior:**
- Finds project root by walking up directories looking for `package.json` or `Makefile`
- Runs linters based on file type with the following precedence:

| File Type | Precedence Order |
|-----------|------------------|
| `.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs` | 1. `npm run lint:fix` 2. `npm run lint` 3. `make lint` |
| `.sh`, `.bash` | `shellcheck` (no project required) |
| `.py` | 1. `npm run lint` 2. `ruff check` |

**Note:** Makefile `format` target is not currently used. To add formatting via Make,
add a `lint` target that runs both format and lint.

**Settings:** `~/.claude/settings.json`
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/post-tool-lint.sh",
            "timeout": 30,
            "statusMessage": "Running lint checks..."
          }
        ]
      }
    ]
  }
}
```

**Required tools:**
```bash
sudo xbps-install -y shellcheck
```

## Notes

- On Void Linux, use npm to install pyright since the system Python is externally managed (PEP 668)
- LSP servers require the corresponding language runtimes (Node.js, Rust) to be installed first
- clangd requires `compile_commands.json` for project awareness (see [dev-tools.md](dev-tools.md#llvmclang-toolchain))
