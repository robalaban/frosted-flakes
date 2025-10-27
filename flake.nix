{
  description = "Frosted flakes, just add milk!";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      # Support both Intel and Apple Silicon Macs, plus Linux
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      templates = {
        rust = {
          path = ./rust;
          description = "A Rust development environment with cargo, rustc, clippy, and rustfmt";
        };
        node = {
          path = ./node;
          description = "A Node.js development environment with pnpm and development tools";
        };
        java = {
          path = ./java;
          description = "A Java 17 development environment with JDK and Gradle";
        };
        python = {
          path = ./python;
          description = "A Python development environment with uv package manager and common tools";
        };
        go = {
          path = ./go;
          description = "A Go development environment with the latest Go toolchain and development tools";
        };
      };

      # Add a convenient development shell for working on the templates themselves
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixpkgs-fmt
              nil # Nix language server
              direnv
              parallel # For running tests in parallel
            ];
            shellHook = ''
              echo "🥣 Welcome to Frosted Flakes development!"
              echo "Available templates: rust, node, java, python, go"
              echo "Use 'nix flake show' to see all available templates"
              echo ""
              echo "Run './scripts/test-all.sh' to test all templates locally"
            '';
          };
        });
    };
}

