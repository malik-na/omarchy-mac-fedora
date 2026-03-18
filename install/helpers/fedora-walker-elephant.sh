#!/bin/bash


OMARCHY_INSTALL="${OMARCHY_INSTALL:-$HOME/.local/share/omarchy/install}"
source "$OMARCHY_INSTALL/helpers/distro.sh"


if ! is_fedora; then
  exit 0
fi


ensure_local_bin_path() {
  local path_before=":$PATH:"
  mkdir -p "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
  if [[ "$path_before" != *":$HOME/.local/bin:"* ]]; then
    if [[ -f "$HOME/.bashrc" ]] && ! grep -q 'PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
      echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.bashrc"
    fi
  fi
}


command_exists_or_linked() {
  local bin="$1"
  command -v "$bin" >/dev/null 2>&1 || [[ -x "$HOME/.cargo/bin/$bin" ]]
}


install_pkg_if_available() {
  local pkg="$1"
  if command_exists_or_linked "$pkg"; then
    return 0
  fi


  if dnf list --available "$pkg" >/dev/null 2>&1; then
    sudo dnf install -y "$pkg" || return 1
  fi
}


link_cargo_bin() {
  local bin="$1"
  ensure_local_bin_path
  if [[ -x "$HOME/.cargo/bin/$bin" ]]; then
    ln -snf "$HOME/.cargo/bin/$bin" "$HOME/.local/bin/$bin"
  fi
}


install_walker_from_source() {
  local version_ref="$1"
  local src_dir
  src_dir="$(mktemp -d /tmp/omarchy-walker-src.XXXXXX)"


  if [[ "${OMARCHY_DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY-RUN] Would clone/build walker source and install to ~/.local/bin/walker"
    rm -rf "$src_dir"
    return 0
  fi


  if ! git clone --depth=1 https://github.com/abenz1267/walker.git "$src_dir"; then
    echo "[WARN] Failed to clone walker source"
    rm -rf "$src_dir"
    return 1
  fi


  if [[ -n "$version_ref" ]]; then
    if ! git -C "$src_dir" fetch --tags --force; then
      echo "[WARN] Failed to fetch walker tags for ref: $version_ref"
      rm -rf "$src_dir"
      return 1
    fi
    if ! git -C "$src_dir" checkout "$version_ref"; then
      echo "[WARN] Failed to checkout walker ref: $version_ref"
      rm -rf "$src_dir"
      return 1
    fi
  fi


  if ! (cd "$src_dir" && cargo build --release); then
    echo "[WARN] Failed to build walker from source"
    rm -rf "$src_dir"
    return 1
  fi


  if [[ ! -x "$src_dir/target/release/walker" ]]; then
    echo "[WARN] Walker build completed without target/release/walker"
    rm -rf "$src_dir"
    return 1
  fi


  ensure_local_bin_path
  install -m 755 "$src_dir/target/release/walker" "$HOME/.local/bin/walker"
  rm -rf "$src_dir"
  echo "[OK] Installed walker via source build"
  return 0
}


ensure_rust_toolchain() {
  if command -v cargo >/dev/null 2>&1 && command -v rustc >/dev/null 2>&1; then
    return 0
  fi
  sudo dnf install -y rust cargo
}


TEMP_BUILD_DEPS=()
install_temp_build_dep() {
  local pkg="$1"
  if rpm -q "$pkg" >/dev/null 2>&1; then
    return 0
  fi


  if sudo dnf install -y "$pkg"; then
    TEMP_BUILD_DEPS+=("$pkg")
    return 0
  fi


  return 1
}


cleanup_temp_build_deps() {
  if ((${#TEMP_BUILD_DEPS[@]} == 0)); then
    return 0
  fi


  echo "[INFO] Removing temporary walker/elephant build dependencies..."
  sudo dnf remove -y "${TEMP_BUILD_DEPS[@]}" || true
}


elephant_providers_present() {
  local providers_dir="$HOME/.config/elephant/providers"
  local providers=(
    providerlist
    desktopapplications
    calc
    menus
    clipboard
    symbols
    files
    websearch
    runner
  )


  local provider
  for provider in "${providers[@]}"; do
    [[ -f "$providers_dir/${provider}.so" ]] || return 1
  done


  return 0
}


install_elephant_go() {
  local version_ref="$1"
  local src_dir
  src_dir="$(mktemp -d /tmp/omarchy-elephant-src.XXXXXX)"


  local providers=(
    providerlist
    desktopapplications
    calc
    menus
    clipboard
    symbols
    files
    websearch
    runner
  )


  if [[ "${OMARCHY_DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY-RUN] Would clone/build elephant via Go and install providers to ~/.config/elephant/providers"
    rm -rf "$src_dir"
    return 0
  fi


  if ! git clone --depth=1 https://github.com/abenz1267/elephant.git "$src_dir"; then
    echo "[WARN] Failed to clone elephant source"
    rm -rf "$src_dir"
    return 1
  fi


  if [[ -n "$version_ref" ]]; then
    if ! git -C "$src_dir" fetch --tags --force; then
      echo "[WARN] Failed to fetch elephant tags for ref: $version_ref"
      rm -rf "$src_dir"
      return 1
    fi
    if ! git -C "$src_dir" checkout "$version_ref"; then
      echo "[WARN] Failed to checkout elephant ref: $version_ref"
      rm -rf "$src_dir"
      return 1
    fi
  fi


  ensure_local_bin_path
  mkdir -p "$HOME/.config/elephant/providers"


  if ! (cd "$src_dir/cmd/elephant" && go build -buildvcs=false -trimpath -o elephant); then
    echo "[WARN] Failed to build elephant binary"
    rm -rf "$src_dir"
    return 1
  fi
  install -m 755 "$src_dir/cmd/elephant/elephant" "$HOME/.local/bin/elephant"


  local provider
  for provider in "${providers[@]}"; do
    if ! (cd "$src_dir/internal/providers/$provider" && go build -buildvcs=false -buildmode=plugin -trimpath); then
      echo "[WARN] Failed to build elephant provider plugin: $provider"
      rm -rf "$src_dir"
      return 1
    fi
    install -m 755 "$src_dir/internal/providers/$provider/${provider}.so" "$HOME/.config/elephant/providers/${provider}.so"
  done


  rm -rf "$src_dir"
  echo "[OK] Installed elephant via Go with provider plugins"
  return 0
}


# Allow pinning via env if a known-good version is required in CI/release.
WALKER_VERSION="${OMARCHY_WALKER_VERSION:-}"
ELEPHANT_VERSION="${OMARCHY_ELEPHANT_VERSION:-}"


BUILD_DEPS=(
  gcc
  gcc-c++
  make
  cmake
  pkgconf-pkg-config
  cairo-devel
  poppler-glib-devel
  glib2-devel
  gtk4-devel
  gtk4-layer-shell-devel
  libxkbcommon-devel
  dbus-devel
  openssl-devel
  protobuf-compiler
  golang
  git
)


fail_walker_install() {
  local reason="$1"
  cleanup_temp_build_deps
  echo "[ERROR] Failed to install walker: $reason"
  echo "[ERROR] Next step: verify rust/cargo and GTK build deps, then rerun $OMARCHY_INSTALL/helpers/fedora-walker-elephant.sh"
  exit 1
}


# Package-first path.
install_pkg_if_available walker || true
install_pkg_if_available elephant || true


if command_exists_or_linked walker && command_exists_or_linked elephant && elephant_providers_present; then
  echo "[OK] Walker and Elephant (with providers) available via packages/path"
  link_cargo_bin walker
  exit 0
fi


# Build fallback path.
ensure_rust_toolchain || {
  fail_walker_install "Rust toolchain unavailable"
}


for dep in "${BUILD_DEPS[@]}"; do
  install_temp_build_dep "$dep" || echo "[WARN] Missing build dependency: $dep"
done


if ! command_exists_or_linked walker; then
  install_walker_from_source "$WALKER_VERSION" || fail_walker_install "source build failed"
fi


if ! command -v walker >/dev/null 2>&1; then
  fail_walker_install "walker binary missing from PATH"
fi


if ! walker --version >/dev/null 2>&1; then
  fail_walker_install "walker --version failed"
fi


echo "[OK] Walker verification passed: $(command -v walker)"


if ! command_exists_or_linked elephant || ! elephant_providers_present; then
  install_elephant_go "$ELEPHANT_VERSION" || true
fi


cleanup_temp_build_deps


echo "[Omarchy/Fedora] Walker + Elephant provisioning step completed."
