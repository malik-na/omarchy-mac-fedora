#!/bin/bash

set -euo pipefail

ALLOW_SKIP=0

for arg in "$@"; do
  case "$arg" in
    --allow-skip)
      ALLOW_SKIP=1
      ;;
    *)
      echo "[FAIL] unknown argument: $arg"
      echo "Usage: $0 [--allow-skip]"
      exit 1
      ;;
  esac
done

skip_or_fail_env() {
  local message="$1"

  if (( ALLOW_SKIP )); then
    echo "[SKIP] $message"
    exit 0
  fi

  echo "[FAIL] $message"
  exit 1
}

echo "=== Fedora Asahi compatibility test ==="

[[ -f /etc/fedora-release ]] || {
  skip_or_fail_env "/etc/fedora-release not found"
}

[[ "$(uname -m)" == "aarch64" ]] || {
  skip_or_fail_env "expected aarch64, got $(uname -m)"
}

grep -qi asahi /proc/version || {
  skip_or_fail_env "Asahi kernel marker not found in /proc/version"
}

for cmd in dnf rpm dracut; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "[FAIL] required command not found: $cmd"
    exit 1
  }
done

echo "[OK] Fedora Asahi aarch64 environment looks compatible"
