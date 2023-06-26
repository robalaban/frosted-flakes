{
  description = "Rust template";

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
        let inherit (lib.importTOML (inputs.self + "/Cargo.toml")) package;
        in {
          packages = {
            default = pkgs.rustPlatform.buildRustPackage {
              inherit (package) version;

              cargoLock.lockFile = (inputs.self + "/Cargo.lock");
              pname = package.name;
              src = inputs.self;
            };
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [ cargo rustc rustfmt rustup clippy ];
          };

          apps = {
            default = {
              program = "${config.packages.default}/bin/${package.name}";
              type = "app";
            };
          };
        };
    };
}
