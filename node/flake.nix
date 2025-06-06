{
  description = "Node.js development environment";

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
          # Use the latest LTS Node.js version
          nodejs = pkgs.nodejs_22;
        in {
          packages = {
            default = nodejs;
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              # Node.js and package managers (pnpm as primary)
              nodejs
              nodePackages.pnpm
              yarn
              
              # Development tools
              nodePackages.typescript
              nodePackages.typescript-language-server
              nodePackages.eslint
              nodePackages.prettier
              nodePackages.nodemon
              
              # Build tools
              nodePackages.vite
              nodePackages.webpack-cli
            ];
            
            shellHook = ''
              echo "🟢 Node.js development environment activated!"
              echo "Node.js version: $(node --version)"
              echo "pnpm version: $(pnpm --version)"
              echo "Primary package manager: pnpm"
              echo "Available tools: pnpm, yarn, typescript, eslint, prettier"
              echo ""
              echo "Quick start:"
              echo "  pnpm init                # Initialize new project"
              echo "  pnpm add <package>       # Install dependencies"
              echo "  pnpm run dev             # Start development server"
              echo "  pnpm dlx create-vite     # Create Vite project"
            '';
          };

          apps = {
            default = {
              program = "${nodejs}/bin/node";
              type = "app";
            };
          };
        };
    };
}
