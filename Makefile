.PHONY: build-wasm clean install-binaryen test test-rust test-typst test-clean build help

help:
	@echo "AssemblyLine Build Commands"
	@echo "=============================="
	@echo "make build             - Build main specification document"
	@echo "make build-wasm        - Build and optimize the WASM plugin"
	@echo "make test              - Run all tests (Rust + Typst + Examples + Validation)"
	@echo "make test-rust         - Run only Rust/WASM plugin tests"
	@echo "make test-typst        - Run only Typst compilation tests"
	@echo "make test-clean        - Clean test artifacts"
	@echo "make install-binaryen  - Install Binaryen for WASM optimization"
	@echo "make clean             - Clean build artifacts"
	@echo ""
	@echo "Test Coverage:"
	@echo "  - 27 Rust unit tests (SAT solver + feature validation + parameters + constraints)"
	@echo "  - 8 Typst integration tests"
	@echo "  - 10 Example compilation tests (including feature visualizations + parameter bindings)"
	@echo "  - 1 Parameter validation test (negative test)"
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
	@echo "=========================================="
	@echo "Running AssemblyLine Test Suite"
	@echo "=========================================="
	@echo ""
	@echo "1. Running Rust tests (WASM plugin)..."
	@cd assembly_plugin && cargo test --lib
	@echo ""
	@echo "2. Running Typst tests..."
	@cd tests && for test in test-*.typ; do \
		echo "  ✓ Compiling $$test..."; \
		typst compile --root .. "$$test" > /dev/null 2>&1 || { echo "  ✗ Failed: $$test"; exit 1; }; \
	done
	@echo ""
	@echo "3. Running example compilation tests..."
	@for example in examples/sat-validation-example.typ examples/parameters-example.typ examples/test-json-export.typ examples/parameter-visualization-demo.typ examples/feature-subtree-demo.typ examples/feature-tree-detailed-example.typ examples/feature-tree-advanced-demo.typ examples/test-validation-options.typ examples/test-feature-tree-with-parameters.typ examples/full-model/feature-model-visualization-demo.typ; do \
		echo "  ✓ Compiling $$example..."; \
		typst compile --root . "$$example" > /dev/null 2>&1 || { echo "  ✗ Failed: $$example"; exit 1; }; \
	done
	@echo ""
	@echo "4. Testing parameter validation (should fail)..."
	@typst compile --root . examples/parameters-validation-test.typ > /dev/null 2>&1 && { echo "  ✗ Validation test should have failed!"; exit 1; } || echo "  ✓ Parameter validation correctly rejected invalid config"
	@echo ""
	@echo "=========================================="
	@echo "✓ All tests passed!"
	@echo "=========================================="

test-rust:
	@echo "Running Rust tests (WASM plugin)..."
	@cd assembly_plugin && cargo test --lib
	@echo "✓ Rust tests passed"

test-typst:
	@echo "Running Typst tests..."
	@cd tests && for test in test-*.typ; do \
		echo "  ✓ Compiling $$test..."; \
		typst compile --root .. "$$test" > /dev/null 2>&1 || { echo "  ✗ Failed: $$test"; exit 1; }; \
	done
	@echo "✓ Typst tests passed"

test-clean:
	@echo "Cleaning test artifacts..."
	@cd tests && rm -f test-*.pdf
	@cd examples && rm -f *.pdf
	@cd examples/full-model && rm -f *.pdf
	@echo "✓ Test artifacts cleaned"
