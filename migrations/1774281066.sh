echo "Install walker and elephant from source on Fedora and set up configs"

if omarchy-cmd-missing dnf; then
  exit 0
fi

OMARCHY_PATH="${OMARCHY_PATH:-$HOME/.local/share/omarchy}"
OMARCHY_INSTALL="${OMARCHY_INSTALL:-$OMARCHY_PATH/install}"

elephant_providers_present() {
  local providers_dir="$HOME/.config/elephant/providers"
  for provider in providerlist desktopapplications calc menus clipboard symbols files websearch runner; do
    [[ -f "$providers_dir/${provider}.so" ]] || return 1
  done
  return 0
}

if omarchy-cmd-missing walker || omarchy-cmd-missing elephant || ! elephant_providers_present; then
  OMARCHY_INSTALL="$OMARCHY_INSTALL" bash "$OMARCHY_INSTALL/helpers/fedora-walker-elephant.sh" || {
    echo "Walker/elephant build failed — skipping config setup"
    exit 1
  }
fi

if omarchy-cmd-present walker && omarchy-cmd-present elephant; then
  omarchy-refresh-walker || true
fi
