#!/bin/bash
# Run all Oracle Council visualization demos
# Usage: bash run_all_demos.sh

set -e

echo "================================================"
echo "  THE ORACLE COUNCIL — Visualization Suite"
echo "  Stereographic Projection & Millennium Problems"
echo "================================================"
echo ""

pip install -q numpy matplotlib scipy 2>/dev/null || true

for demo in demo1_stereographic_projection.py \
            demo2_local_global_transfer.py \
            demo3_ricci_flow_surgery.py \
            demo4_millennium_landscape.py \
            demo5_zeta_critical_strip.py \
            demo6_seven_north_poles.py; do
    echo "Running $demo..."
    python "$(dirname "$0")/$demo"
done

echo ""
echo "All demos complete. PNG files saved to demos/ directory."
