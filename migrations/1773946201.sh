echo "Replace broken Waybar muted icon glyph"

config_file="$HOME/.config/waybar/config.jsonc"

if [[ -f $config_file ]]; then
  sed -i 's/"format-muted": ""/"format-muted": "󰖁"/' "$config_file"
  omarchy-restart-waybar >/dev/null 2>&1 || true
fi
