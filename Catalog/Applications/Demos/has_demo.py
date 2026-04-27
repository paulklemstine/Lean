#!/usr/bin/env python3
"""
demo.py — Illustrating the Non-Archimedean Factoring Oracle theorem.

The formally verified theorem states:
    For every composite n > 1 (i.e., n > 1 and n is not prime),
    there exist a, b > 1 such that a * b = n.

This demo:
  1. Tests the theorem computationally on a range of integers.
  2. Shows that primes are correctly excluded (the original statement was false for primes).
  3. Visualizes the factorization landscape using matplotlib.
"""

import math


def is_prime(n: int) -> bool:
    """Check if n is prime."""
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


def find_nontrivial_factorization(n: int):
    """
    The 'factoring oracle': for composite n > 1, find a, b > 1 with a * b = n.

    This mirrors the Lean proof which uses Nat.exists_dvd_of_not_prime2 to find
    a divisor k with 1 < k < n, then sets a = k, b = n // k.
    """
    if n <= 1:
        return None  # precondition: n > 1
    if is_prime(n):
        return None  # precondition: n is not prime

    # Find the smallest non-trivial divisor (analogous to Nat.minFac)
    for k in range(2, n):
        if n % k == 0:
            a, b = k, n // k
            assert a * b == n
            assert a > 1 and b > 1
            return (a, b)
    return None  # unreachable for composite n


def main():
    """Main demonstration of the factoring oracle theorem."""

    print("=" * 70)
    print("  NON-ARCHIMEDEAN FACTORING ORACLE — Computational Demonstration")
    print("=" * 70)
    print()

    # Key insight: The original theorem claimed ALL n > 1 can be non-trivially
    # factored. This is FALSE for primes. The corrected theorem adds ¬Prime(n).
    print("KEY INSIGHT: Every composite n > 1 has a non-trivial factorization,")
    print("but primes do NOT. The original statement was false; the corrected")
    print("version adds the hypothesis that n is not prime.")
    print()

    # Demonstrate on integers 2..30
    print(f"{'n':>4} | {'Prime?':>7} | {'Factorization':>20} | {'Status':>12}")
    print("-" * 55)

    primes_found = []
    composites_factored = []

    for n in range(2, 31):
        if is_prime(n):
            primes_found.append(n)
            print(f"{n:>4} | {'Yes':>7} | {'N/A (prime)':>20} | {'excluded':>12}")
        else:
            result = find_nontrivial_factorization(n)
            a, b = result
            composites_factored.append((n, a, b))
            print(f"{n:>4} | {'No':>7} | {f'{a} × {b} = {n}':>20} | {'✓ factored':>12}")

    print()
    print(f"Primes (excluded by corrected theorem): {primes_found}")
    print(f"Composites factored: {len(composites_factored)}")
    print()

    # Demonstrate on larger numbers including semiprimes
    print("=" * 70)
    print("  Large semiprime examples (relevant to cryptography)")
    print("=" * 70)
    test_cases = [
        143,     # 11 × 13
        10007 * 10009,  # product of two primes
        2 ** 16 + 1,    # 65537 (Fermat prime — should be excluded!)
        2 ** 16,        # 65536 = 2^16 (highly composite)
        561,            # Carmichael number: 3 × 11 × 17
    ]

    for n in test_cases:
        if is_prime(n):
            print(f"  n = {n:>12} — PRIME (theorem does not apply)")
        else:
            a, b = find_nontrivial_factorization(n)
            print(f"  n = {n:>12} = {a} × {b}")

    print()
    print("=" * 70)
    print("  The Lean proof uses Nat.exists_dvd_of_not_prime2 from Mathlib")
    print("  to extract a witness divisor k with 1 < k < n for composite n,")
    print("  then constructs the pair (k, n/k) as the factorization.")
    print("=" * 70)

    # Try to create a visualization
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np

        fig, ax = plt.subplots(1, 1, figsize=(12, 6))

        ns = list(range(2, 101))
        colors = []
        smallest_factors = []

        for n in ns:
            if is_prime(n):
                colors.append('#e74c3c')  # red for primes
                smallest_factors.append(n)  # prime's smallest non-trivial factor is itself
            else:
                for k in range(2, n):
                    if n % k == 0:
                        smallest_factors.append(k)
                        break
                colors.append('#2ecc71')  # green for composites

        ax.bar(ns, smallest_factors, color=colors, width=0.8, alpha=0.8)
        ax.set_xlabel('n', fontsize=14)
        ax.set_ylabel('Smallest non-trivial divisor', fontsize=14)
        ax.set_title('Factoring Oracle: Primes (red) vs Composites (green)\n'
                      'The theorem applies only to green bars', fontsize=14)

        # Add legend
        from matplotlib.patches import Patch
        legend_elements = [
            Patch(facecolor='#e74c3c', alpha=0.8, label='Prime (excluded)'),
            Patch(facecolor='#2ecc71', alpha=0.8, label='Composite (factorable)')
        ]
        ax.legend(handles=legend_elements, fontsize=12)
        ax.set_xlim(1, 101)

        plt.tight_layout()
        plt.savefig('factoring_oracle.png', dpi=150)
        print(f"\nVisualization saved to factoring_oracle.png")
    except ImportError:
        print("\n(matplotlib not available — skipping visualization)")


if __name__ == "__main__":
    main()
