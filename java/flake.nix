{
  description = "Java template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ];
      perSystem = { pkgs, lib, config, ... }:
        let
          javaVersion = 17;
          overlays = [
            (final: prev: rec {
              jdk = prev.jdk.override { version = "${toString javaVersion}"; };
              gradle = prev.gradle.override { java = jdk; };
            })
          ];
        in {
          packages = {
            src = self;
          };
          devShells.default =
            pkgs.mkShell { packages = with pkgs; [ gradle jdk ]; };
        };
    };
}
