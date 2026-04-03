# dotfiles

Personal configs for Neovim, tmux, and Alacritty on macOS.

## Quick Start

```bash
# one-liner: clone and install everything
bash <(curl -fsSL https://raw.githubusercontent.com/haorui/dotfiles-public/main/install.sh)
```

Or step by step:

```bash
cd ~/.config
git init && git remote add origin https://github.com/haorui/dotfiles-public.git
git fetch origin && git checkout -f main
./install.sh
```

## What's Included

| Tool | Config | Notes |
|------|--------|-------|
| **Neovim** | `nvim/` | AstroNvim v4+, Catppuccin theme, conform.nvim + prettierd |
| **tmux** | `tmux/` | Prefix `Ctrl+T`, Catppuccin, tmux-nvim navigation |
| **Alacritty** | `alacritty/` | JetBrainsMono Nerd Font, 50% opacity, dark_pride theme |

## Dependencies

Installed automatically by `install.sh`:

- [Homebrew](https://brew.sh)
- neovim, tmux, alacritty
- ripgrep, fd (telescope deps)
- node, prettierd (formatting)
- lazygit
- JetBrainsMono Nerd Font

## Key Bindings

### tmux

| Key | Action |
|-----|--------|
| `Ctrl+T` | Prefix |
| `Alt+w` | New window |
| `Alt+1-9` | Switch window |
| `Alt+h/l` | Prev/next window |
| `Alt+c` | Close pane |
| `Alt+m` | Zoom pane |
| `Ctrl+h/j/k/l` | Navigate panes (shared with nvim) |
| `prefix + g` | Lazygit popup |
| `prefix + I` | Install tmux plugins |

### Neovim

Standard AstroNvim keybindings. See `:Telescope keymaps` inside nvim.
