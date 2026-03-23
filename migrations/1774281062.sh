echo "Remove fuzzel launcher (replaced by walker/elephant)"

if omarchy-cmd-missing dnf; then
  exit 0
fi

if omarchy-pkg-missing fuzzel; then
  exit 0
fi

sudo dnf remove -y fuzzel
