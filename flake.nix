{
  description = "Frosted flakes, just add milk!";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: 
  let
    system = "x86_64-linux";  # adjust for your system
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    templates = {
      rust = {
        path = ./rust;
        description = "A rust template";
      };
      node = {
        path = ./node;
        description = "A NodeJS template";
      };
      java = {
        path = ./java;
        description = "A Java template";
      };
    };

    apps.${system}.init = {
      type = "app";
      program = pkgs.writeShellScriptBin "init-flake" ''
        if [ $# -ne 2 ]; then
          echo "Usage: init-flake <template> <project-name>"
          exit 1
        fi
        template=$1
        project_name=$2
        mkdir -p "$project_name" && \
        cd "$project_name" && \
        ${pkgs.nix}/bin/nix flake init -t "github:robalaban/frosted-flakes#$template" && \
        ${pkgs.direnv}/bin/direnv allow
      ''.outPath;
    };
  };
}
