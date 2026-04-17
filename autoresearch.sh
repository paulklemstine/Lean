#!/bin/bash
set -euo pipefail

# Benchmark: find max bit size factorable in 3 seconds
cd /home/raver1975/lean

# Fast syntax check
python3 -c "import py_compile; py_compile.compile('factor_autoresearch.py', doraise=True)" 2>/dev/null || {
    echo "METRIC max_bits_3s=0"
    exit 0
}

# Run the benchmark - simple approach with hard time limit per test
python3 << 'EOF'
import factor_autoresearch as fa
import time, random

def find_max_bits(target_ms=3000):
    lo, hi = 40, 200
    best_bits = lo
    while lo <= hi:
        mid = (lo + hi) // 2
        pass_count = 0
        n_trials = 3  # 3 trials, need 2 to pass (standard 2/3)
        for seed in range(42, 42+n_trials):
            random.seed(seed)
            p = fa.make_prime(mid//2+1)
            q = fa.make_prime(mid-mid//2+1)
            n = p * q
            t0 = time.perf_counter()
            r = fa.factor_best(n)
            t1 = time.perf_counter()
            t_ms = (t1 - t0) * 1000
            ok = r is not None and r[0]*r[1] == n
            if ok and t_ms <= target_ms:
                pass_count += 1
            # Hard cutoff: if >6s, bail this bit size
            if t_ms > 6000:
                pass_count = 0
                break
        if pass_count >= 2:  # 2/3 threshold — standard for ECM variance
            best_bits = mid
            lo = mid + 1
        else:
            hi = mid - 1
    return best_bits

best = find_max_bits(3000)
print(f'METRIC max_bits_3s={best}')
EOF