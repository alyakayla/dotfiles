{ config, pkgs, inputs, username, ... }:

{
  imports = [
    # Generated on the laptop by `nixos-generate-config`, copy it in before installing.
    ./hardware-configuration.nix
    ./nvidia.nix
    ./gaming.nix
    ./fans.nix
  ];

  # ---------------------------------------------------------------- Nix
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    # prebuilt binaries for Noctalia and An Anime Game Launcher
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://ezkea.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nixpkgs.config.allowUnfree = true;

  # ---------------------------------------------------------------- Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # Newest kernel for best hardware/gaming support. if the NVIDIA driver ever
  # fails to build against it, drop this line to fall back to the default LTS
  # kernel. `pkgs.linuxPackages_zen` is a gaming-tuned alternative.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ---------------------------------------------------------------- System
  networking.hostName = "helios";
  networking.networkmanager.enable = true;

  time.timeZone = "UTC"; # CHANGE ME
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.thermald.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.fwupd.enable = true;

  # audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ~ niri
  programs.niri.enable = true; # also sets up xdg-desktop-portal-gnome + session file

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd niri-session";
      user = "greeter";
    };
  };

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  # Noctalia's lock screen authenticates via the default `login` PAM service.

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Electron/Chromium apps run natively on Wayland
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  # ---------------------------------------------------------------- Users
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "gamemode" ];
    # Set a password after install with `passwd`, or uncomment:
    # initialPassword = "changeme";
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    pciutils
    usbutils
    htop
    btop
    nvtopPackages.full # GPU monitor (Intel + NVIDIA)
  ];

  # Keep this at the value the installer generated — do NOT bump it on upgrades.
  system.stateVersion = "26.05";
}
