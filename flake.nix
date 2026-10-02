{
  description = "~ kayla's nixos config. specs: Acer Predator Helios 300 (i7-10750H + RTX 2060 Max-Q), niri, gaming";

  inputs = {
    
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11"; 

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

    # noctalia, the desktop shell (bar, launcher, notifications, lock screen, wallpaper)
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # native Rust Spotify client (community flake)
    #spotifast.url = "github:tomsch/spotifast-nix";

    # anime game launcher
    aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    aagl.inputs.nixpkgs.follows = "nixpkgs";
  };       
   

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      username = "kayla"; # change your username here
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
