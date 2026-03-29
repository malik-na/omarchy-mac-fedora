echo "Normalize waybar launch path after hypr-autostart uwsm fix"

# Apply the new launch path immediately in the current session.
# This avoids carrying a pre-update direct-child waybar instance after update.
if command -v waybar >/dev/null 2>&1; then
  omarchy-restart-waybar >/dev/null 2>&1 || true
fi
