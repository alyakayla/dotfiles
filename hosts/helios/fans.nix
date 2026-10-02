# Fan control with nbfc-linux. nixpkgs has the package but no service module,
# so the systemd unit is defined here.
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.nbfc-linux ];

  environment.etc."nbfc/nbfc.json" = {
    mode = "0644";
    text = builtins.toJSON {
      SelectedConfigId = "Acer Predator PH315-53";
      # If `nbfc status` can't reach the embedded controller, uncomment:
      # EmbeddedControllerType = "dev_port";
    };
  };

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
