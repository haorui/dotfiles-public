#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="https://github.com/haorui/dotfiles-public.git"
CONFIG_DIR="$HOME/.config"

# --- helpers ---
info()  { printf "\033[1;34m[info]\033[0m  %s\n" "$1"; }
ok()    { printf "\033[1;32m[ok]\033[0m    %s\n" "$1"; }
warn()  { printf "\033[1;33m[warn]\033[0m  %s\n" "$1"; }
error() { printf "\033[1;31m[error]\033[0m %s\n" "$1"; exit 1; }

command_exists() { command -v "$1" &>/dev/null; }

# --- install Homebrew ---
install_brew() {
  if command_exists brew; then
    ok "Homebrew already installed"
    return
  fi
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # add to PATH for this session
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

# --- install packages ---
install_packages() {
  local packages=(neovim tmux alacritty ripgrep fd node lazygit)
  local to_install=()

  for pkg in "${packages[@]}"; do
    if brew list "$pkg" &>/dev/null; then
      ok "$pkg already installed"
    else
      to_install+=("$pkg")
    fi
  done

  if [[ ${#to_install[@]} -gt 0 ]]; then
    info "Installing: ${to_install[*]}"
    brew install "${to_install[@]}"
  fi

  # prettierd via npm
  if command_exists prettierd; then
    ok "prettierd already installed"
  else
    info "Installing prettierd..."
    npm install -g @fsouza/prettierd
  fi
}

# --- install Nerd Font ---
install_font() {
  if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null; then
    ok "JetBrainsMono Nerd Font already installed"
    return
  fi
  info "Installing JetBrainsMono Nerd Font..."
  brew install --cask font-jetbrains-mono-nerd-font
}

# --- clone dotfiles ---
clone_dotfiles() {
  if [[ -d "$CONFIG_DIR/.git" ]]; then
    ok "Dotfiles repo already exists at $CONFIG_DIR"
    return
  fi

  info "Cloning dotfiles into $CONFIG_DIR..."
  # ~/.config likely exists, so init in place
  mkdir -p "$CONFIG_DIR"
  cd "$CONFIG_DIR"
  git init
  git remote add origin "$DOTFILES_REPO"
  git fetch origin
  git checkout -f main
  ok "Dotfiles cloned"
}

# --- alacritty themes ---
install_alacritty_themes() {
  local themes_dir="$CONFIG_DIR/alacritty/themes"
  if [[ -d "$themes_dir" ]]; then
    ok "Alacritty themes already installed"
    return
  fi
  info "Cloning Alacritty themes..."
  git clone https://github.com/alacritty/alacritty-theme "$themes_dir"
}

# --- main ---
main() {
  info "Setting up dotfiles..."
  echo

  install_brew
  install_packages
  install_font
  clone_dotfiles
  install_alacritty_themes

  echo
  ok "All done! Next steps:"
  echo "  1. Open tmux - plugins will auto-install on first launch"
  echo "  2. Open nvim - Lazy will auto-install plugins"
  echo "  3. Set Alacritty as default terminal (optional)"
}

main "$@"
