{
  inputs = {
    # gnuradio 3.7 has last been supported in nixos 21.11
    nixpkgs-2111.url = github:NixOS/nixpkgs/nixos-21.11;
    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.11;

    utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-2111, utils, ... }:
    utils.lib.eachSystem [ "x86_64-linux" ]
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pkgs-2111 = import nixpkgs-2111 {
            inherit system;
            config.permittedInsecurePackages = [
              "python2.7-Pillow-6.2.2"
              "python2.7-urllib3-1.26.2"
            ];
          };

          osmo-tetra = pkgs.callPackage ./pkgs/osmo-tetra.nix { };
          tetra-kit-decoder = pkgs.callPackage ./pkgs/tetra-kit-decoder.nix { };
          tetra-kit-recorder = pkgs.callPackage ./pkgs/tetra-kit-recorder.nix { };
          tetra-codec = pkgs.callPackage ./pkgs/tetra-codec.nix { };
        in
        rec {
          checks = packages;
          devShells = {
            osmo-tetra = import ./pkgs/shell-osmo-tetra.nix { pkgs = pkgs-2111; inherit osmo-tetra; };
            osmo-tetra-tmux = import ./pkgs/shell-osmo-tetra.nix { pkgs = pkgs-2111; inherit osmo-tetra; shellHook = true; };
            tetra-kit = import ./pkgs/shell-tetra-kit.nix { inherit pkgs; inherit tetra-kit-decoder; inherit tetra-kit-recorder;};
            tetra-kit-tmux = import ./pkgs/shell-tetra-kit.nix { inherit pkgs; inherit tetra-kit-decoder; inherit tetra-kit-recorder; shellHook = true; };
            speech-decode-notebook = import ./pkgs/shell-speech-decode-notebook.nix { inherit pkgs; inherit tetra-codec; };
          };
          packages = {
            osmo-tetra = osmo-tetra;
            tetra-kit-decoder = tetra-kit-decoder;
            tetra-kit-recorder = tetra-kit-recorder;
            tetra-codec = tetra-codec;
            default = osmo-tetra;
          };
        }
      ) // {
      overlays.default = final: prev: {
        inherit (self.packages."x86_64-linux")
        tetra-kit-decoder tetra-kit-recorder;
      };
      nixosModules = {
        tetra-kit = {
          imports = [
            ./nixos-modules/tetra-kit.nix
          ];

          nixpkgs.overlays = [
            self.overlays.default
          ];
        };
        default = self.nixosModules.tetra-kit;
      };
      hydraJobs =
        let
          hydraSystems = [ "x86_64-linux" ];
        in
        builtins.foldl'
          (hydraJobs: system:
            builtins.foldl'
              (hydraJobs: pkgName:
                nixpkgs.lib.recursiveUpdate hydraJobs {
                  ${pkgName}.${system} = self.packages.${system}.${pkgName};
                }
              )
              hydraJobs
              (builtins.attrNames self.packages.${system})
          )
          { }
          hydraSystems;
    };
}
