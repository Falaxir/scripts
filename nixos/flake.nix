{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    #nixpak = {
    #  url = "github:nixpak/nixpak";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations."falaxir-g5-5590" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # Nixpak Define the overlays
      #overlays = [
      #  (final: prev: {
      #    sandboxed-wine = import ./wine-sandboxed.nix {
      #      mkNixPak = nixpak.lib.nixpak {
      #        inherit (final) lib;
      #        inherit final;
      #      };
      #      pkgs = final;
      #    };
      #  })
      #];

      modules = [
        ./configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.falaxir = import ./home.nix;
        }

        # Reference `sandboxed-wine` in systemPackages
        #{
        #  environment.systemPackages = let
        #    pkgs = import nixpkgs {
        #      system = "x86_64-linux";
        #      overlays = self.overlays; # Add overlays here
        #    };
        #  in with pkgs; [
        #    sandboxed-wine
        #  ];
        #}
      ];
    };
  };
}

