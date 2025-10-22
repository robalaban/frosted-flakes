# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Frosted Flakes is a collection of Nix flake templates for bootstrapping development environments across multiple languages. The project uses Nix flakes to provide reproducible, cross-platform development environments with the latest tools from nixpkgs-unstable.

## Architecture

### Repository Structure

The repository follows a template-based architecture:

- **Root `flake.nix`**: Defines the template registry and main development shell. Exports templates for each language and provides tooling for working on the templates themselves (nixpkgs-fmt, nil, direnv).

- **Language-specific directories** (`rust/`, `node/`, `python/`, `java/`): Each contains:
  - `flake.nix`: Complete, self-contained development environment definition
  - Sample files demonstrating template usage (e.g., `rust/Cargo.toml`, `rust/src/main.rs`)

### Template Architecture Pattern

All language templates follow a consistent pattern using `flake-parts`:

1. **Inputs**: Uses `nixpkgs-unstable` and `flake-parts` for cross-system support
2. **Systems**: Supports `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin`
3. **Outputs**:
   - `packages.default`: Language runtime or environment
   - `devShells.default`: Development environment with tools
   - `apps.default`: Executable program

Each template's `devShell` includes a `shellHook` that displays:
- Activation message with emoji identifier
- Version information
- Available tools
- Quick start commands specific to the language

### Cross-Platform Support

Templates are designed to work identically across:
- Linux (x86_64, aarch64)
- macOS (Intel, Apple Silicon)

The main flake uses `forAllSystems` helper to generate outputs for all supported platforms.

## Development Commands

### Working on Frosted Flakes Templates

```bash
# Enter development environment for working on templates
nix develop

# Run all tests in parallel (recommended before pushing)
./scripts/test-all.sh

# Format Nix files
nixpkgs-fmt flake.nix
nixpkgs-fmt rust/flake.nix  # etc.

# Check what templates are available
nix flake show

# Test a template locally
cd /tmp && mkdir test-project && cd test-project
nix flake init -t /path/to/frosted-flakes#rust
nix develop

# Update nixpkgs to latest unstable
nix flake update
```

### Testing Individual Templates

Each template should be tested in isolation:

```bash
# Rust template
cd rust && nix develop
cargo --version && rustc --version

# Node template
cd node && nix develop
node --version && pnpm --version

# Python template
cd python && nix develop
python --version && uv --version

# Java template
cd java && nix develop
java -version && gradle --version
```

## CI/CD

### GitHub Actions Workflow

The repository includes a comprehensive test harness in `.github/workflows/test.yml` that runs on every push to main and on pull requests. The workflow:

1. **test-templates job**: Tests all 4 templates (rust, node, python, java) on both Ubuntu and macOS in parallel using a matrix strategy. For each template:
   - Initializes the template in a temporary directory
   - Enters the development shell
   - Validates all expected tools are present and working
   - Runs template-specific commands (e.g., `cargo --version` for Rust, `pnpm --version` for Node)

2. **check-root-flake job**: Validates the root flake configuration:
   - Runs `nix flake check` to verify flake correctness
   - Tests the root development shell (nixpkgs-fmt, nil, direnv)
   - Displays flake metadata with `nix flake show`

3. **format-check job**: Ensures all Nix files are properly formatted with `nixpkgs-fmt`

### Running CI Tests Locally

The fastest way to run all CI tests locally is using the parallel test script:

```bash
# Run all tests in parallel (recommended)
./scripts/test-all.sh
```

This script:
- Tests all 4 templates in parallel using GNU `parallel`
- Runs `nix flake check` on the root flake
- Tests the root development shell
- Validates Nix file formatting
- Provides colorized output and a summary

**Requirements**: GNU `parallel` is included in the root development shell, so just run `nix develop` first:
```bash
nix develop
./scripts/test-all.sh
```

**Manual testing** (if you don't have `parallel` or want to test specific components):

```bash
# Check root flake
nix flake check
nix flake show

# Test root dev shell
nix develop --command bash -c "nixpkgs-fmt --version && nil --version && direnv --version"

# Format check
nix develop --command nixpkgs-fmt --check flake.nix
nix develop --command nixpkgs-fmt --check rust/flake.nix
# ... repeat for other templates

# Test a specific template (example: Rust)
cd /tmp && mkdir test-rust && cd test-rust
nix flake init -t ~/code/frosted-flakes#rust
nix develop --command bash -c "cargo --version && rustc --version && clippy --version"
```

### CI Badge

The README.md displays a status badge showing the current build status from GitHub Actions.

## Key Implementation Details

### Package Resolution

- **Rust template** (rust/flake.nix:18-21): Dynamically reads `Cargo.toml` to extract package name/version, with fallback defaults if file doesn't exist
- **Node template** (node/flake.nix:18-19): Uses `nodejs_22` (latest LTS)
- **Python template** (python/flake.nix:22-44): Creates a pre-configured Python environment with common data science and web packages
- **Java template** (java/flake.nix:18-20): Uses JDK 17 (LTS) and sets `JAVA_HOME` environment variable

### Flake Parts Integration

All language templates use `flake-parts` for modular flake composition:
- `perSystem` attribute provides per-system configuration
- Automatically handles cross-platform support
- Provides access to `pkgs`, `lib`, `config` for each system

### Version Management

All packages come from `nixpkgs-unstable` to provide the latest stable versions. When updating versions:

1. Run `nix flake update` in the root or template directory
2. Test on both Linux and macOS if possible
3. Update README.md if tool versions or features change significantly

## Adding New Templates

To add a new language template:

1. Create new directory: `mkdir <language>/`
2. Create `<language>/flake.nix` following the established pattern:
   - Use `flake-parts` for structure
   - Support all 4 platforms
   - Include helpful shellHook with emoji and quick start
   - Export `packages.default`, `devShells.default`, and `apps.default`
3. Update root `flake.nix` (line 12-29) to add template entry
4. Update `README.md` with template description and usage examples
5. Test template initialization and development shell

## Important Conventions

- **Package manager preferences**:
  - Rust: cargo (standard)
  - Node.js: pnpm (primary), yarn (secondary)
  - Python: uv (modern/fast)
  - Java: gradle and maven (both included)
- **Shell hooks**: Always provide quick start commands that users can copy-paste
- **Cross-platform**: Test changes on both macOS and Linux when possible

## Nix Flakes Requirements

Users need:
- Nix with flakes enabled (`experimental-features = nix-command flakes`)
- Optional: direnv for automatic environment activation
