echo "Stabilize waybar theme-set hook to prevent first-session duplicate instances"

HOOK_FILE="$HOME/.config/omarchy/hooks/theme-set"

# Refresh only the standard theme-set hook variant, skip custom theme-hook implementations.
if [[ -f $HOOK_FILE ]] \
  && grep -q "launch_waybar_once" "$HOOK_FILE" \
  && ! grep -q "theme-set\.d\|extract_color" "$HOOK_FILE" \
  && ! grep -q "count=\$(pgrep -xc waybar" "$HOOK_FILE"; then
  omarchy-refresh-config omarchy/hooks/theme-set
fi
