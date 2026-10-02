{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true; # "Steam Big Picture" session option in the greeter
    extraCompatPackages = [ pkgs.proton-ge-bin ]; # GE-Proton shows up in Steam's compat list

    # Every game launched from Steam runs on the RTX 2060 automatically,
    # no need to add `nvidia-offload %command%` per game.
    package = pkgs.steam.override {
      extraEnv = {
        __NV_PRIME_RENDER_OFFLOAD = "1";
        __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __VK_LAYER_NV_optimus = "NVIDIA_only";
      };
    };
  };

  # Add `gamemoderun %command%` to a game's launch options for CPU governor boosts.
  programs.gamemode = {
    enable = true;
    settings.general.renice = 10;
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
    mangohud # FPS overlay: `mangohud %command%`
    protonplus # manage extra Proton/Wine versions
  ];
}
