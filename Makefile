.PHONY: build-wasm clean install-binaryen test test-clean build help

help:
	@echo "AssemblyLine Build Commands"
	@echo "=============================="
	@echo "make build             - Build main specification document"
	@echo "make build-wasm        - Build and optimize the WASM plugin"
	@echo "make test              - Run all tests"
	@echo "make test-clean        - Clean test artifacts"
	@echo "make install-binaryen  - Install Binaryen for WASM optimization"
	@echo "make clean             - Clean build artifacts"
	@echo ""

build:
	@echo "Building main specification..."
	@cd tests && typst compile main.typ
	@echo "✓ Build complete: tests/main.pdf"

build-wasm:
	@./build-wasm.sh

install-binaryen:
	@echo "Installing Binaryen..."
	@command -v brew >/dev/null 2>&1 && (brew install binaryen && echo "✓ Installed via Homebrew") || \
	command -v apt-get >/dev/null 2>&1 && (sudo apt-get install -y binaryen && echo "✓ Installed via apt") || \
	command -v pacman >/dev/null 2>&1 && (sudo pacman -S binaryen && echo "✓ Installed via pacman") || \
	echo "Please install Binaryen manually from: https://github.com/WebAssembly/binaryen/releases"

clean:
	@echo "Cleaning build artifacts..."
	@cd assembly_plugin && cargo clean
	@rm -rf packages/preview/assemblyline/main/plugin/*.wasm
	@echo "✓ Clean complete"

test:
	@echo "Running tests..."
	@cd tests && for test in test-*.typ; do \
		echo "  Compiling $$test..."; \
		typst compile "$$test" || exit 1; \
	done
	@echo "✓ All tests passed"

test-clean:
	@echo "Cleaning test artifacts..."
	@cd tests && rm -f test-*.pdf
	@cd examples && rm -f *.pdf
	@echo "✓ Test artifacts cleaned"
