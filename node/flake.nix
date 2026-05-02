{
  description = "Node.js development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { pkgs, lib, config, ... }:
        let
          # Use the latest LTS Node.js version
          nodejs = pkgs.nodejs_22;
        in
        {
          packages = {
            default = nodejs;
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              # Node.js and pnpm
              nodejs
              pnpm

              # Development tools
              typescript
              typescript-language-server
              eslint
              prettier
              nodemon
            ];

            shellHook = ''
              echo "🟢 Node.js development environment activated!"
              echo "Node.js version: $(node --version)"
              echo "pnpm version: $(pnpm --version)"
              echo "Package manager: pnpm"
              echo "Available tools: pnpm, typescript, eslint, prettier"
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
