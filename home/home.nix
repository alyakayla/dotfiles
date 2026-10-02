{ pkgs, inputs, username, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  # ~ apps
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  programs.herdr.enable = true;

  # zed editor (launch with `zeditor`)
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" ];
    # nix language server + formatter, only on zed's PATH
    extraPackages = with pkgs; [ nixd nixfmt ];
  };

  home.packages = with pkgs; [
    inputs.spotifast.packages.${system}.spotifast # native Spotify client
    # spotify                                     # official client

    claude-code
    opencode

    # niri essentials (bar/launcher/notifications/lock/wallpaper come from noctalia)
    alacritty # terminal
    xwayland-satellite # X11 apps (Steam, many games) under niri
    wl-clipboard
    pavucontrol
    nautilus
  ];

  xdg.desktopEntries.notion = {
    name = "Notion";
    genericName = "Notes";
    exec = "${pkgs.writeShellScript "notion" ''
      exec ${pkgs.chromium}/bin/chromium --app=https://www.notion.so --class=notion \
        --user-data-dir="$HOME/.local/share/notion-app" "$@"
    ''}";
    icon = "notion";
    categories = [ "Office" ];
    terminal = false;
  };

  # ~ desktop
  xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;

  # Noctalia: bar, launcher, control center, notifications, lock screen,
  # idle, wallpaper, screenshots. Started as a systemd user service with niri.
  # Configure it from its settings window (Super+Comma); to manage it
  # declaratively instead, fill in `settings` (written to ~/.config/noctalia/config.toml).
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    # settings = { };
  };

  services.polkit-gnome.enable = true;

  home.pointerCursor = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    gtk.enable = true;
  };
}
