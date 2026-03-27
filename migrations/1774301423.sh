echo "Ensure grub-btrfs is installed and GRUB snapshot entries are generated"

if omarchy-cmd-missing grub2-mkconfig; then
  exit 0
fi

if [[ "$(findmnt -no FSTYPE / 2>/dev/null)" != "btrfs" ]]; then
  exit 0
fi

if omarchy-cmd-missing snapper; then
  exit 0
fi

# Install grub-btrfs if missing (in case previous migration failed)
if ! sudo test -x /etc/grub.d/41_snapshots-btrfs 2>/dev/null; then
  OMARCHY_PATH="${OMARCHY_PATH:-$HOME/.local/share/omarchy}"
  if ! bash "$OMARCHY_PATH/install/helpers/fedora-grub-btrfs.sh"; then
    echo "grub-btrfs install failed — retry omarchy-update from a desktop terminal with sudo access"
    exit 1
  fi
fi

if ! sudo test -x /etc/grub.d/41_snapshots-btrfs 2>/dev/null; then
  exit 0
fi

if ! sudo snapper --csvout list-configs 2>/dev/null | awk -F, 'NR>1 {print $1}' | grep -qx "root"; then
  exit 0
fi

# Check if snapshot entries already exist
if sudo grep -q "grub-btrfs.cfg" /boot/grub2/grub.cfg 2>/dev/null; then
  exit 0
fi

snapshot_count=$(sudo snapper -c root list --csvout 2>/dev/null | awk -F, 'NR>1' | wc -l)
if (( snapshot_count == 0 )); then
  sudo snapper -c root create --description "omarchy update bootstrap snapshot" --cleanup-algorithm number
fi

sudo /etc/grub.d/41_snapshots-btrfs

if [[ -d /boot/grub2 ]]; then
  sudo grub2-mkconfig -o /boot/grub2/grub.cfg
fi

if systemctl list-unit-files 2>/dev/null | grep -q "^grub-btrfsd\.service"; then
  sudo systemctl enable --now grub-btrfsd 2>/dev/null || true
fi
