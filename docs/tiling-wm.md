# Tiling Window Manager Plan

Base system: Bazzite (Kinoite base), KDE Plasma 6, Wayland.

## Decision

Add tiling via a **KWin script** rather than a standalone/replacement tiling WM
(Sway, Hyprland, i3, etc). This keeps the existing Plasma/KWin session
(compositor effects, portals, notifications, Discover, System Settings, ...)
and adds dynamic tiling on top of it, with low risk and an easy on/off toggle.

Chosen script: **[Polonium](https://github.com/zeroxoneafour/polonium)**
(autotile manager for Plasma 6, Wayland-only, actively maintained).

Considered but not chosen:

- **Krohnkite** — mature dwm-style tiling, but the actively-maintained fork
  was archived on GitHub and moved to Codeberg (Dec 2025), making it more
  fragile to track from an automated image build.
- **Native Plasma tiling zones** (System Settings → Window Management →
  Tiling) — already available, zero maintenance, but not dynamic/automatic
  (new windows don't auto-insert into tiles). Good fallback if Polonium
  doesn't work out.
- **Standalone tiling WM as a separate login session** — more "authentic"
  tiling WM experience, but means maintaining a second, fully separate
  desktop config (portals, polkit agent, notifications, wallpaper, etc.)
  alongside Plasma.
- **Full replacement of Plasma with a tiling WM** — biggest commitment,
  loses KDE tooling (System Settings, Discover) unless rebuilt manually.

## Planned system-wide (image) install

Once the trial below has been validated, install Polonium system-wide by
adding a step to `build_files/build.sh`, following the same pattern already
used for `netbird`/`megasync` in that file:

1. Download the release asset from GitHub's stable "latest" redirect:
   `https://github.com/zeroxoneafour/polonium/releases/latest/download/polonium.kwinscript`
   (always resolves to the current latest tagged release — we chose to
   track latest rather than pin a version).
2. Install system-wide (for all users on the image) with:
   `kpackagetool6 -g -t KWin/Script -i polonium.kwinscript`
3. Optionally also fetch the `polonium-saver` release asset (a small DBus
   helper Polonium can use to persist tile layouts across logout/login) and
   install it to `/usr/bin/`.
4. No systemd unit is needed — KWin scripts are loaded by KWin itself, not
   run as a separate service.
5. Enabling the script and setting keybindings remains a **per-user**
   runtime choice (stored in `~/.config/kwinrc`) made through System
   Settings after the image is booted — this cannot and should not be
   forced at image-build time.
6. Verify with `just build` (and optionally `just build-qcow2` /
   `just spawn-vm`) before rebasing a real machine onto the new image.

## Note: user-level trial install (no image changes)

Before touching the image, Polonium was installed **for the local user
only**, to try it out live without any risk to the reproducible build:

```bash
# Download the prebuilt script package (no build tooling needed)
curl -sL -o /tmp/polonium.kwinscript \
  https://github.com/zeroxoneafour/polonium/releases/latest/download/polonium.kwinscript

# Install for the current user only (no -g flag)
# Installs into ~/.local/share/kwin/scripts/polonium
kpackagetool6 -t KWin/Script -i /tmp/polonium.kwinscript

# Enable it
kwriteconfig6 --file kwinrc --group Plugins --key poloniumEnabled true

# Ask KWin to reload its config live (a full logout/login may be needed
# for the script to fully activate)
qdbus6 org.kde.KWin /KWin reconfigure   # or: dbus-send --session --print-reply \
                                         #     --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure
```

Configure engine/layout options via System Settings → Window Management →
KWin Scripts → gear icon next to "Polonium", and set shortcuts via System
Settings → Shortcuts (search "Polonium").

To remove the trial install:

```bash
kwriteconfig6 --file kwinrc --group Plugins --key poloniumEnabled false
kpackagetool6 -t KWin/Script -r polonium
```

If the trial works out, follow the "Planned system-wide (image) install"
section above to bake it into `build_files/build.sh` for reproducibility
across rebuilds/rebases.
