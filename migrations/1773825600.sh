echo "Use symbols-based emoji picker flow (SUPER+CTRL+E -> omarchy-launch-walker -m symbols)"

BINDINGS_FILE="$HOME/.config/hypr/bindings.conf"
DEFAULT_BINDINGS_FILE="$HOME/.local/share/omarchy/default/hypr/bindings/utilities.conf"

# Migrate user override back to symbols provider flow.
if [[ -f "$BINDINGS_FILE" ]] && grep -q '^bindd = SUPER CTRL, E, Emoji picker, exec, omarchy-emoji-picker$' "$BINDINGS_FILE"; then
  sed -i 's|^bindd = SUPER CTRL, E, Emoji picker, exec, omarchy-emoji-picker$|bindd = SUPER CTRL, E, Emoji picker, exec, omarchy-launch-walker -m symbols|' "$BINDINGS_FILE"
fi

# Keep default bindings in sync for updated installs.
if [[ -f "$DEFAULT_BINDINGS_FILE" ]] && grep -q '^bindd = SUPER CTRL, E, Emoji picker, exec, omarchy-emoji-picker$' "$DEFAULT_BINDINGS_FILE"; then
  sed -i 's|^bindd = SUPER CTRL, E, Emoji picker, exec, omarchy-emoji-picker$|bindd = SUPER CTRL, E, Emoji picker, exec, omarchy-launch-walker -m symbols|' "$DEFAULT_BINDINGS_FILE"
fi

# Ensure symbols provider action copies to clipboard and pastes to active field.
mkdir -p "$HOME/.config/elephant"
cat >"$HOME/.config/elephant/symbols.toml" <<'EOF'
command = 'wl-copy && hyprctl dispatch sendshortcut "SHIFT, Insert,"'
EOF

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload >/dev/null 2>&1 || true
fi
