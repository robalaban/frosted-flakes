{
  description = "Java template";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" ];

      perSystem = { pkgs, lib, config, ... }:
        let
          inherit (inputs.self + "./" + ) package;
          javaVersion = 17;
          overlays = [
            (final: prev: rec {
              jdk = prev.jdk.override { version = "${toString javaVersion}"; };
              gradle = prev.gradle.override { java = jdk; };
            })
          ];
        in {
          devShells.default =
            pkgs.mkShell { packages = with pkgs; [ gradle jdk ]; };
        };
    };

}
