#!/usr/bin/env bash
#
# Install or update the ML4W Dock
#

set -euo pipefail

REPO_URL="https://github.com/mylinuxforwork/ml4w-dock"
INSTALL_DIR="$HOME/.local/share/ml4w-dock"

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

echo ":: Start the dock with: qs -p $INSTALL_DIR"
