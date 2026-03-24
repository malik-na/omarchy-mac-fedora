echo "Refresh stale omarchy/hooks/theme-set to avoid first theme-switch waybar duplicate"

HOOK_FILE="$HOME/.config/omarchy/hooks/theme-set"

if [[ -f $HOOK_FILE ]] \
  && grep -q "launch_waybar_once" "$HOOK_FILE" \
  && grep -q "if ! pgrep -x waybar >/dev/null; then" "$HOOK_FILE" \
  && ! grep -q "sleep 1" "$HOOK_FILE"; then
  omarchy-refresh-config omarchy/hooks/theme-set
fi