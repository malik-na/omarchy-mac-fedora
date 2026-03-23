echo "Replace fuzzel SUPER+SPACE launcher binding with omarchy-launch-walker"

BINDINGS_CONF="$HOME/.config/hypr/bindings.conf"

if [[ -f $BINDINGS_CONF ]] && grep -q "SUPER, SPACE.*fuzzel" "$BINDINGS_CONF"; then
  sed -i 's/bindd = SUPER, SPACE, Launch apps, exec, fuzzel/bindd = SUPER, SPACE, Launch apps, exec, omarchy-launch-walker/' "$BINDINGS_CONF"
fi
