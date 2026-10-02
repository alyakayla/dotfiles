# NixOS config — Predator Helios 300

```
flake.nix                      inputs (nixpkgs-unstable, home-manager, noctalia, zen, spotifast)
hosts/helios/configuration.nix system: boot, niri, greetd, audio, users
hosts/helios/nvidia.nix        Intel + RTX 2060 PRIME offload
hosts/helios/gaming.nix        Steam, Proton-GE, gamemode, gamescope, mangohud
home/home.nix                  user apps + Noctalia shell (home-manager)
home/niri/config.kdl           niri keybinds/layout
```

## Before installing (still on Windows)

1. **BIOS (F2 at boot):** set the SATA mode from *Optane without RAID* / *RST* to **AHCI**,
   otherwise the NVMe drive is invisible to Linux. If you're keeping Windows, first boot Windows
   into Safe Mode once (`bcdedit /set {current} safeboot minimal`), switch to AHCI, boot, then
   `bcdedit /deletevalue {current} safeboot`.
2. **Disable Secure Boot** (set a supervisor password first if the option is greyed out).
3. Copy this folder to a USB stick or push it to a git repo.

## Install

Boot the NixOS ISO, partition/mount to `/mnt` (the graphical installer is easiest), then:

```sh
nixos-generate-config --root /mnt
cp -r <this-repo> /mnt/etc/nixos-config
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos-config/hosts/helios/

# Check the GPU bus IDs match hosts/helios/nvidia.nix
lspci | grep -E 'VGA|3D'

# Set your time zone in configuration.nix, then:
cd /mnt/etc/nixos-config
git add hosts/helios/hardware-configuration.nix   # flakes only see git-tracked files
nixos-install --flake .#helios
nixos-enter --root /mnt -c 'passwd kayla'
```

After reboot: `sudo nixos-rebuild switch --flake /etc/nixos-config#helios`.
Update everything with `nix flake update` followed by that same rebuild.

## Notes

- **GPU:** the desktop runs on the Intel iGPU; Steam games run on the RTX 2060 automatically.
  To run anything else on the NVIDIA card: `nvidia-offload <program>`. Check with `nvtop`.
- **Steam launch options:** `gamemoderun mangohud %command%` gives CPU boost + FPS overlay.
- **Spotifast** comes from the community flake `tomsch/spotifast-nix` (it isn't in the NUR).
  To use the official client, swap it for `spotify` in `home/home.nix`.
- **Claude:** `claude-code` is the CLI. Anthropic ships no official Linux desktop app.
- **Notion:** Lotion is abandoned and not packaged for Nix, so "Notion" in the launcher opens
  notion.so as a standalone Chromium app window.
- **Shell:** Noctalia v5 provides the bar, launcher, notifications, lock screen, idle handling,
  wallpaper and screenshots, so there's no waybar/mako/fuzzel/swaylock. Change its look from
  its settings window (`Super+Comma`).
- **Keys:** `Super+Space` launcher, `Super+A` control center, `Super+Return` terminal,
  `Super+B` Zen, `Super+S` Steam, `Super+O` overview, `Super+Alt+L` lock,
  `Super+Shift+S` screenshot, `Super+Shift+C` keep-awake (for long games/cutscenes),
  `Super+Shift+/` cheat sheet.
- Fan/RGB control (PredatorSense) has no official Linux equivalent; look at `nbfc-linux` or
  the community `acer-predator-turbo` kernel module if you need it.
