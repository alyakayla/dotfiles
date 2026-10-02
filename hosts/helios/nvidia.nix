# Optimus setup: Intel UHD 630 drives the desktop (cool + quiet, good battery),
# RTX 2060 Max-Q wakes up for games via PRIME render offload.
{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # needed for Steam / Proton / 32-bit games
    extraPackages = with pkgs; [
      intel-media-driver # VA-API video decode on the iGPU
    ];
  };

  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    # Turing (RTX 20xx) is supported by the open kernel modules.
    # If you get suspend/resume problems, set this to false.
    open = true;

    # Lets the dGPU fully power off when idle (RTD3, Turing+).
    powerManagement.enable = true;
    powerManagement.finegrained = true;

    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true; # provides `nvidia-offload <cmd>`

      # VERIFY on the laptop:  lspci | grep -E 'VGA|3D'
      #   00:02.0 VGA ... Intel   -> "PCI:0:2:0"
      #   01:00.0 VGA ... NVIDIA  -> "PCI:1:0:0"
      # (lspci shows hex; these values are decimal — convert if they differ)
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # niri + NVIDIA: stop the driver from hoarding VRAM in the compositor
  # (recommended by the niri wiki).
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
    builtins.toJSON {
      rules = [
        {
          pattern = { feature = "procname"; matches = "niri"; };
          profile = "Limit Free Buffer Pool On Wayland Compositors";
        }
      ];
      profiles = [
        {
          name = "Limit Free Buffer Pool On Wayland Compositors";
          settings = [ { key = "GLVidHeapReuseRatio"; value = 0; } ];
        }
      ];
    };
}
