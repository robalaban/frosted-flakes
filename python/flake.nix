{
  description = "A Python project using uv as the package manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system =  "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      pythonEnv = pkgs.python312.withPackages (ps: with ps; [
        pip
        virtualenv
        poetry
        numpy
        pandas
      ]);
    in
    {
      defaultPackage.${system} = pythonEnv;
      devShell.${system}.default = pkgs.mkShell {
        buildInputs = [
          pythonEnv
        ];
      };
    };
}
