#!/usr/bin/env python3
"""
demo.py — Numerical illustration of the Non-Archimedean Factoring Oracle theorem.

Theorem (corrected):
    For every composite n > 1, there exist a, b > 1 such that a * b = n.

This script:
  1. Tests the theorem on a range of composite numbers.
  2. Shows that primes are counterexamples to the original (uncorrected) statement.
  3. Illustrates the p-adic valuation landscape for factored numbers.
  4. Saves a visualization to factoring_oracle.png.
"""

import math
from collections import defaultdict


def is_prime(n: int) -> bool:
    """Simple primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def smallest_nontrivial_factor(n: int) -> int:
    """Find the smallest divisor d > 1 of n (which will be prime)."""
    if n <= 1:
        raise ValueError(f"n must be > 1, got {n}")
    for d in range(2, int(math.isqrt(n)) + 1):
        if n % d == 0:
            return d
    return n  # n is prime


def factor_oracle(n: int):
    """
    The factoring oracle: given composite n > 1, produce (a, b) with a*b = n, a > 1, b > 1.

    This mirrors the formal Lean proof:
      1. Extract a non-trivial divisor k of n (with 1 < k < n).
      2. Set a = k, b = n // k.

    Raises ValueError if n is prime (the theorem does not apply).
    """
    if n <= 1:
        raise ValueError(f"n must be > 1, got {n}")
    if is_prime(n):
        raise ValueError(f"n = {n} is prime — the original theorem is FALSE for primes!")

    k = smallest_nontrivial_factor(n)
    a, b = k, n // k
    assert a * b == n, f"Factoring failed: {a} * {b} != {n}"
    assert a > 1, f"Factor a = {a} is not > 1"
    assert b > 1, f"Factor b = {b} is not > 1"
    return a, b


def p_adic_valuation(n: int, p: int) -> int:
    """Compute v_p(n), the p-adic valuation of n."""
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def main():
    print("=" * 70)
    print("  NON-ARCHIMEDEAN FACTORING ORACLE — Numerical Demonstration")
    print("=" * 70)

    # --- Part 1: Verify the corrected theorem on composite numbers ---
    print("\n[1] Factoring oracle on composite numbers (n = 4..50):\n")
    print(f"  {'n':>4s}  {'a':>4s}  {'b':>4s}  {'a*b':>6s}  {'a>1':>4s}  {'b>1':>4s}  Status")
    print("  " + "-" * 50)
    composites_tested = 0
    for n in range(4, 51):
        if is_prime(n):
            continue
        a, b = factor_oracle(n)
        status = "✓" if (a * b == n and a > 1 and b > 1) else "✗"
        print(f"  {n:4d}  {a:4d}  {b:4d}  {a*b:6d}  {'T':>4s}  {'T':>4s}  {status}")
        composites_tested += 1

    print(f"\n  All {composites_tested} composite numbers factored successfully.")

    # --- Part 2: Show primes are counterexamples ---
    print("\n[2] Primes are counterexamples to the ORIGINAL (uncorrected) statement:\n")
    primes_under_50 = [n for n in range(2, 51) if is_prime(n)]
    print(f"  Primes under 50: {primes_under_50}")
    print(f"  None of these can be written as a*b with a > 1 and b > 1.")
    for p in primes_under_50[:5]:
        try:
            factor_oracle(p)
        except ValueError as e:
            print(f"  factor_oracle({p}): {e}")

    # --- Part 3: p-adic valuation landscape ---
    print("\n[3] p-adic valuation landscape (key insight for the p-adic context):\n")
    print("  The p-adic valuation v_p(n) = v_p(a) + v_p(b) is additive under")
    print("  multiplication, connecting factorization to p-adic structure.\n")

    test_primes = [2, 3, 5]
    n_values = [12, 30, 60, 100, 360]

    print(f"  {'n':>5s}", end="")
    for p in test_primes:
        print(f"  v_{p}(n)", end="")
    print("  factorization  valuation check")
    print("  " + "-" * 65)

    for n in n_values:
        a, b = factor_oracle(n)
        print(f"  {n:5d}", end="")
        checks = []
        for p in test_primes:
            vn = p_adic_valuation(n, p)
            va = p_adic_valuation(a, p)
            vb = p_adic_valuation(b, p)
            print(f"  {vn:5d}", end="")
            checks.append(vn == va + vb)
        all_ok = all(checks)
        print(f"    {a:>3d} × {b:<4d}   {'✓ additive' if all_ok else '✗ ERROR'}")

    # --- Part 4: Key insight ---
    print("\n" + "=" * 70)
    print("  KEY INSIGHT:")
    print("  The corrected theorem is a foundational fact: every composite")
    print("  number admits a non-trivial factorization. The original statement")
    print("  was FALSE because it omitted the compositeness hypothesis.")
    print("  In the formal Lean proof, Mathlib's Nat.exists_dvd_of_not_prime2")
    print("  extracts a divisor 1 < k < n for any composite n > 1, and the")
    print("  complementary factor n/k completes the factorization.")
    print("=" * 70)

    # --- Part 5: Save visualization ---
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np

        fig, axes = plt.subplots(1, 2, figsize=(14, 6))

        # Left: factorization tree
        ax = axes[0]
        ns = list(range(4, 61))
        composites = [n for n in ns if not is_prime(n)]
        factors_a = []
        factors_b = []
        for n in composites:
            a, b = factor_oracle(n)
            factors_a.append(a)
            factors_b.append(b)

        ax.scatter(factors_a, factors_b, c=composites, cmap='viridis',
                   s=80, edgecolors='black', linewidths=0.5, alpha=0.8)
        for i, n in enumerate(composites):
            ax.annotate(str(n), (factors_a[i], factors_b[i]),
                        fontsize=6, ha='center', va='bottom')
        ax.set_xlabel('Smallest factor a', fontsize=12)
        ax.set_ylabel('Complementary factor b = n/a', fontsize=12)
        ax.set_title('Factoring Oracle: (a, b) for composite n ∈ [4, 60]', fontsize=13)
        ax.grid(True, alpha=0.3)

        # Right: p-adic valuations
        ax = axes[1]
        ns_range = list(range(2, 61))
        for p_val, color in [(2, '#e74c3c'), (3, '#2ecc71'), (5, '#3498db')]:
            vals = [p_adic_valuation(n, p_val) for n in ns_range]
            ax.bar([n + (p_val - 3) * 0.25 for n in ns_range], vals,
                   width=0.25, alpha=0.7, color=color, label=f'v_{p_val}(n)')

        ax.set_xlabel('n', fontsize=12)
        ax.set_ylabel('p-adic valuation', fontsize=12)
        ax.set_title('p-adic valuations v_p(n) for p ∈ {2, 3, 5}', fontsize=13)
        ax.legend(fontsize=11)
        ax.grid(True, alpha=0.3, axis='y')

        plt.tight_layout()
        plt.savefig('factoring_oracle.png', dpi=150, bbox_inches='tight')
        print(f"\n  Visualization saved to factoring_oracle.png")

    except ImportError:
        print("\n  [matplotlib not available — skipping visualization]")


if __name__ == "__main__":
    main()
