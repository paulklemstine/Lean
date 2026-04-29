#!/bin/bash
set -euo pipefail

# Aether autoresearch script
# Checks compilation, counts theorems/sorries, reports metrics

cd "$(dirname "$0")"

# Count total theorems and sorries across verified files
TOTAL_THEOREMS=0
TOTAL_SORRIES=0
VERIFIED_FILES=0

for f in $(grep "Path.*read_text" autoresearch.checks.sh | grep -oE "'[^']+'" | tr -d "'"); do
  FILEPATH="Catalog/${f#\.\./}"
  if [ -f "$FILEPATH" ]; then
    THMS=$(grep -cE "^\s*theorem " "$FILEPATH" 2>/dev/null || echo 0)
    SORRIES=$(grep -c "sorry" "$FILEPATH" 2>/dev/null || echo 0)
    TOTAL_THEOREMS=$((TOTAL_THEOREMS + THMS))
    TOTAL_SORRIES=$((TOTAL_SORRIES + SORRIES))
    VERIFIED_FILES=$((VERIFIED_FILES + 1))
  fi
done

# Count bridges
BRIDGE_COUNT=$(ls Catalog/Bridges/*Bridge*.lean 2>/dev/null | wc -l)

# Count catalog files
CATALOG_FILES=$(find Catalog -name "*.lean" ! -path "*/\.lake/*" 2>/dev/null | wc -l)

# Check for compilation errors
BUILD_OK=1
if [ -f "autoresearch.checks.sh" ]; then
  bash autoresearch.checks.sh 2>&1 | grep -q "PASSED" || BUILD_OK=0
fi

# Calculate concept quality (0-1)
# Higher is better: based on verified theorems and bridges
if [ $BUILD_OK -eq 1 ] && [ $TOTAL_SORRIES -eq 0 ]; then
  CONCEPT_QUALITY=1
else
  CONCEPT_QUALITY=0
fi

echo "METRIC concept_quality=$CONCEPT_QUALITY"
echo "METRIC verified_decls=$TOTAL_THEOREMS"
echo "METRIC verified_files=$VERIFIED_FILES"
echo "METRIC bridge_count=$BRIDGE_COUNT"
echo "METRIC sorry_files=$TOTAL_SORRIES"
echo "METRIC catalog_files=$CATALOG_FILES"
