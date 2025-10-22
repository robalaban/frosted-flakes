{
  description = "Python development environment with uv package manager";

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

      perSystem = { pkgs, ... }:
        let
          # Use the latest stable Python version
          python = pkgs.python312;

          # Create a Python environment with common packages
          pythonEnv = python.withPackages (ps: with ps; [
            # Data science and scientific computing
            numpy
            pandas
            matplotlib
            scipy
            scikit-learn

            # Web development
            requests
            flask
            fastapi

            # Development tools
            pytest
            black
            isort
            mypy

            # Jupyter and notebooks
            jupyter
            ipython
          ]);
        in
        {
          packages = {
            default = pythonEnv;
          };

          devShells = {
            default = pkgs.mkShell {
              packages = with pkgs; [
                pythonEnv

                # Modern Python package manager and tools
                uv # Fast Python package installer
                ruff # Fast Python linter
                pyright # Python language server
              ];

              shellHook = ''
                echo "🐍 Python development environment activated!"
                echo "Python version: $(python --version)"
                echo "Package manager: uv (fast and modern)"
                echo "Available tools: uv, ruff, pyright"
                echo ""
                echo "Quick start:"
                echo "  uv init                  # Initialize new project with uv"
                echo "  uv add <package>         # Add dependency"
                echo "  uv run python script.py # Run Python script"
                echo "  jupyter notebook         # Start Jupyter notebook"
                echo ""
                echo "Pre-installed packages:"
                echo "  numpy, pandas, matplotlib, scipy, scikit-learn"
                echo "  requests, flask, fastapi"
                echo "  pytest, black, isort, mypy"
              '';
            };
          };

          apps = {
            default = {
              program = "${pythonEnv}/bin/python";
              type = "app";
            };
          };
        };
    };
}
