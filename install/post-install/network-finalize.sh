#!/bin/bash
# Finalize Fedora network backend at the end of installer flow.
# This is intentionally late to avoid dropping Wi-Fi during package/build steps.

OMARCHY_INSTALL="${OMARCHY_INSTALL:-$HOME/.local/share/omarchy/install}"
source "$OMARCHY_INSTALL/helpers/distro.sh"

if ! is_fedora; then
  exit 0
fi

ensure_iwd_backend() {
  local backend_conf="/etc/NetworkManager/conf.d/10-wifi-backend.conf"

  if ! command -v NetworkManager >/dev/null 2>&1 && ! rpm -q NetworkManager >/dev/null 2>&1; then
    echo "[WARN] NetworkManager is not installed; skipping iwd backend finalize"
    return 1
  fi

  if ! rpm -q iwd >/dev/null 2>&1; then
    echo "[INFO] Installing iwd backend package"
    sudo dnf install -y iwd || {
      echo "[WARN] Failed to install iwd"
      return 1
    }
  else
    echo "[OK] iwd already installed"
  fi

  sudo mkdir -p /etc/NetworkManager/conf.d
  if [[ ! -f "$backend_conf" ]] || ! grep -q '^\s*wifi\.backend\s*=\s*iwd\s*$' "$backend_conf"; then
    printf '[device]\nwifi.backend=iwd\n' | sudo tee "$backend_conf" >/dev/null || {
      echo "[WARN] Failed to write NetworkManager iwd backend config"
      return 1
    }
    echo "[OK] Set NetworkManager Wi-Fi backend to iwd"
  else
    echo "[OK] NetworkManager already configured with wifi.backend=iwd"
  fi

  sudo systemctl disable --now wpa_supplicant >/dev/null 2>&1 || true
  sudo systemctl enable --now iwd >/dev/null 2>&1 || {
    echo "[WARN] Failed to enable iwd service"
    return 1
  }
  sudo systemctl restart NetworkManager >/dev/null 2>&1 || {
    echo "[WARN] Failed to restart NetworkManager"
    return 1
  }

  echo "[OK] iwd backend finalized"
}

echo "[Omarchy/Fedora] Finalizing network backend at end of install..."
ensure_iwd_backend || echo "[WARN] Network backend finalize failed"
