#!/usr/bin/env bash
# Install nautilus-python and deploy LocalSend extension for Nautilus context menu
# Also ensures LocalSend Flatpak is installed via Flathub

export OMARCHY_PATH="${OMARCHY_PATH:-$HOME/.local/share/omarchy}"

# Ensure Flathub remote is configured
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install LocalSend via Flatpak if missing
if ! command -v localsend &>/dev/null && ! flatpak info org.localsend.localsend_app &>/dev/null 2>&1; then
  flatpak install -y flathub org.localsend.localsend_app
fi

if ! rpm -q nautilus-python >/dev/null 2>&1; then
  sudo dnf install -y nautilus-python
fi

EXTENSIONS_DIR="$HOME/.local/share/nautilus-python/extensions"
mkdir -p "$EXTENSIONS_DIR"
cp "$OMARCHY_PATH/default/nautilus-python/extensions/localsend.py" "$EXTENSIONS_DIR/"

nautilus -q 2>/dev/null || true
