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
    utils.lib.eachDefaultSystem
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

          osmo-tetra = pkgs.callPackage ./osmo-tetra.nix { };
          tetra-kit-decoder = pkgs.callPackage ./tetra-kit-decoder.nix { };
          tetra-kit-recorder = pkgs.callPackage ./tetra-kit-recorder.nix { };
          tetra-codec = pkgs.callPackage ./tetra-codec.nix { };
        in
        rec {
          checks = packages;
          devShells = {
            osmo-tetra = import ./shell-osmo-tetra.nix { pkgs = pkgs-2111; inherit osmo-tetra; };
            osmo-tetra-tmux = import ./shell-osmo-tetra.nix { pkgs = pkgs-2111; inherit osmo-tetra; shellHook = true; };
            tetra-kit = import ./shell-tetra-kit.nix { inherit pkgs; inherit tetra-kit-decoder; inherit tetra-kit-recorder;};
            tetra-kit-tmux = import ./shell-tetra-kit.nix { inherit pkgs; inherit tetra-kit-decoder; inherit tetra-kit-recorder; shellHook = true; };
            speech-decode-notebook = import ./shell-speech-decode-notebook.nix { inherit pkgs; inherit tetra-codec; };
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
