# OpenCode Setup
Date: 2026-02-01

## Overview

OpenCode is an open-source AI coding assistant for the terminal. This setup uses a remote Ollama instance running on a GPU host.

## Installation

```bash
npm install -g opencode-ai@latest
```

**Verify:**
```bash
opencode --version
```

## Ollama Server (GPU Host)

Ollama runs on the `gpu` host (192.168.1.169) with an RTX 4070 12GB.

**Service:** `/etc/sv/ollama/run`
```bash
#!/bin/sh
exec 2>&1
export OLLAMA_HOST=192.168.1.169:11434
export HOME=/home/john
cd /home/john
exec chpst -u john /usr/local/bin/ollama serve
```

**Check status:**
```bash
ssh gpu "sv status ollama"
ssh gpu "OLLAMA_HOST=192.168.1.169:11434 ollama list"
```

**Test connectivity:**
```bash
curl -s http://192.168.1.169:11434/api/tags | jq
```

## Installed Models

| Model | Size | Purpose | Tool Calling |
|-------|------|---------|--------------|
| qwen3:14b-32k | 9.3 GB | Reasoning + coding (32k context) | Yes |
| qwen3:14b | 9.3 GB | Base model (4k default context) | Limited |
| qwen2.5-coder:7b | 4.7 GB | Fast coding (92+ languages) | No |
| deepseek-coder-v2:16b | 8.9 GB | Complex tasks (300+ languages, MoE) | No |
| llama3.2:3b | 2.0 GB | Quick titles/summaries | No |

**Pull additional models:**
```bash
ssh gpu "OLLAMA_HOST=192.168.1.169:11434 ollama pull <model>"
```

## Configuration

**Config file:** `~/.config/opencode/config.json`

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (GPU)",
      "options": {
        "baseURL": "http://192.168.1.169:11434/v1"
      },
      "models": {
        "qwen3:14b-32k": {
          "name": "Qwen3 14B (32k ctx)",
          "tool_call": true,
          "limit": { "context": 32768, "output": 8192 }
        },
        "qwen2.5-coder:7b": {
          "name": "Qwen2.5 Coder 7B",
          "limit": { "context": 32768, "output": 8192 }
        },
        "deepseek-coder-v2:16b": {
          "name": "DeepSeek Coder V2 16B",
          "limit": { "context": 65536, "output": 8192 }
        },
        "llama3.2:3b": {
          "name": "Llama 3.2 3B",
          "limit": { "context": 8192, "output": 4096 }
        }
      }
    }
  },
  "model": "ollama/qwen3:14b-32k"
}
```

## Usage

**Start TUI:**
```bash
opencode
```

**Single query:**
```bash
opencode run "your prompt here"
```

**Use specific model:**
```bash
opencode -m ollama/qwen3:14b
```

**List available models:**
```bash
opencode models ollama
```

**Continue last session:**
```bash
opencode -c
```

## Key Bindings (TUI)

| Key | Action |
|-----|--------|
| `Ctrl+A` | Switch model/provider |
| `Tab` | Cycle agents (build/plan) |
| `Ctrl+X b` | Toggle sidebar |
| `Ctrl+X m` | Model list |
| `Ctrl+X l` | Session list |
| `Ctrl+X n` | New session |
| `Escape` | Interrupt generation |
| `Ctrl+C` | Exit |

## Tool Calling Fix

OpenCode sends extensive tool definitions (file operations, search, etc.) that can exceed Ollama's default 4096 token context window. This causes tools to be silently ignored.

**Solution:** Create a custom model with increased context:

```bash
# On GPU host
ssh gpu
cat > /tmp/Modelfile << 'EOF'
FROM qwen3:14b
PARAMETER num_ctx 32768
EOF

OLLAMA_HOST=192.168.1.169:11434 ollama create qwen3:14b-32k -f /tmp/Modelfile
```

The `qwen3:14b-32k` model has 32k context window and properly supports tool calling with OpenCode.

## Notes

- OpenCode uses `@ai-sdk/openai-compatible` to connect to Ollama's OpenAI-compatible API
- The `/v1` suffix on the baseURL is required for OpenAI compatibility
- Models are defined in config to set context/output limits (Ollama doesn't report these)
- Port 11434 is Ollama's default/well-known port
- **Critical**: Models need `num_ctx` >= 16384 for tool calling to work with OpenCode
