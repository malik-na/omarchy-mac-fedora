#!/bin/bash

# Minimal dry-run shim: log potentially destructive commands and skip execution.
omarchy_dry_run() {
  printf '[DRY-RUN]'
  printf ' %q' "$@"
  printf '\n'
  return 0
}

sudo() {
  omarchy_dry_run sudo "$@"
}

dnf() {
  omarchy_dry_run dnf "$@"
}

flatpak() {
  omarchy_dry_run flatpak "$@"
}

cargo() {
  omarchy_dry_run cargo "$@"
}

systemctl() {
  omarchy_dry_run systemctl "$@"
}

reboot() {
  omarchy_dry_run reboot "$@"
}

shutdown() {
  omarchy_dry_run shutdown "$@"
}

loginctl() {
  omarchy_dry_run loginctl "$@"
}

omarchy-lazyvim-setup() {
  omarchy_dry_run omarchy-lazyvim-setup "$@"
}
