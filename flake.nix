{
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      overlay = prev: _final: rec {
        erlang = prev.beam.interpreters.erlang_28;
        beamPackages = prev.beam.packagesWith erlang;
        elixir = beamPackages.elixir_1_19;
        inherit (beamPackages) hex;
      };

      forAllSystems =
        generate:
        nixpkgs.lib.genAttrs [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ] (
          system:
          generate {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ overlay ];
            };
          }
        );
    in
    {
      packages = forAllSystems (
        { pkgs, ... }:
        let
          src = pkgs.nix-gitignore.gitignoreSource [
            "/flake.nix"
            "/flake.lock"
            "/shell.nix"
            "/README.md"
            "/.git/"
          ] ./.;
          mixExs = builtins.readFile "${src}/mix.exs";
          pname = builtins.head (builtins.match ".*app:[[:space:]]*:([a-zA-Z0-9_]+).*" mixExs);
          version = builtins.head (
            builtins.match ".*version:[[:space:]]*\"([0-9]+\\.[0-9]+\\.[0-9]+)\".*" mixExs
          );

          mixNixDeps = pkgs.callPackages ./deps.nix { };
        in
        {
          default =
            with pkgs;
            beamPackages.mixRelease {
              inherit
                pname
                version
                src
                elixir
                ;
              inherit mixNixDeps;

              removeCookie = false;
            };
        }
      );

      devShells = forAllSystems (
        { pkgs, ... }:
        {
          default = self.devShells.${pkgs.stdenv.hostPlatform.system}.dev;
          dev = pkgs.callPackage ./shell.nix {
            mixEnv = "dev";
          };
          test = pkgs.callPackage ./shell.nix {
            mixEnv = "test";
          };
          prod = pkgs.callPackage ./shell.nix {
            mixEnv = "prod";
          };
        }
      );
    };
}
