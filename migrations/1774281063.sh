echo "Remove stale key binding overrides from user bindings.conf"

BINDINGS_CONF="$HOME/.config/hypr/bindings.conf"

# The correct bindings live in utilities.conf (sourced before bindings.conf).
# Any stale exec line in bindings.conf overrides them; remove the stale ones.
if [[ -f $BINDINGS_CONF ]]; then
  # SUPER+SPACE: fuzzel → omarchy-launch-walker
  if grep -q "SUPER, SPACE.*exec" "$BINDINGS_CONF" && \
     ! grep -q "SUPER, SPACE.*exec.*omarchy-launch-walker" "$BINDINGS_CONF"; then
    sed -i '/SUPER, SPACE.*exec/d' "$BINDINGS_CONF"
  fi

  # SUPER CTRL+SPACE: omarchy-theme-bg-next → omarchy-menu background
  if grep -q "SUPER CTRL, SPACE.*exec" "$BINDINGS_CONF" && \
     ! grep -q "SUPER CTRL, SPACE.*exec.*omarchy-menu background" "$BINDINGS_CONF"; then
    sed -i '/SUPER CTRL, SPACE.*exec/d' "$BINDINGS_CONF"
  fi

  # SUPER CTRL+E: omarchy-emoji-picker → omarchy-launch-walker -m symbols
  if grep -q "SUPER CTRL, E.*exec" "$BINDINGS_CONF" && \
     ! grep -q "SUPER CTRL, E.*exec.*omarchy-launch-walker" "$BINDINGS_CONF"; then
    sed -i '/SUPER CTRL, E.*exec/d' "$BINDINGS_CONF"
  fi
fi
