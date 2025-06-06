{
  description = "Rust development environment";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { pkgs, lib, config, ... }:
        let 
          # Check if Cargo.toml exists, otherwise provide a default package name
          package = if builtins.pathExists (inputs.self + "/Cargo.toml")
                   then (lib.importTOML (inputs.self + "/Cargo.toml")).package
                   else { name = "rust-project"; version = "0.1.0"; };
        in {
          packages = {
            default = pkgs.rustPlatform.buildRustPackage {
              inherit (package) version;
              pname = package.name;
              src = inputs.self;
              
              # Handle case where Cargo.lock might not exist yet
              cargoLock = if builtins.pathExists (inputs.self + "/Cargo.lock")
                         then { lockFile = (inputs.self + "/Cargo.lock"); }
                         else { lockFile = null; };
            };
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [ 
              # Core Rust toolchain
              cargo 
              rustc 
              rustfmt 
              clippy
              rust-analyzer
              
              # Additional development tools
              cargo-watch
              cargo-edit
              cargo-audit
              
              # System tools
              pkg-config
              openssl
            ];
            
            shellHook = ''
              echo "🦀 Rust development environment activated!"
              echo "Available tools: cargo, rustc, clippy, rustfmt, rust-analyzer"
              echo "Additional tools: cargo-watch, cargo-edit, cargo-audit"
            '';
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
