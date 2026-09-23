#!/usr/bin/env bash
#
# Uninstall the ML4W Dock
#

set -euo pipefail

INSTALL_DIR="$HOME/.local/share/ml4w-dock"
CONFIG_DIR="$HOME/.config/ml4w-dock"

if pgrep -f "qs -p $INSTALL_DIR" >/dev/null 2>&1; then
    echo ":: Stopping the running dock"
    pkill -f "qs -p $INSTALL_DIR" || true
fi

if [ -d "$INSTALL_DIR" ]; then
    echo ":: Removing $INSTALL_DIR"
    rm -rf "$INSTALL_DIR"
    echo ":: Done."
else
    echo ":: Nothing to do: $INSTALL_DIR does not exist."
fi

if [ -d "$CONFIG_DIR" ]; then
    echo ":: Your configuration in $CONFIG_DIR was kept. Remove it manually if you no longer need it."
fi
