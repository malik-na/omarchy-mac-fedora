echo "Remove makima key remap integration from Fedora builds"

sudo systemctl disable --now makima 2>/dev/null || true
sudo rm -rf /etc/systemd/system/makima.service.d 2>/dev/null || true
rm -rf "$HOME/.config/makima" 2>/dev/null || true
omarchy-pkg-drop makima-bin || true
