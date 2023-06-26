{
  description = "Frosted flakes, just add milk!";

  outputs = { self, nixpkgs, ... }: {
    templates = {
      rust = {
        path = ./rust;
        description = "A rust template";
      };
    };
  };
}
