echo "Fix fastfetch OS age source to machine-id timestamp"

FASTFETCH_CONFIG="$HOME/.config/fastfetch/config.jsonc"

# Refresh only if user still has the old root-birth age formula.
if [[ -f "$FASTFETCH_CONFIG" ]] && grep -q 'stat -c %W /' "$FASTFETCH_CONFIG"; then
  omarchy-refresh-fastfetch
fi
