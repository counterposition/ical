BINARY_NAME=ical
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT=$(shell git rev-parse --short HEAD 2>/dev/null || echo "none")
DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
LDFLAGS=-ldflags "-X main.version=$(VERSION) -X main.commit=$(COMMIT) -X main.date=$(DATE)"

.PHONY: all build install test lint lint-actions check-module clean completions release indexnow help

all: build

build: ## Build the binary (includes EventKit via cgo)
	@mkdir -p bin
	go build $(LDFLAGS) -o bin/$(BINARY_NAME) ./cmd/ical/

install: build ## Install the binary to $GOPATH/bin
	go install $(LDFLAGS) ./cmd/ical/

test: ## Run tests
	go test ./... -v

lint: ## Run golangci-lint
	@if command -v mise >/dev/null 2>&1; then \
		mise x -- golangci-lint run ./...; \
	elif command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run ./...; \
	else \
		echo "golangci-lint not found; install mise to use pinned tools from mise.toml" >&2; \
		exit 127; \
	fi

lint-actions: ## Lint and security-audit GitHub Actions workflows
	actionlint .github/workflows/*.yml
	zizmor --format plain .github/workflows

check-module: ## Verify the fork module path and reject upstream self-imports
	@test "$$(go list -m)" = "github.com/counterposition/ical" || { \
		echo "go.mod must declare github.com/counterposition/ical" >&2; \
		exit 1; \
	}
	@if git grep -n '"github.com/BRO3886/ical/' -- '*.go'; then \
		echo "upstream self-imports are not allowed in the fork module" >&2; \
		exit 1; \
	fi

release: ## Build release tarballs for GitHub upload (arm64 + amd64)
	@mkdir -p bin
	@for arch in arm64 amd64; do \
		echo "Building ical-darwin-$$arch..."; \
		CGO_ENABLED=1 GOARCH=$$arch go build $(LDFLAGS) -o bin/ical ./cmd/ical/; \
		chmod +x bin/ical; \
		tar -czf bin/ical-darwin-$$arch.tar.gz -C bin ical; \
		rm bin/ical; \
	done
	@cd bin && shasum -a 256 \
		ical-darwin-arm64.tar.gz \
		ical-darwin-amd64.tar.gz > SHA256SUMS
	@echo "Release assets are in bin/"

clean: ## Remove built binaries
	rm -rf bin/

indexnow: ## Submit live sitemap URLs to IndexNow (run after a deploy with content changes)
	sh scripts/indexnow.sh

completions: build ## Generate shell completion scripts
	mkdir -p completions
	./bin/$(BINARY_NAME) completion bash > completions/ical.bash
	./bin/$(BINARY_NAME) completion zsh > completions/_ical
	./bin/$(BINARY_NAME) completion fish > completions/ical.fish

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
