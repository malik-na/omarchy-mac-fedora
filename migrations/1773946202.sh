echo "Install missing Yaru split theme packages on Fedora"

if ! command -v dnf >/dev/null 2>&1; then
  exit 0
fi

packages=(
  yaru-icon-theme
  yaru-gtk2-theme
  yaru-gtk3-theme
  yaru-gtk4-theme
  yaru-gtksourceview-theme
)

missing=()
for pkg in "${packages[@]}"; do
  if omarchy-pkg-missing "$pkg"; then
    missing+=("$pkg")
  fi
done

if (( ${#missing[@]} == 0 )); then
  echo "Yaru split theme packages already installed"
  exit 0
fi

omarchy-pkg-add "${missing[@]}"
