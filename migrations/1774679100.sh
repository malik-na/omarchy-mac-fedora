echo "Install tmux on Fedora if missing"

if ! command -v tmux >/dev/null 2>&1; then
  omarchy-pkg-add tmux || true
fi
