# Building AssemblyLine

This document explains how to build the AssemblyLine project, including the WASM plugin.

## Prerequisites

- **Rust**: Ensure you have Rust installed with the `wasm32-unknown-unknown` target
  ```bash
  rustup target add wasm32-unknown-unknown
  ```
- **Typst**: For compiling the specification
- **Binaryen** (optional): For WASM optimization
  ```bash
  # macOS
  brew install binaryen

  # Linux (Ubuntu/Debian)
  sudo apt-get install binaryen

  # Or download from: https://github.com/WebAssembly/binaryen/releases
  ```

## Building the WASM Plugin

### Option 1: Using the Build Script

```bash
./build-wasm.sh
```

This script will:
1. Verify the Rust toolchain is set up
2. Build the WASM binary in release mode
3. Optimize it with `wasm-opt` (if installed)
4. Copy it to `packages/preview/assemblyline/main/plugin/`

### Option 2: Using Make

```bash
make build-wasm
```

Or install Binaryen first:
```bash
make install-binaryen
make build-wasm
```

### Manual Build

If you prefer to build manually:

```bash
cd assembly_plugin
cargo build --release --target wasm32-unknown-unknown
cd ..

# Optional: Optimize with wasm-opt
wasm-opt -Oz assembly_plugin/target/wasm32-unknown-unknown/release/assembly_plugin.wasm \
  -o packages/preview/assemblyline/main/plugin/assembly_plugin.wasm

# Or just copy without optimization
cp assembly_plugin/target/wasm32-unknown-unknown/release/assembly_plugin.wasm \
  packages/preview/assemblyline/main/plugin/
```

## Compiling the Specification

Once the WASM plugin is built, compile the main specification:

```bash
typst compile main.typ main.pdf
```

## Project Structure

```
.
├── assembly_plugin/              # Rust project for WASM validation plugin
│   ├── Cargo.toml
│   ├── src/
│   └── target/wasm32-unknown-unknown/
├── packages/preview/assemblyline/main/  # Publishable Typst package
│   ├── lib/                      # Core AssemblyLine library
│   ├── plugin/                   # WASM binaries
│   │   └── assembly_plugin.wasm
│   └── typst.toml               # Package manifest
├── features/                     # Feature definitions
├── use-cases/                    # Use case scenarios
├── diagrams/                     # Architecture diagrams
├── build-wasm.sh                 # WASM build script
├── Makefile                      # Build commands
└── main.typ                      # Main specification file
```

## WASM Binary Optimization

The build script automatically optimizes the WASM binary if `wasm-opt` is available.

**Size reduction example:**
- Before optimization: ~313 KiB
- After optimization (with `-Oz`): ~200-250 KiB (typical 30-40% reduction)

The `-Oz` flag provides maximum size optimization, suitable for distribution.

## Troubleshooting

### wasm32 target not found
```bash
rustup target add wasm32-unknown-unknown
```

### WASM binary too large
Install Binaryen and rebuild:
```bash
make install-binaryen
make clean
make build-wasm
```

### main.typ won't compile
Ensure the WASM plugin is built first:
```bash
make build-wasm
typst compile main.typ
```

## Development Workflow

1. Make changes to `assembly_plugin/src/`
2. Run `make build-wasm` to rebuild the plugin
3. Run `typst compile main.typ` to generate the PDF

For rapid iteration, you can skip WASM rebuilds if only changing Typst files.

## Publishing to Typst Universe

The package in `packages/preview/assemblyline/main/` is ready to publish:

```bash
# Create a PR to https://github.com/typst/packages
# Including the built WASM binary
```

See the main README for more details on publishing.
