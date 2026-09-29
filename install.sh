#!/usr/bin/env bash
# install.sh — install the Wallpaper library to ~/.local/share/wallpapers.
# Usage: install.sh [--link] [--flat] [--theme NAME] [--dest DIR]
# Default: installs Wallpaper/ -> $DEST/Wallpaper. --theme is kept for
# backward compat (e.g. --theme Wallpaper).
# --flat: copy/link EVERY image (any depth, .git excluded) directly into
# $DEST with no subdirectories (same contract as nixos-config's
# wallpapers-sync). Colliding basenames get a parent-dir suffix.
set -euo pipefail
MODE="copy"
FLAT=0
THEME=""
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while [ $# -gt 0 ]; do
  case "$1" in
    --link) MODE="link"; shift ;;
    --flat) FLAT=1; shift ;;
    --theme) THEME="${2:?--theme needs a name}"; shift 2 ;;
    --dest) DEST="${2:?--dest needs a dir}"; shift 2 ;;
    -h|--help)
      echo "Usage: install.sh [--link] [--flat] [--theme NAME] [--dest DIR]"
      exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

# --flat installs a single file-only Dir, so --link with --flat links files.
if [ "$FLAT" -eq 1 ]; then
  [ -L "$DEST" ] && rm -f "$DEST"
  mkdir -p "$DEST"
  # drop stale nested dirs / links from previous non-flat installs
  # (the loop below recreates everything the flat store needs)
  find "$DEST" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} + 2>/dev/null || true
  find "$DEST" -mindepth 1 -maxdepth 1 -type l -exec rm -f {} + 2>/dev/null || true
  count=0
  while IFS= read -r -d '' src; do
    base="$(basename "$src")"
    dest="$DEST/$base"
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      # same content -> nothing to do (link or copy)
      if [ "$MODE" = link ] && [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        count=$((count + 1)); continue
      fi
      cmp -s "$src" "$dest" 2>/dev/null && { count=$((count + 1)); continue; }
      stem="${base%.*}"; ext="${base##*.}"
      if [ "$stem" = "$ext" ]; then ext=""; else ext=".$ext"; fi
      parent="$(basename "$(dirname "$src")")"
      dest="$DEST/${stem}_${parent}${ext}"
      n=1
      while { [ -e "$dest" ] || [ -L "$dest" ]; } && ! cmp -s "$src" "$dest" 2>/dev/null; do
        n=$((n + 1))
        dest="$DEST/${stem}_${parent}_${n}${ext}"
      done
      cmp -s "$src" "$dest" 2>/dev/null && { count=$((count + 1)); continue; }
    fi
    if [ "$MODE" = link ]; then ln -sf "$src" "$dest"; else cp -f "$src" "$dest"; fi
    count=$((count + 1))
  done < <(find "$SRC_DIR" -path "$SRC_DIR/.git" -prune -o -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0)
  echo "done ($MODE --flat: $count images -> $DEST)"
  exit 0
fi

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
