#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME="$(mktemp -d /tmp/omarchy-dry-run-home.XXXXXX)"

cleanup() {
  if [[ ${OMARCHY_DRY_RUN_KEEP_HOME:-0} != "1" ]]; then
    rm -rf "$TMP_HOME"
  else
    echo "[DRY-RUN] Keeping temp HOME at: $TMP_HOME"
  fi
}
trap cleanup EXIT

export HOME="$TMP_HOME"
export OMARCHY_PATH="$REPO_ROOT"
export OMARCHY_INSTALL="$REPO_ROOT/install"
export OMARCHY_DISTRO="${OMARCHY_DISTRO:-fedora}"
export OMARCHY_DRY_RUN=1
export OMARCHY_SKIP_REBOOT_PROMPT=1
export OMARCHY_INSTALL_LOG_FILE="${OMARCHY_INSTALL_LOG_FILE:-/tmp/omarchy-install-dry-run.log}"

mkdir -p "$HOME/.local/share"
ln -snf "$REPO_ROOT" "$HOME/.local/share/omarchy"

echo "[DRY-RUN] HOME=$HOME"
echo "[DRY-RUN] OMARCHY_PATH=$OMARCHY_PATH"
echo "[DRY-RUN] OMARCHY_INSTALL=$OMARCHY_INSTALL"
echo "[DRY-RUN] LOG=$OMARCHY_INSTALL_LOG_FILE"

bash "$REPO_ROOT/install.sh"
