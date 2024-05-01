{
  description = "My flake";

  # TODO: LSP
  # TODO: push extrakto to nixpkgs
  # TODO: sops

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";

    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";
    # nur.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    arkenfox.url = "github:dwarfmaster/arkenfox-nixos";
    arkenfox.inputs.nixpkgs.follows = "nixpkgs";

    base16.url = "github:SenchoPens/base16.nix";

    base16-zathura.url = "github:haozeke/base16-zathura";
    base16-zathura.flake = false;
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;

      systems = [ "x86_64-linux" "aarch64-linux" ];
      pkg-inputs = [ "nixpkgs" "nixpkgs-unstable" ];
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.nixpkgs.${system});
      pkgsFor = with lib; genAttrs pkg-inputs (pkg:
        genAttrs systems (system: import inputs.${pkg} {
          inherit system;
          config.allowUnfree = true;
        })
      );

      nixosConfig = { modules, system }:
        let
          specialArgs = {
            inherit inputs outputs;
            pkgs-unstable = pkgsFor.nixpkgs-unstable.${system};
          };
        in
        lib.nixosSystem {
          inherit specialArgs;
          pkgs = pkgsFor.nixpkgs.${system};

          modules = [
            outputs.nixosModules
            # Import home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                sharedModules = [ outputs.homeManagerModules ];
                extraSpecialArgs = specialArgs;
              };
            }
          ] ++ modules;
        };
    in
    {
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      overlays = import ./overlays { inherit inputs outputs; };
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });

      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);
      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });
      templates = import ./templates;


      nixosConfigurations = {
        uicom = nixosConfig {
          modules = [ ./hosts/uicom ];
          system = "x86_64-linux";
        };

        vm-imper-mini = nixosConfig {
          modules = [ ./hosts/vm-imper-mini ];
          system = "x86_64-linux";
        };
      };

      # homeConfigurations = { };
    };
}
