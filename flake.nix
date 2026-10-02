{
  description = "NixOS — Acer Predator Helios 300 (i7-10750H + RTX 2060 Max-Q), niri, gaming";

  inputs = {
    # Unstable: newest NVIDIA drivers, Mesa, Proton, niri and app versions — best for gaming.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen Browser (not in nixpkgs)
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Noctalia v5 — the desktop shell (bar, launcher, notifications, lock screen, wallpaper)
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Spotifast — native Rust Spotify client (community flake, not in NUR/nixpkgs)
    spotifast.url = "github:tomsch/spotifast-nix";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      username = "kayla"; # CHANGE ME if you want a different login name
    in
    {
      nixosConfigurations.helios = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs username; };
        modules = [
          ./hosts/helios/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "bak";
              extraSpecialArgs = { inherit inputs username; };
              users.${username} = import ./home/home.nix;
            };
          }
        ];
      };
    };
}
