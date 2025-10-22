#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Track overall status
FAILED_TESTS=()
PASSED_TESTS=()

# Cleanup function
cleanup() {
  if [ -n "${TEST_DIRS:-}" ]; then
    for dir in $TEST_DIRS; do
      [ -d "$dir" ] && rm -rf "$dir"
    done
  fi
}
trap cleanup EXIT

echo -e "${BLUE}🥣 Frosted Flakes Local Test Suite${NC}"
echo "======================================"
echo ""

# Test function for templates
test_template() {
  local template=$1
  local test_name="template-$template"

  echo -e "${YELLOW}Testing $template template...${NC}"

  # Create temporary directory
  local test_dir=$(mktemp -d)
  TEST_DIRS="$TEST_DIRS $test_dir"

  cd "$test_dir"

  # Initialize template
  if ! nix flake init -t "$REPO_ROOT#$template" &>/dev/null; then
    echo -e "${RED}✗ Failed to initialize $template template${NC}"
    FAILED_TESTS+=("$test_name")
    return 1
  fi

  # Run template-specific validation
  case "$template" in
    rust)
      if nix develop --command bash -c "
        set -e
        cargo --version &>/dev/null && \
        rustc --version &>/dev/null && \
        clippy --version &>/dev/null || cargo clippy --version &>/dev/null && \
        rustfmt --version &>/dev/null && \
        rust-analyzer --version &>/dev/null && \
        cargo-watch --version &>/dev/null && \
        cargo-edit --version &>/dev/null || cargo set-version --help &>/dev/null
      " 2>&1; then
        echo -e "${GREEN}✓ Rust template passed${NC}"
        PASSED_TESTS+=("$test_name")
        return 0
      else
        echo -e "${RED}✗ Rust template failed${NC}"
        FAILED_TESTS+=("$test_name")
        return 1
      fi
      ;;
    node)
      if nix develop --command bash -c "
        set -e
        node --version &>/dev/null && \
        pnpm --version &>/dev/null && \
        yarn --version &>/dev/null && \
        tsc --version &>/dev/null && \
        eslint --version &>/dev/null && \
        prettier --version &>/dev/null && \
        nodemon --version &>/dev/null
      " 2>&1; then
        echo -e "${GREEN}✓ Node.js template passed${NC}"
        PASSED_TESTS+=("$test_name")
        return 0
      else
        echo -e "${RED}✗ Node.js template failed${NC}"
        FAILED_TESTS+=("$test_name")
        return 1
      fi
      ;;
    python)
      if nix develop --command bash -c "
        set -e
        python --version &>/dev/null && \
        uv --version &>/dev/null && \
        ruff --version &>/dev/null && \
        pyright --version &>/dev/null && \
        black --version &>/dev/null && \
        isort --version &>/dev/null && \
        mypy --version &>/dev/null && \
        jupyter --version &>/dev/null && \
        pytest --version &>/dev/null && \
        python -c 'import sys; import requests, flask, fastapi' &>/dev/null
      " 2>&1; then
        echo -e "${GREEN}✓ Python template passed${NC}"
        PASSED_TESTS+=("$test_name")
        return 0
      else
        echo -e "${RED}✗ Python template failed${NC}"
        FAILED_TESTS+=("$test_name")
        return 1
      fi
      ;;
    java)
      if nix develop --command bash -c "
        set -e
        java -version &>/dev/null && \
        javac -version &>/dev/null && \
        gradle --version &>/dev/null && \
        mvn --version &>/dev/null && \
        test -n \"\$JAVA_HOME\"
      " 2>&1; then
        echo -e "${GREEN}✓ Java template passed${NC}"
        PASSED_TESTS+=("$test_name")
        return 0
      else
        echo -e "${RED}✗ Java template failed${NC}"
        FAILED_TESTS+=("$test_name")
        return 1
      fi
      ;;
  esac
}

# Run template tests in parallel
echo -e "${BLUE}Running template tests in parallel...${NC}"
echo ""

TEST_DIRS=""
export -f test_template
export REPO_ROOT RED GREEN YELLOW NC BLUE

# Run all template tests in parallel and collect results
parallel --will-cite --jobs 4 --line-buffer test_template ::: rust node python java || true

echo ""
echo -e "${BLUE}Running root flake checks...${NC}"

# Test root flake check
cd "$REPO_ROOT"
if nix flake check 2>&1 | grep -q "error:"; then
  echo -e "${RED}✗ Flake check failed${NC}"
  FAILED_TESTS+=("flake-check")
else
  echo -e "${GREEN}✓ Flake check passed${NC}"
  PASSED_TESTS+=("flake-check")
fi

# Test root dev shell
if nix develop --command bash -c "
  command -v nixpkgs-fmt >/dev/null && \
  command -v nil >/dev/null && \
  command -v direnv >/dev/null && \
  command -v parallel >/dev/null
" >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Root dev shell passed${NC}"
  PASSED_TESTS+=("root-devshell")
else
  echo -e "${RED}✗ Root dev shell failed${NC}"
  FAILED_TESTS+=("root-devshell")
fi

echo ""
echo -e "${BLUE}Running format checks...${NC}"

# Format check
if nix develop --command bash -c "
  set -e
  nixpkgs-fmt --check flake.nix &>/dev/null && \
  nixpkgs-fmt --check rust/flake.nix &>/dev/null && \
  nixpkgs-fmt --check node/flake.nix &>/dev/null && \
  nixpkgs-fmt --check python/flake.nix &>/dev/null && \
  nixpkgs-fmt --check java/flake.nix &>/dev/null
" 2>&1; then
  echo -e "${GREEN}✓ Format check passed${NC}"
  PASSED_TESTS+=("format-check")
else
  echo -e "${RED}✗ Format check failed (run: nixpkgs-fmt *.nix */flake.nix)${NC}"
  FAILED_TESTS+=("format-check")
fi

# Summary
echo ""
echo "======================================"
echo -e "${BLUE}Test Summary${NC}"
echo "======================================"
echo -e "${GREEN}Passed: ${#PASSED_TESTS[@]}${NC}"
echo -e "${RED}Failed: ${#FAILED_TESTS[@]}${NC}"

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
  echo ""
  echo -e "${RED}Failed tests:${NC}"
  for test in "${FAILED_TESTS[@]}"; do
    echo -e "${RED}  - $test${NC}"
  done
  echo ""
  exit 1
else
  echo ""
  echo -e "${GREEN}All tests passed! 🎉${NC}"
  echo ""
  exit 0
fi
