# reminders 

Boot the NixOS installer, partition/mount to `/mnt` (the graphical installer is easiest), then:

```sh
nixos-generate-config --root /mnt
cp -r <this-repo> /mnt/etc/nixos-config
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos-config/hosts/helios/

# Check the GPU bus IDs match hosts/helios/nvidia.nix
lspci | grep -E 'VGA|3D'

# Set your time zone in configuration.nix, then:
cd /mnt/etc/nixos-config
git add hosts/helios/hardware-configuration.nix  
nixos-install --flake .#helios
nixos-enter --root /mnt -c 'passwd kayla'
```

After reboot: 
`sudo nixos-rebuild switch --flake /etc/nixos-config#helios
 nix flake update`.

## notes

- In the An Anime Game Launcher settings, add these environment variables:
 `__NV_PRIME_RENDER_OFFLOAD=1`, `__NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0`,
  `__GLX_VENDOR_LIBRARY_NAME=nvidia`, `__VK_LAYER_NV_optimus=NVIDIA_only`.
- `gamemoderun mangohud %command%` on the steam games. 
- defaults: `Super+Space` launcher, `Super+A` control center, `Super+Return` terminal,
  `Super+B` Zen, `Super+S` Steam, `Super+O` overview, `Super+Alt+L` lock,
  `Super+Shift+S` screenshot, `Super+Shift+C` keep-awake (for long games/cutscenes),
  `Super+Shift+/` cheat sheet.
- fans: `nbfc-linux` runs as a service with the PH315-53 profile (`hosts/helios/fans.nix`). `nbfc status`, `nbfc set -s 100`, `nbfc set -a`.
