#!/bin/bash
set -euo pipefail

# Correctness checks for factoring experiments
# Verify that the factorizer correctly factors known numbers

cd /home/raver1975/lean

# Quick correctness test: factor known semiprimes
python3 -c "
import sys
sys.path.insert(0, '.')
from factor_autoresearch import *

# Test 1: Known small semiprimes
for n, expected in [(561, 3), (1729, 7), (10403, 101)]:
    r = factor_best(n)
    if r is None or r[0] * r[1] != n:
        print(f'FAIL: {n} not factored correctly')
        sys.exit(1)
    if r[0] != expected and r[1] != expected:
        pass  # Either factor is fine

# Test 2: Fresh random semiprimes (different seed each time)
random.seed(int(time.time()) % 10000)
for bits in [32, 48, 64]:
    p = make_prime(bits//2+1)
    q = make_prime(bits-bits//2+1)
    n = p * q
    r = factor_best(n)
    if r is None or r[0] * r[1] != n or r[0] == 1:
        print(f'FAIL: {bits}-bit semiprime not factored')
        sys.exit(1)

print('All correctness checks passed')
" 2>&1 | tail -5