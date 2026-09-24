#!/usr/bin/env bash
#
# Install or update the ML4W Dock
#

set -euo pipefail

REPO_URL="https://github.com/mylinuxforwork/ml4w-dock"
INSTALL_DIR="$HOME/.local/share/ml4w-dock"
BIN_DIR="$HOME/.local/bin"

if ! command -v git >/dev/null 2>&1; then
    echo ":: ERROR: git is required but not installed."
    exit 1
fi

if ! command -v qs >/dev/null 2>&1; then
    echo ":: WARNING: quickshell (qs) is not installed. The dock needs it to run."
fi

if [ -d "$INSTALL_DIR/.git" ]; then
    echo ":: Updating ml4w-dock in $INSTALL_DIR"
    git -C "$INSTALL_DIR" pull --ff-only
    echo ":: ml4w-dock updated successfully."
elif [ -d "$INSTALL_DIR" ]; then
    echo ":: ERROR: $INSTALL_DIR exists but is not a git repository."
    echo ":: Please remove or rename it and run this script again."
    exit 1
else
    echo ":: Cloning ml4w-dock into $INSTALL_DIR"
    mkdir -p "$(dirname "$INSTALL_DIR")"
    git clone "$REPO_URL" "$INSTALL_DIR"
    echo ":: ml4w-dock installed successfully."
fi

echo ":: Linking ml4w-dock into $BIN_DIR"
mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/bin/ml4w-dock" "$BIN_DIR/ml4w-dock"

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *)
        echo ":: WARNING: $BIN_DIR is not in your \$PATH."
        echo ":: Add it to your shell configuration, e.g. in ~/.bashrc or ~/.zshrc:"
        echo ":: export PATH=\"\$HOME/.local/bin:\$PATH\""
        ;;
esac

echo ":: Start the dock with: ml4w-dock"
