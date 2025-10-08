#!/bin/bash
set -euo pipefail

# RLENV Build Script
# This script rebuilds the application from source located at /rlenv/source/gobgp/
#
# Original image: ghcr.io/mayhemheroes/gobgp:v3.34.0
# Git revision: e2ae6daf0ba28a900041fe9b0329e8b1fc67fde9

# Change to the source directory
cd /rlenv/source/gobgp

# Apply sed fix to remove benchmark function that interferes with fuzzing
sed -i '/func BenchmarkNormalizeFlowSpecOpValues(/,/^}/ s/^/\/\//' pkg/packet/bgp/bgp_test.go

# Set compiler flags for address sanitizer
export CXXFLAGS="-fsanitize=address -lpthread"

# Build the fuzz target (first attempt - may fail due to reflect import issue)
compile_native_go_fuzzer $PWD/pkg/packet/bgp FuzzParseBGPMessage fuzz_parse_bgp_message || true

# Fix the "reflect imported and not used" issue if the generated file exists
if [ -f pkg/packet/bgp/bgp_test.go_fuzz.go ]; then
  sed -i '/^[[:space:]]*"reflect"$/d' pkg/packet/bgp/bgp_test.go_fuzz.go
fi

# Rebuild after fixing the reflect import issue
compile_native_go_fuzzer $PWD/pkg/packet/bgp FuzzParseBGPMessage fuzz_parse_bgp_message

# Verify build artifacts exist
if [ ! -f /out/fuzz_parse_bgp_message ]; then
    echo "Error: Build artifact /out/fuzz_parse_bgp_message not found"
    exit 1
fi

echo "Build completed successfully. Fuzzer binary at /out/fuzz_parse_bgp_message"
