{
  description = "Frosted flakes, just add milk!";

  outputs = { self, nixpkgs, ... }: {
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
