echo "Enable Walker file search and calculator (install qalculate + create qalc.cfg)"

if ! rpm -q libqalculate >/dev/null 2>&1; then
  sudo dnf install -y libqalculate qalculate
fi

mkdir -p ~/.config/qalculate
touch ~/.config/qalculate/qalc.cfg

systemctl --user restart elephant.service 2>/dev/null || true
pkill -f "walker --gapplication" 2>/dev/null || true
