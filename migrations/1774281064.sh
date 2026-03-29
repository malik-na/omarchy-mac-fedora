echo "Update omarchy/hooks/theme-set waybar safety logic to use launch_waybar_once"

HOOK_FILE="$HOME/.config/omarchy/hooks/theme-set"

# Only update if file has old waybar dedup logic and is NOT the theme-hook version
if [[ -f $HOOK_FILE ]] && grep -q "pgrep -xc waybar" "$HOOK_FILE" && ! grep -q "theme-set\.d\|extract_color" "$HOOK_FILE"; then
  omarchy-refresh-config omarchy/hooks/theme-set
fi
