#!/bin/bash

is_btrfs_mount() {
  local mount_point="$1"
  [[ "$(findmnt -no FSTYPE "$mount_point" 2>/dev/null)" == "btrfs" ]]
}

has_snapper_config() {
  local config_name="$1"
  sudo snapper --csvout list-configs 2>/dev/null | awk -F, 'NR>1 {print $1}' | grep -qx "$config_name"
}

if ! command -v snapper >/dev/null 2>&1; then
  echo "[SKIP] snapper not installed"
  exit 0
fi

if ! is_btrfs_mount / || ! is_btrfs_mount /home; then
  echo "[SKIP] Btrfs root/home layout not detected; skipping snapper config"
  exit 0
fi

if ! has_snapper_config root; then
  echo "[INFO] Creating snapper config: root"
  sudo snapper -c root create-config / || {
    echo "[WARN] Failed to create root snapper config"
    exit 0
  }
fi

if ! has_snapper_config home; then
  echo "[INFO] Creating snapper config: home"
  sudo snapper -c home create-config /home || {
    echo "[WARN] Failed to create home snapper config"
    exit 0
  }
fi

echo "[INFO] Applying root retention policy"
sudo snapper -c root set-config \
  NUMBER_CLEANUP=yes \
  NUMBER_LIMIT=8 \
  NUMBER_LIMIT_IMPORTANT=6 \
  TIMELINE_CREATE=yes \
  TIMELINE_CLEANUP=yes \
  TIMELINE_LIMIT_HOURLY=6 \
  TIMELINE_LIMIT_DAILY=5 \
  TIMELINE_LIMIT_WEEKLY=3 \
  TIMELINE_LIMIT_MONTHLY=1 \
  TIMELINE_LIMIT_YEARLY=0 \
  EMPTY_PRE_POST_CLEANUP=yes || echo "[WARN] Failed to apply root retention"

echo "[INFO] Applying home retention policy"
sudo snapper -c home set-config \
  NUMBER_CLEANUP=no \
  NUMBER_LIMIT=0 \
  NUMBER_LIMIT_IMPORTANT=0 \
  TIMELINE_CREATE=yes \
  TIMELINE_CLEANUP=yes \
  TIMELINE_LIMIT_HOURLY=4 \
  TIMELINE_LIMIT_DAILY=5 \
  TIMELINE_LIMIT_WEEKLY=2 \
  TIMELINE_LIMIT_MONTHLY=1 \
  TIMELINE_LIMIT_YEARLY=0 \
  EMPTY_PRE_POST_CLEANUP=yes || echo "[WARN] Failed to apply home retention"

sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer || {
  echo "[WARN] Failed to enable snapper timers"
  exit 0
}

echo "[OK] Snapper root/home configuration complete"
