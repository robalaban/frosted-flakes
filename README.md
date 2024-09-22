# Frosted Flakes

Frosted Flakes is a collection of Nix flake templates for quickly bootstrapping development environments. Just add milk!

## What is Frosted Flakes?

Frosted Flakes is a repository of pre-configured Nix flake templates for various programming languages and development environments. It aims to simplify the process of setting up new projects with consistent, reproducible development environments using Nix.

## Project Goals

1. Provide a quick and easy way to start new projects with Nix flakes
2. Ensure consistent development environments across different machines
3. Offer templates for popular programming languages and frameworks
4. Simplify the adoption of Nix and flakes for new users

## Available Templates

Currently, Frosted Flakes offers templates for:

- Rust
- Node.js
- Java
- Python

More templates will be added in the future.

## How to Use

To use Frosted Flakes, you need to have Nix installed with flakes enabled.

### Creating a New Project

To create a new project using a Frosted Flakes template, use the following command:

```bash
mkdir -p my-new-project && cd my-new-project && nix flake init -t github:robalaban/frosted-flakes#java
```

Replace `<template>` with the name of the template you want to use (e.g. `rust`, `node`, or `java`).
