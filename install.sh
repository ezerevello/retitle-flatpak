#!/usr/bin/env bash

set -euo pipefail

BIN_DIR="$HOME/.local/bin"
SCRIPT_NAME="retitle-flatpak"
SCRIPT_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$SCRIPT_NAME"

# --- 1. install script ---
mkdir -p "$BIN_DIR"

if [[ ! -f "$SCRIPT_SRC" ]]; then
    echo "❌ Can't found '$SCRIPT_NAME' in the same dir of install.sh"
    exit 1
fi

cp "$SCRIPT_SRC" "$BIN_DIR/$SCRIPT_NAME"
chmod +x "$BIN_DIR/$SCRIPT_NAME"
echo "✅ $SCRIPT_NAME copied to $BIN_DIR"

# --- 2. verify if ~/.local/bin active PATH ---
if echo "$PATH" | tr ':' '\n' | grep -qx "$BIN_DIR"; then
    echo "✅ $BIN_DIR Already in PATH."
    echo ""
    echo "Can use: $SCRIPT_NAME <APP_ID> \"<title>\""
    exit 0
fi

echo "⚠️  $BIN_DIR isn't in the PATH. Scanning shell..."

# --- 3. detect shell and rc file ---
SHELL_NAME="$(basename "${SHELL:-}")"
RC_FILE=""

case "$SHELL_NAME" in
    zsh)  RC_FILE="$HOME/.zshrc" ;;
    bash) RC_FILE="$HOME/.bashrc" ;;
    fish)
        echo "🐟 Shell detected: fish"
        fish -c "fish_add_path $BIN_DIR"
        echo "✅ Added to fish_add_path"
        echo ""
        echo "Restart the terminal or execute: source ~/.config/fish/config.fish"
        echo "Then use: $SCRIPT_NAME <APP_ID> \"<title>\""
        exit 0
        ;;
    ksh)  RC_FILE="$HOME/.kshrc" ;;
    *)
        echo "⚠️  Shell '$SHELL_NAME' not recognized."
        read -rp "Add your config file path (e.g: ~/.bashrc): " RC_FILE
        RC_FILE="${RC_FILE/#\~/$HOME}"
        ;;
esac

EXPORT_LINE="export PATH=\"\$HOME/.local/bin:\$PATH\""

if grep -qF 'local/bin' "$RC_FILE" 2>/dev/null; then
    echo "⚠️  .local/bin reference already exists in $RC_FILE but isn't active in this sesion."
    echo "    You probable need restart the terminal or execute: source $RC_FILE"
else
    echo "" >> "$RC_FILE"
    echo "# added by retitle-flatpak install.sh" >> "$RC_FILE"
    echo "$EXPORT_LINE" >> "$RC_FILE"
    echo "✅ PATH updated in $RC_FILE"
fi

# --- 4. apply in actual session ---
export PATH="$BIN_DIR:$PATH"
echo "✅ PATH active in this session."
echo ""
echo "Restart the terminal or execute: source $RC_FILE"
echo "Then use: $SCRIPT_NAME <APP_ID> \"<title>\""
