echo "Install hyprland-guiutils if available in Fedora repos"

if omarchy-cmd-missing dnf; then
  exit 0
fi

if omarchy-pkg-missing hyprland-guiutils; then
  omarchy-pkg-add hyprland-guiutils || true
fi
