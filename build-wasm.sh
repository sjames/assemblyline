#!/bin/bash
set -e

echo "=========================================="
echo "AssemblyLine WASM Build Script"
echo "=========================================="

# Configuration
PLUGIN_DIR="assembly_plugin"
SOURCE_WASM="${PLUGIN_DIR}/target/wasm32-unknown-unknown/release/assembly_plugin.wasm"
DEST_DIR="packages/preview/assemblyline/main/plugin"
DEST_WASM="${DEST_DIR}/assembly_plugin.wasm"
OPTIMIZED_WASM="${DEST_DIR}/assembly_plugin.wasm"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if wasm32 target is installed
echo -e "${BLUE}Checking Rust toolchain...${NC}"
if ! rustup target list | grep -q "wasm32-unknown-unknown (installed)"; then
    echo -e "${YELLOW}Installing wasm32-unknown-unknown target...${NC}"
    rustup target add wasm32-unknown-unknown
else
    echo -e "${GREEN}✓ wasm32-unknown-unknown target is installed${NC}"
fi

# Build the WASM binary
echo -e "${BLUE}Building WASM binary...${NC}"
cd ${PLUGIN_DIR}
cargo build --release --target wasm32-unknown-unknown
cd ..

if [ ! -f "${SOURCE_WASM}" ]; then
    echo -e "${RED}✗ Build failed: ${SOURCE_WASM} not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ WASM binary built successfully${NC}"

# Get initial size
INITIAL_SIZE=$(stat -f%z "${SOURCE_WASM}" 2>/dev/null || stat -c%s "${SOURCE_WASM}" 2>/dev/null)
echo -e "  Initial size: $(numfmt --to=iec-i --suffix=B ${INITIAL_SIZE} 2>/dev/null || echo "${INITIAL_SIZE} bytes")"

# Create destination directory
mkdir -p "${DEST_DIR}"

# Check for wasm-opt and optimize if available
if command -v wasm-opt &> /dev/null; then
    echo -e "${BLUE}Optimizing WASM binary with wasm-opt...${NC}"
    wasm-opt -Oz "${SOURCE_WASM}" -o "${OPTIMIZED_WASM}"

    OPTIMIZED_SIZE=$(stat -f%z "${OPTIMIZED_WASM}" 2>/dev/null || stat -c%s "${OPTIMIZED_WASM}" 2>/dev/null)
    REDUCTION=$(echo "scale=2; (${INITIAL_SIZE} - ${OPTIMIZED_SIZE}) * 100 / ${INITIAL_SIZE}" | bc)

    echo -e "${GREEN}✓ WASM binary optimized${NC}"
    echo -e "  Optimized size: $(numfmt --to=iec-i --suffix=B ${OPTIMIZED_SIZE} 2>/dev/null || echo "${OPTIMIZED_SIZE} bytes")"
    echo -e "  Size reduction: ${REDUCTION}%"
else
    echo -e "${YELLOW}⚠ wasm-opt not found, skipping optimization${NC}"
    echo -e "  Install Binaryen to optimize: https://github.com/WebAssembly/binaryen/releases"
    cp "${SOURCE_WASM}" "${OPTIMIZED_WASM}"
    echo -e "${GREEN}✓ WASM binary copied to ${DEST_DIR}${NC}"
fi

# Verify the binary was created
if [ ! -f "${OPTIMIZED_WASM}" ]; then
    echo -e "\033[0;31m✗ Failed to create optimized WASM binary${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=========================================="
echo "Build completed successfully!"
echo "==========================================${NC}"
echo "Output: ${OPTIMIZED_WASM}"
echo ""
