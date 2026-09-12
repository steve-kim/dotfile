#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

detect_pkg() {
  if [[ "$OSTYPE" == "darwin"* ]]; then echo brew
  elif grep -qi microsoft /proc/version 2>/dev/null; then echo apt
  elif command -v apt &>/dev/null; then echo apt
  elif command -v dnf &>/dev/null; then echo dnf
  elif command -v pacman &>/dev/null; then echo pacman
  else echo unknown; fi
}

PKG=$(detect_pkg)

case "$PKG" in
  brew)
    command -v brew &>/dev/null || \
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install neovim tmux fzf tree-sitter ripgrep
    brew install --cask ghostty
    ;;
  apt)
    sudo apt update && sudo apt install -y neovim tmux fzf ripgrep alacritty
    command -v tree-sitter &>/dev/null || cargo install tree-sitter-cli
    ;;
  dnf)
    sudo dnf install -y neovim tmux fzf ripgrep alacritty
    command -v tree-sitter &>/dev/null || cargo install tree-sitter-cli
    ;;
  pacman)
    sudo pacman -S --noconfirm neovim tmux fzf ripgrep tree-sitter alacritty
    ;;
  *)
    echo "Unknown package manager — install neovim, tmux, fzf, ripgrep, tree-sitter, alacritty manually"
    ;;
esac

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  [[ -e "$dst" && ! -L "$dst" ]] && mv "$dst" "$dst.bak"
  ln -sfn "$src" "$dst"
}

link "$DOTFILES/nvim"                 "$HOME/.config/nvim"
link "$DOTFILES/tmux"                 "$HOME/.config/tmux"

# TPM (Tmux Plugin Manager) — must come after tmux symlink is created
if [[ ! -d "$HOME/.config/tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
fi

# Install TPM plugins non-interactively
if command -v tmux &>/dev/null; then
  "$HOME/.config/tmux/plugins/tpm/bin/install_plugins"
fi

# Link which-key config and build menu
if [[ -d "$HOME/.config/tmux/plugins/tmux-which-key" ]]; then
  ln -sfn "$DOTFILES/tmux/which-key.yaml" "$HOME/.config/tmux/plugins/tmux-which-key/config.yaml"
  bash "$HOME/.config/tmux/plugins/tmux-which-key/plugin.sh.tmux"
fi
link "$DOTFILES/bin/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"
link "$DOTFILES/bin/tmux-layout"      "$HOME/.local/bin/tmux-layout"

if [[ "$OSTYPE" == "darwin"* ]]; then
  link "$DOTFILES/terminal/ghostty" "$HOME/.config/ghostty"
else
  link "$DOTFILES/terminal/alacritty" "$HOME/.config/alacritty"
fi
chmod +x "$HOME/.local/bin/tmux-sessionizer"

echo ""
echo "Done. Next steps:"
echo "  1. Open nvim and run :Lazy sync"
echo "  2. Install LSP servers per project (rust-analyzer, clangd, pyright)"
echo "  3. Set SESSIONIZER_PATH in ~/.zshrc if your projects are not in ~/code"
