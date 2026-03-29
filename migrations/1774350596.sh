echo "Remove stale waybar reload_style_on_change setting and restart cleanly on theme switch"

WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
changed=0

if [[ -f $WAYBAR_CONFIG ]] && grep -q '"reload_style_on_change": true,' "$WAYBAR_CONFIG"; then
  sed -i '/"reload_style_on_change": true,/d' "$WAYBAR_CONFIG"
  changed=1
fi

if [[ $changed -eq 1 ]]; then
  omarchy-restart-waybar >/dev/null 2>&1 || true
fi
