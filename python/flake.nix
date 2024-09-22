{
  description = "A Python project using uv as the package manager";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, flake-parts }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" ];

      perSystem = { system, pkgs, ... }:
        {
          packages = {
            default = pkgs.python312.withPackages (ps: with ps; [
              pip
              virtualenv
              poetry
              numpy
              pandas
            ]);
          };
          devShells = {
            default = pkgs.mkShell {
              packages = with pkgs; [ python312 ];
            };
          };
        };
    };
}