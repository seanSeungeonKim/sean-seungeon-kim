# Variables
JEKYLL = bundle exec jekyll
BUILD_DIR = _site
PORT = 4000
CONFIG = _config.yml

.PHONY: all build serve clean help

# Default target
all: build

# Build the Jekyll site
build:
	$(JEKYLL) build --watch

# Serve the Jekyll site locally
serve:
	$(JEKYLL) serve

# Clean the build directory
clean:
	rm -rf $(BUILD_DIR)

# Show available commands
help:
	@echo "Available commands:"
	@echo "  make build   - Build the Jekyll site"
	@echo "  make serve   - Build and serve the Jekyll site locally"
	@echo "  make clean   - Clean the build directory"
	@echo "  make help    - Show this help message"
