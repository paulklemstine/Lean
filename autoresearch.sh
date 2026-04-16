#!/bin/bash
set -euo pipefail

# Autoresearch benchmark: factor large integers
# Outputs METRIC lines for primary and secondary metrics

cd /home/raver1975/lean

# Fast syntax check
python3 -c "import py_compile; py_compile.compile('factor_autoresearch.py', doraise=True)" 2>/dev/null || {
    echo "METRIC factor_80bit_ms=999999"
    echo "METRIC alpha_fit=1.0"
    echo "METRIC best_48bit_ms=999999"
    echo "METRIC CRT_reduction=0"
    exit 0
}

# Run the benchmark (3 runs for stability)
python3 factor_autoresearch.py 2>&1 | grep "^METRIC" || {
    echo "METRIC factor_80bit_ms=999999"
    echo "METRIC alpha_fit=1.0"
    echo "METRIC best_48bit_ms=999999"
    echo "METRIC CRT_reduction=0"
}