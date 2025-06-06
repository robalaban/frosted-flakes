{
  description = "Java development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      
      perSystem = { pkgs, lib, config, ... }:
        let
          # Use JDK 17 (LTS)
          javaVersion = 17;
          jdk = pkgs.jdk17;
        in {
          packages = {
            default = jdk;
          };
          
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              # Core Java development
              jdk
              
              # Build tools
              gradle
              maven
              
              # Additional development tools
              jdt-language-server  # Java language server for IDEs
              google-java-format   # Code formatter
              
              # Analysis and testing tools
              spotbugs            # Static analysis
              checkstyle          # Code style checker
            ];
            
            shellHook = ''
              echo "☕ Java development environment activated!"
              echo "Java version: $(java -version 2>&1 | head -n 1)"
              echo "Available tools: gradle, maven, google-java-format"
              echo ""
              echo "Quick start:"
              echo "  gradle init              # Initialize new Gradle project"
              echo "  mvn archetype:generate   # Initialize new Maven project"
              echo "  gradle build             # Build with Gradle"
              echo "  mvn compile              # Compile with Maven"
              echo ""
              echo "JDK Location: ${jdk}"
              export JAVA_HOME="${jdk}"
            '';
            
            # Set JAVA_HOME for the shell
            JAVA_HOME = jdk;
          };
          
          apps = {
            default = {
              program = "${jdk}/bin/java";
              type = "app";
            };
          };
        };
    };
}
