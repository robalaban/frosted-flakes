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
  };
}
