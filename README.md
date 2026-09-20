# wallpapers — flat wallpaper library (matugen-driven)

Single flat collection: `Wallpaper/` — 319 curated images (jpg/png),
no theme subfolders. Used as the matugen source by
[dotfiles](https://github.com/rajan9884/dotfiles), which installs it to
`~/.local/share/wallpapers/Wallpaper`.

## Use on any distro

```bash
git clone <your-remote>/wallpapers.git ~/wallpapers
~/wallpapers/install.sh            # installs Wallpaper/ -> ~/.local/share/wallpapers/Wallpaper
~/wallpapers/install.sh --link     # symlink instead of copy (live-update on git pull)
```

## Use with dotfiles (Arch)

`dotfiles/install.sh` clones this repo to
`~/.local/share/wallpapers-upstream` and copies `Wallpaper/*` to
`~/.local/share/wallpapers/Wallpaper`. Override with
`WALLPAPER_SOURCE=/path/to/wallpapers ./install.sh`.

## Use with NixOS

In `nixos-config/flake.nix`:

```nix
inputs.wallpapers.url = "path:../wallpapers";  # local checkout
# inputs.wallpapers.url = "github:rajan9884/wallpapers";  # after push
```

`modules/home/wallpapers.nix` links `Wallpaper/` to
`~/.local/share/wallpapers/Wallpaper`.

## Adding wallpapers

1. Drop files into `Wallpaper/` (jpg/jpeg/png/webp, flat — no subfolders).
2. Commit. Pickers (`wall-selector`, rofi, `swww-all.sh`) and matugen read
   `~/.local/share/wallpapers/Wallpaper/` — no config change needed.
