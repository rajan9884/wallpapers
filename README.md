# wallpapers — wallpaper library (matugen-driven)

Collection: `Wallpaper/` — 319 curated images (jpg/png), no theme
subfolders. Consumers read them from a **flat** store:
`~/.local/share/wallpapers/*.jpg` (files only, no nesting).

## Use on any distro

```bash
git clone https://github.com/rajan9884/wallpapers.git ~/wallpapers
~/wallpapers/install.sh --flat            # copy every image flat into ~/.local/share/wallpapers
~/wallpapers/install.sh --flat --link     # symlink instead (live-update on git pull)
~/wallpapers/install.sh --flat --dest DIR # custom destination
```

Without `--flat` (legacy): installs `Wallpaper/` ->
`~/.local/share/wallpapers/Wallpaper`. Prefer `--flat` — pickers and
matugen configs read the top level.

## Use with dotfiles (Arch)

`dotfiles/install.sh` clones this repo to
`~/.local/share/wallpapers-upstream` and copies `Wallpaper/*` to
`~/.local/share/wallpapers/Wallpaper`. Override with
`WALLPAPER_SOURCE=/path/to/wallpapers ./install.sh`.

## Use with NixOS (nixos-config)

No flake input, no store bloat: `modules/home/wallpapers.nix`
flatten-copies every image under `~/wallpapers` (any depth) into
`~/.local/share/wallpapers/` on each rebuild. Re-sync manually after
`git pull` with `wallpapers-sync` (same logic, in `~/.local/bin`).

## Adding wallpapers

1. Drop files into `Wallpaper/` (jpg/jpeg/png/webp, flat — no subfolders).
2. Commit. Pickers (`wall-selector`, rofi, `swww-all.sh`) and matugen read
   `~/.local/share/wallpapers/` — no config change needed.
