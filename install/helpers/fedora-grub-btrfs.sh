#!/bin/bash

OMARCHY_INSTALL="${OMARCHY_INSTALL:-$HOME/.local/share/omarchy/install}"
source "$OMARCHY_INSTALL/helpers/distro.sh"

if ! is_fedora; then
  exit 0
fi

# Skip if already installed
if [[ -x /etc/grub.d/41_snapshots-btrfs ]]; then
  echo "[OK] grub-btrfs already installed, skipping"
  exit 0
fi

if ! command -v git >/dev/null 2>&1; then
  echo "[INFO] Installing git for grub-btrfs build"
  sudo dnf install -y git || {
    echo "[WARN] Failed to install git"
    exit 1
  }
fi

if ! command -v make >/dev/null 2>&1; then
  echo "[INFO] Installing make for grub-btrfs build"
  sudo dnf install -y make || {
    echo "[WARN] Failed to install make"
    exit 1
  }
fi

if ! rpm -q inotify-tools >/dev/null 2>&1; then
  echo "[INFO] Installing inotify-tools"
  sudo dnf install -y inotify-tools || {
    echo "[WARN] Failed to install inotify-tools"
    exit 1
  }
fi

tmpdir=$(mktemp -d /tmp/omarchy-grub-btrfs.XXXXXX)
trap 'rm -rf "$tmpdir"' EXIT

echo "[Omarchy/Fedora] Installing grub-btrfs from upstream..."
if ! git clone --depth=1 https://github.com/Antynea/grub-btrfs.git "$tmpdir/grub-btrfs"; then
  echo "[WARN] Failed to clone grub-btrfs"
  exit 1
fi

if ! (cd "$tmpdir/grub-btrfs" && sudo make GRUB_UPDATE_EXCLUDE=true install); then
  echo "[WARN] Failed to install grub-btrfs"
  exit 1
fi

config_file="/etc/default/grub-btrfs/config"
sudo mkdir -p /etc/default/grub-btrfs
sudo touch "$config_file"

set_config() {
  local key="$1"
  local value="$2"

  if sudo grep -q "^${key}=" "$config_file"; then
    sudo sed -i "s|^${key}=.*|${key}=${value}|" "$config_file"
  else
    echo "${key}=${value}" | sudo tee -a "$config_file" >/dev/null
  fi
}

mkconfig_lib="/usr/share/grub/grub-mkconfig_lib"
if [[ ! -f "$mkconfig_lib" && -f "/usr/share/grub2/grub-mkconfig_lib" ]]; then
  mkconfig_lib="/usr/share/grub2/grub-mkconfig_lib"
fi

set_config "GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS" '"rd.live.overlay.overlayfs=1"'
set_config "GRUB_BTRFS_GRUB_DIRNAME" '"/boot/grub2"'
set_config "GRUB_BTRFS_GBTRFS_DIRNAME" '"/boot/grub2"'
set_config "GRUB_BTRFS_MKCONFIG" '/usr/bin/grub2-mkconfig'
set_config "GRUB_BTRFS_SCRIPT_CHECK" 'grub2-script-check'
set_config "GRUB_BTRFS_MKCONFIG_LIB" "$mkconfig_lib"

echo "[OK] grub-btrfs installed and configured"
