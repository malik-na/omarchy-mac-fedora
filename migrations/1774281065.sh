echo "Add #custom-omarchy font-size styling to waybar style.css"

WAYBAR_STYLE="$HOME/.config/waybar/style.css"

if [[ -f $WAYBAR_STYLE ]] && ! grep -q "#custom-omarchy {" "$WAYBAR_STYLE"; then
  printf '\n#custom-omarchy {\n  font-size: 13px;\n}\n' >> "$WAYBAR_STYLE"
fi
