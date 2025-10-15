#!/bin/bash
set -euo pipefail

# RLENV Build Script
# This script rebuilds the application from source located at /rlenv/source/gobgp/
#
# Original image: ghcr.io/mayhemheroes/gobgp:v3.34.0
# Git revision: e2ae6daf0ba28a900041fe9b0329e8b1fc67fde9

# Ensure Go toolchain is in PATH (for non-root users)
export PATH="/root/.go/bin:/root/go/bin:${PATH}"
export GOPATH="${GOPATH:-/root/go}"
# Use the Go cache from the Docker build to avoid network access
export GOCACHE="/root/.cache/go-build"
export GOMODCACHE="/root/go/pkg/mod"
# Disable VCS stamping to avoid Git errors in Docker
export GOFLAGS="${GOFLAGS:-} -buildvcs=false"

# Change to the source directory
cd /rlenv/source/gobgp
rm -f *.a /out/fuzz_parse_bgp_message

# Set compiler flags for address sanitizer
export CXXFLAGS="${CXXFLAGS:-} -fsanitize=address -lpthread"

# First compilation attempt - may generate file with unused reflect import
# Using || true to continue even if this fails
compile_native_go_fuzzer $PWD/pkg/packet/bgp FuzzParseBGPMessage fuzz_parse_bgp_message || true

# Fix the "reflect imported and not used" issue if it occurs
# This is a known issue with go-118-fuzz-build (see CLAUDE.md)
if [ -f pkg/packet/bgp/bgp_test.go_fuzz.go ]; then
    sed -i '/^[[:space:]]*"reflect"$/d' pkg/packet/bgp/bgp_test.go_fuzz.go
fi

# Rebuild after fixing the reflect import issue
compile_native_go_fuzzer $PWD/pkg/packet/bgp FuzzParseBGPMessage fuzz_parse_bgp_message

# Verify build artifact exists
if [ ! -f /out/fuzz_parse_bgp_message ]; then
    echo "Error: Build artifact not found at /out/fuzz_parse_bgp_message"
    exit 1
fi

# Ensure the output file is world-readable, writable, and executable for unprivileged users
chmod 777 /out/fuzz_parse_bgp_message

echo "Build completed successfully: /out/fuzz_parse_bgp_message"
