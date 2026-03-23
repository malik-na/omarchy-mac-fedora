echo "Remove stale key binding overrides from user bindings.conf"

BINDINGS_CONF="$HOME/.config/hypr/bindings.conf"

# These bindings were previously shipped in the install template (config/hypr/bindings.conf)
# but now live exclusively in utilities.conf. Any copies in bindings.conf cause
# duplicate binds that override or conflict with the correct utilities.conf version.
# Remove them unconditionally — users who want to customise these can re-add them.
if [[ -f $BINDINGS_CONF ]]; then
  # SUPER+SPACE (was: omarchy-launch-walker in old template, now only in utilities.conf)
  sed -i '/SUPER, SPACE.*exec/d' "$BINDINGS_CONF"

  # SUPER ALT+SPACE (was: omarchy-menu in old template, now only in utilities.conf)
  sed -i '/SUPER ALT, SPACE.*exec.*omarchy-menu[^-]/d' "$BINDINGS_CONF"

  # SUPER CTRL+SPACE (was: omarchy-theme-bg-next, now omarchy-menu background in utilities.conf)
  sed -i '/SUPER CTRL, SPACE.*exec/d' "$BINDINGS_CONF"

  # SUPER CTRL+E (was: omarchy-emoji-picker, now omarchy-launch-walker -m symbols in utilities.conf)
  sed -i '/SUPER CTRL, E.*exec/d' "$BINDINGS_CONF"
fi
