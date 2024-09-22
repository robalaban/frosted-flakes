{
  description = "A Python Flake using uv as the package manager";

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

      perSystem = { pkgs, ... }:
        let
          myPythonEnv = pkgs.python312.withPackages (ps: with ps; [
            numpy
            pandas
          ]);
        in
        {
          packages = {
            default = myPythonEnv;
          };
          devShells = {
            default = pkgs.mkShell {
              packages = [ myPythonEnv pkgs.uv pkgs.ruff ];
            };
          };
        };
    };
}