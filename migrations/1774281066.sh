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
  # Register elephant as a systemd user service if not already done
  if ! systemctl --user cat elephant.service >/dev/null 2>&1; then
    elephant service enable || true
  fi

  # Ensure ExecStart points to ~/.local/bin/elephant
  mkdir -p ~/.config/systemd/user/elephant.service.d
  if [[ ! -f ~/.config/systemd/user/elephant.service.d/20-exec.conf ]]; then
    cat >~/.config/systemd/user/elephant.service.d/20-exec.conf <<EOF
[Service]
ExecStart=
ExecStart=$HOME/.local/bin/elephant
EOF
  fi

  # Ensure PATH includes omarchy bin and ~/.local/bin
  if [[ ! -f ~/.config/systemd/user/elephant.service.d/30-path.conf ]]; then
    cat >~/.config/systemd/user/elephant.service.d/30-path.conf <<EOF
[Service]
Environment=PATH=$OMARCHY_PATH/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin
EOF
  fi

  omarchy-refresh-walker || true
fi
