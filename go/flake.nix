{
  description = "Go development environment";

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
          # Check if go.mod exists, otherwise provide a default module name
          moduleName =
            if builtins.pathExists (inputs.self + "/go.mod")
            then
              let
                goModContent = builtins.readFile (inputs.self + "/go.mod");
                lines = lib.splitString "\n" goModContent;
                moduleLine = lib.findFirst (line: lib.hasPrefix "module " line) "" lines;
              in
              lib.removePrefix "module " moduleLine
            else "example.com/myapp";
        in
        {
          packages = {
            default = pkgs.buildGoModule {
              pname = lib.last (lib.splitString "/" moduleName);
              version = "0.1.0";
              src = inputs.self;

              # Handle case where go.sum might not exist yet
              vendorHash = null;
            };
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              # Core Go toolchain (latest version)
              go

              # Development tools
              gotools # goimports, godoc, etc.
              gopls # Go language server
              gomodifytags # Modify struct field tags
              impl # Generate method stubs
              delve # Go debugger

              # Code quality tools
              golangci-lint # Fast linters runner
              go-migrate # Database migrations

              # Testing and benchmarking
              gotestsum # Pretty test output
            ];

            shellHook = ''
              echo "🔵 Go development environment activated!"
              echo "Go version: $(go version | cut -d' ' -f3)"
              echo "Available tools: go, gopls, delve, golangci-lint"
              echo ""
              echo "Quick start:"
              echo "  go mod init <module>     # Initialize new module"
              echo "  go get <package>         # Add dependency"
              echo "  go run .                 # Run the program"
              echo "  go test ./...            # Run all tests"
              echo "  go build                 # Build binary"
              echo "  golangci-lint run        # Run linters"
            '';
          };

          apps = {
            default = {
              program = "${config.packages.default}/bin/${lib.last (lib.splitString "/" moduleName)}";
              type = "app";
            };
          };
        };
    };
}
