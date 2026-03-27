echo "Install google-noto-color-emoji-fonts for color emoji rendering"

if omarchy-pkg-missing google-noto-color-emoji-fonts; then
  omarchy-pkg-add google-noto-color-emoji-fonts
fi
