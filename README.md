# Frosted Flakes 🥣

[![Test Flakes](https://github.com/robalaban/frosted-flakes/actions/workflows/test.yml/badge.svg)](https://github.com/robalaban/frosted-flakes/actions/workflows/test.yml)

Frosted Flakes is a collection of Nix flake templates for quickly bootstrapping development environments. Just add milk!

## What is Frosted Flakes?

Frosted Flakes provides pre-configured, reproducible development environments for popular programming languages using Nix flakes. Each template includes the latest stable versions of language toolchains, development tools, and common dependencies.

## Project Goals

1. **Quick Setup**: One command to create fully-configured development environments
2. **Reproducibility**: Consistent environments across different machines and team members  
3. **Latest Tools**: Always use the most recent stable versions from nixpkgs-unstable
4. **Best Practices**: Include linters, formatters, and development tools out of the box

## Available Templates

### 🦀 Rust
- **Toolchain**: cargo, rustc, clippy, rustfmt, rust-analyzer
- **Tools**: cargo-watch, cargo-edit, cargo-audit
- **System**: pkg-config, openssl

### 🟢 Node.js
- **Runtime**: Node.js 22 (latest LTS)
- **Package Manager**: pnpm (primary), yarn (secondary)
- **Tools**: TypeScript, ESLint, Prettier, Nodemon
- **Build Tools**: Vite, Webpack

### 🐍 Python  
- **Runtime**: Python 3.12
- **Package Manager**: uv (fast and modern)
- **Tools**: ruff (linter), pyright (LSP), black, isort, mypy
- **Libraries**: numpy, pandas, matplotlib, scipy, scikit-learn, requests, flask, fastapi, pytest, jupyter

### ☕ Java
- **Runtime**: JDK 17 (LTS)
- **Build Tools**: Gradle, Maven
- **Tools**: Language server, Google Java Format, SpotBugs, Checkstyle

## Cross-Platform Support

All templates support:
- **Linux**: x86_64, aarch64
- **macOS**: Intel (x86_64), Apple Silicon (aarch64)

## Usage

### Creating a New Project

Create a new project with a template:

```bash
# Create project directory and initialize
mkdir my-project && cd my-project

# Initialize with template (replace 'rust' with desired language)
nix flake init -t github:robalaban/frosted-flakes#rust

# Enter development environment
nix develop
```

### Available Templates

```bash
# Rust development environment
nix flake init -t github:robalaban/frosted-flakes#rust

# Node.js development environment  
nix flake init -t github:robalaban/frosted-flakes#node

# Python development environment
nix flake init -t github:robalaban/frosted-flakes#python

# Java development environment
nix flake init -t github:robalaban/frosted-flakes#java
```

### Automatic Environment with direnv

For automatic environment activation when entering directories:

```bash
# In your project directory
echo "use flake" > .envrc
direnv allow

# Environment will activate automatically when you cd into the directory
```

## Development Environment Features

Each template provides:

- ✅ **Latest stable versions** from nixpkgs-unstable
- ✅ **Language-specific toolchains** and package managers  
- ✅ **Development tools** (linters, formatters, language servers)
- ✅ **Helpful shell prompts** with quick-start instructions
- ✅ **Cross-platform compatibility** 
- ✅ **Reproducible builds** via Nix flakes

## Examples

### Rust Development
```bash
# Initialize Rust project
mkdir my-rust-app && cd my-rust-app
nix flake init -t github:robalaban/frosted-flakes#rust
nix develop

# Available tools
cargo new .
cargo build
cargo test
cargo clippy
cargo fmt
```

### Node.js Development  
```bash
# Initialize Node.js project
mkdir my-node-app && cd my-node-app
nix flake init -t github:robalaban/frosted-flakes#node
nix develop

# Available tools
pnpm init
pnpm add express
pnpm run dev
```

### Python Development
```bash
# Initialize Python project
mkdir my-python-app && cd my-python-app
nix flake init -t github:robalaban/frosted-flakes#python  
nix develop

# Available tools
uv init
uv add requests
python app.py
jupyter notebook
```

### Java Development
```bash
# Initialize Java project
mkdir my-java-app && cd my-java-app
nix flake init -t github:robalaban/frosted-flakes#java
nix develop

# Available tools
gradle init
gradle build
mvn archetype:generate
```

## Requirements

- [Nix](https://nixos.org/download.html) with flakes enabled
- Optional: [direnv](https://direnv.net/) for automatic environment activation

### Enable Nix Flakes

Add to `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

## Contributing

Contributions are welcome! To add a new template:

1. Create a new directory with the language name
2. Add a `flake.nix` with the development environment
3. Update the main `flake.nix` to include your template
4. Update this README

## License

MIT License - feel free to use these templates for any project!
