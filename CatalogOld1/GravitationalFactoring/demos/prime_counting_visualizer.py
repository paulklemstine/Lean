#!/usr/bin/env python3
"""
Prime Counting Function Visualizer

Compares π(x) with its asymptotic approximations:
- x/ln(x) — the classic PNT approximation
- Li(x) — the logarithmic integral (better approximation)

Also verifies Bertrand's postulate and explores prime gaps.

Usage:
    python prime_counting_visualizer.py [max_x]
"""

import sys
import math

def sieve_of_eratosthenes(limit):
    """Return a list of primes up to limit using the Sieve of Eratosthenes."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(math.sqrt(limit)) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def pi(x, primes):
    """Prime counting function π(x)."""
    count = 0
    for p in primes:
        if p > x:
            break
        count += 1
    return count

def li(x):
    """Logarithmic integral Li(x) ≈ ∫₂ˣ dt/ln(t), approximated numerically."""
    if x <= 2:
        return 0
    # Simple numerical integration using trapezoidal rule
    n_steps = max(1000, int(x))
    n_steps = min(n_steps, 100000)
    dt = (x - 2) / n_steps
    total = 0
    for i in range(n_steps):
        t = 2 + (i + 0.5) * dt
        if t > 1:
            total += dt / math.log(t)
    return total

def verify_bertrand(primes, max_n):
    """Verify Bertrand's postulate: for every n ≥ 1, there exists a prime p with n < p ≤ 2n."""
    prime_set = set(primes)
    for n in range(1, max_n + 1):
        found = False
        for p in range(n + 1, 2 * n + 1):
            if p in prime_set:
                found = True
                break
        if not found:
            return False, n
    return True, max_n

def prime_gaps(primes):
    """Compute gaps between consecutive primes."""
    gaps = []
    for i in range(1, len(primes)):
        gaps.append((primes[i-1], primes[i], primes[i] - primes[i-1]))
    return gaps

def main():
    max_x = int(sys.argv[1]) if len(sys.argv) > 1 else 1000

    print("╔══════════════════════════════════════════════════════════╗")
    print("║     Prime Counting Function π(x) Visualizer             ║")
    print("║     Gravitational Factoring Project — v12               ║")
    print("╚══════════════════════════════════════════════════════════╝")

    primes = sieve_of_eratosthenes(max_x)

    # Verified values
    print("\n  Formally Verified Values (Lean 4):")
    verified = [(2,1), (3,2), (5,3), (10,4), (20,8), (30,10), (100,25), (1000,168)]
    for x, expected in verified:
        if x <= max_x:
            actual = pi(x, primes)
            status = "✓" if actual == expected else "✗"
            print(f"    π({x:>5}) = {actual:>4}  {status} (proven: prime_count_{x})")

    # Comparison table
    print(f"\n  {'x':>8} {'π(x)':>8} {'x/ln(x)':>10} {'Li(x)':>10} {'π/[x/ln]':>10} {'π/Li':>10}")
    print("  " + "-" * 60)

    checkpoints = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000,
                   50000, 100000, 500000, 1000000]

    for x in checkpoints:
        if x > max_x:
            break
        p = pi(x, primes)
        xln = x / math.log(x) if x > 1 else 0
        lix = li(x)
        ratio1 = p / xln if xln > 0 else 0
        ratio2 = p / lix if lix > 0 else 0
        print(f"  {x:>8} {p:>8} {xln:>10.1f} {lix:>10.1f} {ratio1:>10.4f} {ratio2:>10.4f}")

    # Prime Number Theorem convergence
    print(f"\n  Prime Number Theorem: π(x) ~ x/ln(x)")
    print(f"    The ratio π(x)/(x/ln(x)) → 1 as x → ∞")
    print(f"    Li(x) is a much better approximation than x/ln(x)")

    # Bertrand's postulate
    bertrand_limit = min(max_x // 2, 10000)
    holds, checked = verify_bertrand(primes, bertrand_limit)
    print(f"\n  Bertrand's Postulate Verification:")
    print(f"    Checked for all n ≤ {checked}: {'✓ Holds' if holds else '✗ Failed at n=' + str(checked)}")
    print(f"    Formally verified instances: n = 1, 2, 3, 10, 50")

    # Prime gaps
    gaps = prime_gaps(primes)
    max_gap = max(gaps, key=lambda g: g[2]) if gaps else (0, 0, 0)
    print(f"\n  Largest Prime Gap ≤ {max_x}:")
    print(f"    Between {max_gap[0]} and {max_gap[1]}, gap = {max_gap[2]}")

    # Gap distribution
    gap_counts = {}
    for _, _, g in gaps:
        gap_counts[g] = gap_counts.get(g, 0) + 1

    print(f"\n  Gap Distribution (top 10):")
    for gap, count in sorted(gap_counts.items(), key=lambda x: -x[1])[:10]:
        bar = "█" * min(count, 50)
        print(f"    Gap {gap:>3}: {count:>5} {bar}")

    # Twin primes
    twin_primes = [(p1, p2) for p1, p2, g in gaps if g == 2]
    print(f"\n  Twin Prime Pairs ≤ {max_x}: {len(twin_primes)}")
    if twin_primes:
        print(f"    First few: {twin_primes[:8]}")
        print(f"    Last found: {twin_primes[-1]}")

    print(f"\n  Total primes ≤ {max_x}: {len(primes)}")

if __name__ == "__main__":
    main()
