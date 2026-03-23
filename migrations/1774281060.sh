echo "Set up snapper configs, retention policy, timers, and install btrfs-assistant"

if omarchy-cmd-missing snapper; then
  exit 0
fi

if [[ "$(findmnt -no FSTYPE / 2>/dev/null)" != "btrfs" ]]; then
  exit 0
fi

has_snapper_config() {
  sudo snapper --csvout list-configs 2>/dev/null | awk -F, 'NR>1 {print $1}' | grep -qx "$1"
}

if ! has_snapper_config root; then
  sudo snapper -c root create-config / 2>/dev/null || true
fi

if [[ "$(findmnt -no FSTYPE /home 2>/dev/null)" == "btrfs" ]] && ! has_snapper_config home; then
  sudo snapper -c home create-config /home 2>/dev/null || true
fi

if has_snapper_config root; then
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
    EMPTY_PRE_POST_CLEANUP=yes
fi

if has_snapper_config home; then
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
    EMPTY_PRE_POST_CLEANUP=yes
fi

sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer 2>/dev/null || true

if omarchy-pkg-missing btrfs-assistant; then
  omarchy-pkg-add btrfs-assistant
fi
