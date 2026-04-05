#!/usr/bin/env bash
# Install qalculate (Walker calculator) and plocate (Walker file search) if missing

packages=()
rpm -q libqalculate >/dev/null 2>&1 || packages+=(libqalculate)
rpm -q qalculate >/dev/null 2>&1 || packages+=(qalculate)
rpm -q plocate >/dev/null 2>&1 || packages+=(plocate)

if ((${#packages[@]} > 0)); then
  sudo dnf install -y "${packages[@]}"
fi

mkdir -p ~/.config/qalculate
touch ~/.config/qalculate/qalc.cfg

if command -v updatedb >/dev/null 2>&1; then
  sudo updatedb || true
fi

# Restart elephant so calc/files providers pick up newly installed qalculate/plocate
systemctl --user restart elephant 2>/dev/null || true

# Refresh walker config (adds missing [[providers.prefixes]] for files provider) and restart
omarchy-refresh-config walker/config.toml
omarchy-restart-walker
