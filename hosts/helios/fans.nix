# Fan control with nbfc-linux. nixpkgs has the package but no service module,
# so the systemd unit is defined here.
#
#   nbfc status        current temps / fan speeds
#   nbfc set -s 100    force fans to 100%
#   nbfc set -a        back to automatic
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.nbfc-linux ];

  # `mode` makes this a real, writable file instead of a read-only store
  # symlink, so `nbfc` commands can update it. Rebuilds reset it to this.
  environment.etc."nbfc/nbfc.json" = {
    mode = "0644";
    text = builtins.toJSON {
      SelectedConfigId = "Acer Predator PH315-53"; # Helios 300 (2020, RTX 2060)
      # If `nbfc status` can't reach the embedded controller, uncomment:
      # EmbeddedControllerType = "dev_port";
    };
  };

  # nbfc talks to the embedded controller through ec_sys and needs write access.
  boot.extraModprobeConfig = "options ec_sys write_support=1";

  systemd.services.nbfc_service = {
    description = "NoteBook FanControl service";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.kmod ]; # nbfc runs modprobe itself
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.nbfc-linux}/bin/nbfc_service --config-file /etc/nbfc/nbfc.json";
      Restart = "on-failure";
    };
  };
}
