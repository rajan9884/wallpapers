#!/usr/bin/env bash
# install.sh — install the flat Wallpaper library to ~/.local/share/wallpapers.
# Usage: install.sh [--link] [--theme NAME] [--dest DIR]
# Default: installs Wallpaper/ -> $DEST/Wallpaper. --theme is kept for
# backward compat (e.g. --theme Wallpaper).
set -euo pipefail
MODE="copy"
THEME=""
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while [ $# -gt 0 ]; do
  case "$1" in
    --link) MODE="link"; shift ;;
    --theme) THEME="${2:?--theme needs a name}"; shift 2 ;;
    --dest) DEST="${2:?--dest needs a dir}"; shift 2 ;;
    -h|--help)
      echo "Usage: install.sh [--link] [--theme NAME] [--dest DIR]"
      exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

themes=()
if [ -n "$THEME" ]; then
  [ -d "$SRC_DIR/$THEME" ] || { echo "theme '$THEME' not found" >&2; exit 1; }
  themes=("$THEME")
else
  # Single flat library — every subdir is a collection (normally just Wallpaper/).
  for d in "$SRC_DIR"/*/; do
    d="$(basename "$d")"
    [ -d "$SRC_DIR/$d" ] && themes+=("$d")
  done
fi

mkdir -p "$DEST"
for t in "${themes[@]}"; do
  # skip files at repo root (README, install.sh) — only dirs count
  [ -d "$SRC_DIR/$t" ] || continue
  case "$t" in
    .git) continue ;;
  esac
  mkdir -p "$DEST/$t"
  if [ "$MODE" = link ]; then
    for f in "$SRC_DIR/$t"/*; do
      [ -e "$f" ] || continue
      ln -sf "$f" "$DEST/$t/$(basename "$f")"
    done
  else
    cp -a "$SRC_DIR/$t/." "$DEST/$t/"
  fi
  echo "installed $t -> $DEST/$t"
done
echo "done ($MODE -> $DEST)"
