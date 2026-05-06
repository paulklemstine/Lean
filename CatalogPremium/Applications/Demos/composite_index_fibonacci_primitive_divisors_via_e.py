#!/usr/bin/env python3
"""
Applications of Fibonacci Entry-Point Theory
=============================================

This script demonstrates practical applications of the entry-point
divisibility theorem and Carmichael's primitive divisor theorem.
"""

from math import gcd, isqrt
from functools import lru_cache

# ============================================================
# Core Fibonacci / number theory utilities
# ============================================================

def fib(n):
    if n <= 1: return n
    a, b = 0, 1
    for _ in range(n): a, b = b, a + b
    return a

def fib_mod(n, m):
    """Compute F(n) mod m efficiently."""
    if m == 1: return 0
    if n <= 1: return n % m
    a, b = 0, 1
    for _ in range(n):
        a, b = b, (a + b) % m
    return a

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def entry_point(p):
    """Entry point of p in the Fibonacci sequence (smallest k>0 with p|F(k))."""
    a, b = 0, 1
    for k in range(1, p * p + 1):
        a, b = b, (a + b) % p
        if a == 0:
            return k
    return None

def pisano_period(m):
    """Compute the Pisano period π(m): period of F(n) mod m."""
    if m <= 1: return 1
    a, b = 0, 1
    for k in range(1, 6 * m + 3):
        a, b = b, (a + b) % m
        if a == 0 and b == 1:
            return k
    return None

# ============================================================
# Application 1: Fibonacci Pseudoprime Test
# ============================================================

def fibonacci_pseudoprime_test(n):
    """
    Test whether n passes the Fibonacci compositeness test.

    For prime p: F(p) ≡ (p/5) mod p, where (p/5) is the Legendre symbol.
    - If p ≡ ±1 (mod 5): F(p) ≡ 1 (mod p)
    - If p ≡ ±2 (mod 5): F(p) ≡ -1 (mod p)

    If n fails this test, n is definitely composite.
    If n passes, it's "probably prime" (but Fibonacci pseudoprimes exist).
    """
    if n < 2: return False
    if n == 2 or n == 5: return True

    fn_mod = fib_mod(n, n)

    # Compute expected value based on Legendre symbol (n/5)
    r = n % 5
    if r == 1 or r == 4:  # n ≡ ±1 (mod 5)
        expected = 1
    elif r == 2 or r == 3:  # n ≡ ±2 (mod 5)
        expected = n - 1  # ≡ -1 mod n
    else:  # n ≡ 0 (mod 5)
        expected = 0

    return fn_mod == expected

def demo_primality_testing():
    """Demonstrate the Fibonacci primality test."""
    print("=" * 60)
    print("APPLICATION 1: FIBONACCI PRIMALITY TEST")
    print("=" * 60)
    print()
    print("The Fibonacci sequence provides a compositeness test:")
    print("If p is prime, then F(p) ≡ (p/5) mod p.")
    print("Failure means n is DEFINITELY composite.\n")

    # Test composites that are correctly detected
    composites_detected = 0
    composites_missed = 0 # Fibonacci pseudoprimes
    fpsp = []

    for n in range(4, 1000):
        if is_prime(n):
            continue
        passes = fibonacci_pseudoprime_test(n)
        if passes:
            composites_missed += 1
            if len(fpsp) < 10:
                fpsp.append(n)
        else:
            composites_detected += 1

    print(f"  Composites n ∈ [4, 999]:")
    print(f"    Correctly identified as composite: {composites_detected}")
    print(f"    Fibonacci pseudoprimes (false positives): {composites_missed}")
    if fpsp:
        print(f"    First few pseudoprimes: {fpsp}")
    else:
        print(f"    No pseudoprimes found in this range!")

    # Test some specific numbers
    print(f"\n  Specific tests:")
    test_nums = [561, 1105, 1729, 2821, 6601, 8911, 10585]
    for n in test_nums:
        passes = fibonacci_pseudoprime_test(n)
        actual = "prime" if is_prime(n) else "COMPOSITE"
        test_result = "passes" if passes else "FAILS"
        print(f"    n = {n:>6}: {actual:>10}, Fibonacci test {test_result}")

# ============================================================
# Application 2: Fibonacci-based Random Number Generation
# ============================================================

def fibonacci_rng(seed1, seed2, modulus, count):
    """
    Fibonacci-based PRNG: x_{n+2} = (x_{n+1} + x_n) mod m.

    The period is related to the Pisano period π(m).
    Entry point theory tells us which primes divide F(n) mod m.
    """
    a, b = seed1 % modulus, seed2 % modulus
    result = []
    for _ in range(count):
        result.append(a)
        a, b = b, (a + b) % modulus
    return result

def demo_random_generation():
    """Demonstrate Fibonacci-based random number generation."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: FIBONACCI-BASED RANDOM GENERATION")
    print("=" * 60)
    print()
    print("The Fibonacci sequence mod m has period π(m) (Pisano period).")
    print("Entry points determine which indices yield zero mod m.\n")

    for m in [7, 11, 13, 17, 23, 29, 31]:
        pp = pisano_period(m)
        ep = entry_point(m) if is_prime(m) else "N/A"
        print(f"  m = {m:>3}: Pisano period π(m) = {pp:>4}, "
              f"entry point z(m) = {str(ep):>4}, "
              f"π(m)/z(m) = {pp/ep:.1f}" if isinstance(ep, int) else
              f"  m = {m:>3}: Pisano period π(m) = {pp:>4}, entry point z(m) = {ep}")

    print()
    print("  Key insight: π(p) is always a multiple of z(p).")
    print("  This constrains the structure of Fibonacci-based PRNGs.")
    print()

    # Show a sample sequence
    m = 97
    seq = fibonacci_rng(1, 1, m, 20)
    print(f"  Sample: F(n) mod {m} for n=0..19:")
    print(f"    {seq}")

# ============================================================
# Application 3: Efficient Fibonacci Divisibility Check
# ============================================================

def demo_divisibility_check():
    """Show how entry points enable efficient divisibility checks."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: EFFICIENT DIVISIBILITY CHECKING")
    print("=" * 60)
    print()
    print("Instead of computing huge Fibonacci numbers, use:")
    print("  p | F(n) ⟺ z(p) | n")
    print("This reduces divisibility to a single modular arithmetic check!\n")

    # Example: Does 13 divide F(10000)?
    test_cases = [
        (13, 10000),
        (7, 9999),
        (89, 100000),
        (233, 50000),
        (2, 300),
        (5, 1000),
    ]

    for p, n in test_cases:
        z = entry_point(p)
        divides = (n % z == 0)
        verification = (fib_mod(n, p) == 0)
        assert divides == verification, f"Mismatch for p={p}, n={n}"
        print(f"  Does {p} | F({n})? "
              f"z({p}) = {z}, {n} mod {z} = {n % z}, "
              f"Answer: {'YES' if divides else 'NO'}")

    print()
    print("  This works even for astronomically large n!")
    print("  For example: Does 7 | F(10^100)?")
    z7 = entry_point(7)
    huge_n = 10**100
    divides = (huge_n % z7 == 0)
    print(f"  z(7) = {z7}, 10^100 mod {z7} = {huge_n % z7}, "
          f"Answer: {'YES' if divides else 'NO'}")

# ============================================================
# Application 4: Pisano Period Structure
# ============================================================

def demo_pisano_structure():
    """Show the relationship between entry points and Pisano periods."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: PISANO PERIOD STRUCTURE")
    print("=" * 60)
    print()
    print("For prime p, the Pisano period π(p) satisfies:")
    print("  - z(p) | π(p) (entry point divides period)")
    print("  - π(p) | p² - 1 (period divides p² - 1)")
    print("  - π(p) = z(p) · k where k ∈ {1, 2, 4}\n")

    print(f"{'p':>5} {'z(p)':>6} {'π(p)':>6} {'π/z':>5} {'p²-1':>8} {'(p²-1)/π':>8}")
    print("-" * 45)

    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        z = entry_point(p)
        pi = pisano_period(p)
        ratio = pi // z
        p2m1 = p * p - 1
        print(f"{p:>5} {z:>6} {pi:>6} {ratio:>5} {p2m1:>8} {p2m1 // pi:>8}")

    print()
    print("  Note: π(p)/z(p) is always 1, 2, or 4.")
    print("  This reflects the structure of the multiplicative group")
    print("  of F_p[√5] (or F_{p²} when 5 is not a square mod p).")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications of Fibonacci Entry-Point Theory           ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    demo_primality_testing()
    demo_random_generation()
    demo_divisibility_check()
    demo_pisano_structure()

    print("\n" + "=" * 60)
    print("All application demos complete!")


#!/usr/bin/env python3
"""
Fibonacci Entry Points and Primitive Prime Divisors
====================================================

Demonstrates the key concepts from Carmichael's 1913 theorem:
for every composite n ≥ 13, the Fibonacci number F(n) has a primitive
prime divisor — a prime p | F(n) with p ∤ F(k) for all 0 < k < n.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd, log2
from functools import lru_cache

# ============================================================
# Core Functions
# ============================================================

def fib(n):
    """Compute the n-th Fibonacci number."""
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def prime_sieve(limit):
    """Sieve of Eratosthenes."""
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def entry_point(p):
    """Entry point (rank of apparition) of prime p in Fibonacci sequence."""
    a, b = 0, 1
    for k in range(1, p * p + 1):
        a, b = b, (a + b) % p
        if a == 0:
            return k
    return None

def small_prime_factors(n, limit=10000):
    """Return prime factors of n up to limit."""
    factors = set()
    d = 2
    while d * d <= n and d <= limit:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1 and n <= limit * limit:
        factors.add(n)
    return factors

def proper_divisors(n):
    """Return proper divisors of n."""
    return [d for d in range(1, n) if n % d == 0]

def primitive_residual(n):
    """
    Compute the primitive residual of F(n):
    iteratively divide F(n) by gcd(F(n), F(d)) for proper d | n.
    If result > 1, F(n) has a primitive prime divisor.
    """
    fn = fib(n)
    if fn <= 1:
        return 0
    rem = fn
    divs = [d for d in range(1, n) if d > 0 and n % d == 0]
    for _ in range(200):
        changed = False
        for d in divs:
            g = gcd(rem, fib(d))
            if g > 1:
                rem = rem // g
                changed = True
        if not changed:
            break
    return rem

# ============================================================
# Demo 1: Entry Points Table
# ============================================================

def demo_entry_points():
    print("=" * 60)
    print("ENTRY POINTS OF PRIMES IN THE FIBONACCI SEQUENCE")
    print("=" * 60)
    print(f"{'Prime p':>10} {'Entry z(p)':>12} {'F(z(p))':>15}")
    print("-" * 40)

    primes = prime_sieve(50)
    for p in primes:
        z = entry_point(p)
        fz = fib(z)
        print(f"{p:>10} {z:>12} {fz:>15}")

    print("\nKey: z(p) is the smallest k > 0 with p | F(k).")
    print("Fundamental theorem: p | F(n) ⟺ z(p) | n")

# ============================================================
# Demo 2: Verify Entry Point Divisibility
# ============================================================

def demo_entry_point_divisibility():
    print("\n" + "=" * 60)
    print("ENTRY POINT DIVISIBILITY: p | F(n) ⟺ z(p) | n")
    print("=" * 60)

    for p in [2, 3, 5, 7, 11, 13]:
        z = entry_point(p)
        # Verify mod p using Fibonacci mod p
        a, b = 0, 1
        all_match = True
        for n in range(1, 100):
            a, b = b, (a + b) % p
            divides_fib = (a == 0)
            divides_idx = (n % z == 0)
            if divides_fib != divides_idx:
                all_match = False
                break

        status = "✓" if all_match else "✗"
        print(f"  p={p:>3}, z(p)={z:>3}: Verified for n=1..99 {status}")

# ============================================================
# Demo 3: Primitive Divisors
# ============================================================

def demo_primitive_divisors():
    print("\n" + "=" * 60)
    print("PRIMITIVE PRIME DIVISORS OF FIBONACCI NUMBERS")
    print("=" * 60)
    print(f"{'n':>4} {'F(n)':>15} {'Type':>10} {'Residual':>12} {'Has primitive?':>15}")
    print("-" * 60)

    for n in range(2, 35):
        fn = fib(n)
        comp = "composite" if not is_prime(n) and n > 1 else "prime"
        res = primitive_residual(n) if not is_prime(n) and n > 1 else fn
        has_prim = "YES" if res > 1 else "no"
        fn_str = str(fn) if fn < 10**14 else f"{fn:.3e}"
        print(f"{n:>4} {fn_str:>15} {comp:>10} {res:>12} {has_prim:>15}")

    print()
    print("Carmichael's Theorem: For composite n ≥ 13, the residual > 1,")
    print("meaning F(n) always has a primitive prime divisor.")
    print("n = 12 is the last exception: F(12) = 144 = 2⁴·3²,")
    print("and 2|F(3), 3|F(4) — no new primes appear.")

# ============================================================
# Demo 4: GCD Identity
# ============================================================

def demo_gcd_identity():
    print("\n" + "=" * 60)
    print("FIBONACCI GCD IDENTITY: gcd(F(m), F(n)) = F(gcd(m,n))")
    print("=" * 60)

    examples = [(6, 9), (8, 12), (10, 15), (12, 18), (14, 21), (20, 30)]
    for m, n in examples:
        fm, fn = fib(m), fib(n)
        g = gcd(fm, fn)
        fg = fib(gcd(m, n))
        status = "✓" if g == fg else "✗"
        print(f"  gcd(F({m}), F({n})) = gcd({fm}, {fn}) = {g} = F({gcd(m,n)}) {status}")

# ============================================================
# Demo 5: Verification
# ============================================================

def demo_carmichael_verification():
    print("\n" + "=" * 60)
    print("COMPUTATIONAL VERIFICATION OF CARMICHAEL'S THEOREM")
    print("=" * 60)

    exceptions = []
    for n in range(4, 200):
        if is_prime(n):
            continue
        res = primitive_residual(n)
        if n >= 13 and res <= 1:
            exceptions.append(n)

    if not exceptions:
        print(f"  ✓ Verified: all composite n ∈ [13, 199] have primitive residual > 1")
    else:
        print(f"  ✗ Exceptions: {exceptions}")

    print("\nExceptional cases (composite n < 13):")
    for n in [4, 6, 8, 9, 10, 12]:
        res = primitive_residual(n)
        print(f"  n={n:>2}: F({n})={fib(n):>6}, residual={res} {'← no primitive!' if res <= 1 else ''}")

# ============================================================
# Demo 6: Visualization
# ============================================================

def demo_visualization():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Entry points
    primes = prime_sieve(200)
    eps = [entry_point(p) for p in primes]

    ax = axes[0, 0]
    ax.scatter(primes, eps, s=12, alpha=0.7, c='steelblue')
    ax.plot([0, 200], [0, 200], 'r--', alpha=0.3, label='z(p) = p')
    ax.set_xlabel('Prime p')
    ax.set_ylabel('Entry point z(p)')
    ax.set_title('Fibonacci Entry Points of Primes')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: z(p)/p ratio
    ax = axes[0, 1]
    ratios = [z/p for p, z in zip(primes, eps)]
    ax.scatter(primes, ratios, s=12, alpha=0.7, c='coral')
    ax.axhline(y=1, color='r', linestyle='--', alpha=0.3)
    ax.set_xlabel('Prime p')
    ax.set_ylabel('z(p) / p')
    ax.set_title('Normalized Entry Points (z(p)/p)')
    ax.grid(True, alpha=0.3)

    # Plot 3: Primitive residuals
    ax = axes[1, 0]
    ns = list(range(4, 80))
    residuals = []
    colors = []
    for n in ns:
        if is_prime(n):
            residuals.append(0)
            colors.append('lightgray')
        else:
            res = primitive_residual(n)
            residuals.append(min(log2(res) if res > 1 else 0, 40))
            colors.append('steelblue' if n >= 13 else 'red')

    ax.bar(ns, residuals, color=colors, alpha=0.7, width=0.8)
    ax.axvline(x=12.5, color='green', linestyle='--', alpha=0.5, label='n = 13 threshold')
    ax.set_xlabel('Index n')
    ax.set_ylabel('log₂(primitive residual)')
    ax.set_title('Primitive Residual of F(n) for Composite n')
    ax.legend()
    ax.grid(True, alpha=0.3, axis='y')

    # Plot 4: Growth comparison
    ax = axes[1, 1]
    ns = list(range(2, 60))
    log_fib = [log2(fib(n)) if fib(n) > 0 else 0 for n in ns]

    log_prod = []
    for n in ns:
        if not is_prime(n) and n > 3:
            divs = proper_divisors(n)
            prod_log = sum(log2(fib(d)) for d in divs if fib(d) > 1)
            log_prod.append(prod_log)
        else:
            log_prod.append(None)

    ax.plot(ns, log_fib, 'b-', label='log₂ F(n)', linewidth=1.5)
    comp_ns = [n for n, lp in zip(ns, log_prod) if lp is not None]
    comp_lp = [lp for lp in log_prod if lp is not None]
    ax.scatter(comp_ns, comp_lp, c='red', s=15, alpha=0.7,
              label='Σ log₂ F(d), proper d|n', zorder=5)
    ax.set_xlabel('Index n')
    ax.set_ylabel('log₂')
    ax.set_title('F(n) Growth vs. Proper Divisor Contributions')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/fibonacci_entry_points.png', dpi=150, bbox_inches='tight')
    print("\nVisualization saved to demos/fibonacci_entry_points.png")

# ============================================================
if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Fibonacci Entry Points & Carmichael's Theorem Demo     ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    demo_entry_points()
    demo_entry_point_divisibility()
    demo_primitive_divisors()
    demo_gcd_identity()
    demo_carmichael_verification()
    demo_visualization()

    print("\n" + "=" * 60)
    print("All demos complete!")
