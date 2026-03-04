#!/bin/bash

set -euo pipefail

MODE="ci"
RUN_INSTALL=0

while (( $# > 0 )); do
  case "$1" in
    --ci)
      MODE="ci"
      ;;
    --device)
      MODE="device"
      ;;
    --run-install)
      RUN_INSTALL=1
      ;;
    --help)
      echo "Usage: $0 [--ci|--device] [--run-install]"
      echo
      echo "  --ci           Run non-destructive checks (default)."
      echo "  --device       Run strict Fedora Asahi checks and post-install validation commands."
      echo "  --run-install  In --device mode, run install.sh end-to-end with reboot prompt disabled."
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      echo "Use --help for usage."
      exit 1
      ;;
  esac
  shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMARCHY_PATH="$(cd "$SCRIPT_DIR/.." && pwd)"

pass() {
  echo "[PASS] $1"
}

section() {
  echo
  echo "== $1 =="
}

run() {
  local label="$1"
  shift
  echo "[RUN ] $label"
  "$@"
}

check_syntax() {
  section "Bash syntax checks"

  local -a all_scripts
  local -a scripts

  mapfile -t all_scripts < <(git -C "$OMARCHY_PATH" ls-files "*.sh")
  scripts=()

  local file
  for file in "${all_scripts[@]}"; do
    if [[ $file == migrations/* ]]; then
      continue
    fi
    scripts+=("$file")
  done

  if (( ${#scripts[@]} == 0 )); then
    echo "No shell scripts found."
    return
  fi

  for file in "${scripts[@]}"; do
    run "bash -n $file" bash -n "$OMARCHY_PATH/$file"
  done

  pass "All shell scripts passed bash -n"
}

check_forbidden_arch_assumptions() {
  section "Fedora runtime guardrails"

  local files=(
    "bin/omarchy-channel-set"
    "bin/omarchy-version-channel"
    "bin/omarchy-version-pkgs"
    "bin/omarchy-update-keyring"
  )

  local pattern='pacman|yay|paru|/etc/pacman|pacman\.log|pacman-key'

  if grep -En "$pattern" "${files[@]/#/$OMARCHY_PATH/}"; then
    echo "[FAIL] Found forbidden Arch runtime assumptions in hardened Fedora scripts"
    exit 1
  fi

  pass "No forbidden Arch runtime assumptions in hardened scripts"
}

check_environment() {
  section "Fedora Asahi environment check"

  if [[ $MODE == "ci" ]]; then
    run "compatibility test (allow skip)" bash "$OMARCHY_PATH/tests/test-fedora-asahi-compatibility.sh" --allow-skip
  else
    run "compatibility test (strict)" bash "$OMARCHY_PATH/tests/test-fedora-asahi-compatibility.sh"
  fi
}

run_device_install() {
  if (( ! RUN_INSTALL )); then
    return
  fi

  if [[ $MODE != "device" ]]; then
    echo "[FAIL] --run-install requires --device mode"
    exit 1
  fi

  section "End-to-end installer run"
  echo "This modifies the current system."
  echo "Repository path: $OMARCHY_PATH"

  run "install.sh with reboot prompt disabled" env OMARCHY_SKIP_REBOOT_PROMPT=1 bash "$OMARCHY_PATH/install.sh"
  pass "install.sh completed"
}

print_post_reboot_checklist() {
  if [[ $MODE != "device" ]]; then
    return
  fi

  section "Post-reboot validation checklist"
  cat <<'EOF'
Run these after reboot on the target machine:

  systemctl is-enabled sddm.service
  systemctl is-enabled omarchy-seamless-login.service
  journalctl -b -u sddm.service --no-pager -n 120
  bash -lc 'echo "$PATH"'
  bash -lc 'command -v omarchy-menu omarchy-cmd-terminal-cwd uwsm-app'

Functional checks in Hyprland session:
  SUPER+RETURN opens terminal
  launcher opens and starts apps
  Wi-Fi menu opens
  Bluetooth menu opens
  lock screen works
EOF
}

main() {
  section "Phase 3.1 test runner"
  echo "Mode: $MODE"
  echo "Repo: $OMARCHY_PATH"

  check_syntax
  check_forbidden_arch_assumptions
  check_environment
  run_device_install
  print_post_reboot_checklist

  section "Result"
  pass "Phase 3.1 checks completed"
}

main
