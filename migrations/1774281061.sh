echo "Enable grub-btrfs snapshot entries in GRUB on Fedora Btrfs systems"

if omarchy-cmd-missing grub2-mkconfig; then
  exit 0
fi

if [[ ! -x /etc/grub.d/41_snapshots-btrfs ]]; then
  exit 0
fi

if omarchy-cmd-missing snapper; then
  exit 0
fi

if ! sudo snapper --csvout list-configs 2>/dev/null | awk -F, 'NR>1 {print $1}' | grep -qx "root"; then
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
