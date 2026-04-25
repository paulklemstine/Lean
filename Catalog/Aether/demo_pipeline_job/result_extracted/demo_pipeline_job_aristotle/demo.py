#!/usr/bin/env python3
"""
demo.py — Numerical illustration of the Non-Archimedean Factoring Oracle theorem.

Theorem (corrected): Every composite integer n > 1 admits a nontrivial factorization
n = a * b with a > 1 and b > 1.

This script:
  1. Demonstrates the theorem by factoring composite numbers.
  2. Shows WHY the original (uncorrected) statement fails for primes.
  3. Visualizes the "factoring landscape" — for each n, plots its smallest
     nontrivial factor (the one used in the Lean proof via Nat.minFac).
  4. Saves a PNG visualization.
"""

import math
import sys

# ---------------------------------------------------------------------------
# Core factoring logic mirroring the Lean proof
# ---------------------------------------------------------------------------

def smallest_nontrivial_factor(n: int) -> int:
    """
    Find the smallest divisor d of n with 1 < d < n.
    This mirrors Nat.exists_dvd_of_not_prime2 in Mathlib:
    given n > 1 and ¬ Prime n, extract a nontrivial divisor.
    Returns 0 if n is prime (no such factor exists).
    """
    if n <= 1:
        return 0
    for d in range(2, int(math.isqrt(n)) + 1):
        if n % d == 0:
            return d
    return 0  # n is prime


def factoring_oracle(n: int):
    """
    The factoring oracle: given composite n > 1, produce (a, b) with
    a * b = n, a > 1, b > 1.

    This is exactly the witness construction in the Lean proof:
      a = minFac(n),  b = n / minFac(n)
    """
    assert n > 1, "n must be > 1"
    d = smallest_nontrivial_factor(n)
    if d == 0:
        raise ValueError(f"{n} is prime — the original theorem is FALSE for primes!")
    a, b = d, n // d
    assert a * b == n, "Product check failed"
    assert a > 1 and b > 1, "Nontriviality check failed"
    return a, b


# ---------------------------------------------------------------------------
# Demonstration
# ---------------------------------------------------------------------------

def demonstrate_theorem():
    """Show the theorem in action on composite numbers."""
    print("=" * 65)
    print("  NON-ARCHIMEDEAN FACTORING ORACLE — Numerical Demonstration")
    print("=" * 65)
    print()
    print("Theorem: Every composite n > 1 has a, b > 1 with a * b = n.")
    print()

    # Composite examples
    composites = [4, 6, 9, 12, 15, 21, 35, 49, 100, 561, 1729, 8051]
    print("── Composite numbers (theorem applies) ─────────────────────────")
    for n in composites:
        a, b = factoring_oracle(n)
        print(f"  n = {n:>5}  →  {a} × {b} = {n}   ✓")

    print()
    print("── Prime numbers (original statement FAILS) ─────────────────────")
    primes = [2, 3, 5, 7, 11, 13, 97, 101]
    for p in primes:
        d = smallest_nontrivial_factor(p)
        status = "no nontrivial factors" if d == 0 else f"factor {d}"
        print(f"  n = {p:>5}  →  {status}  ✗  (prime — correctly excluded)")


def demonstrate_counterexample():
    """Show exactly why the original statement is false."""
    print()
    print("── Why the ORIGINAL statement is false ──────────────────────────")
    print()
    print("  Original claim: ∀ n > 1, ∃ a b > 1, a * b = n")
    print("  Counterexample: n = 2 (prime)")
    print("    The only factorizations of 2 are: 1 × 2 and 2 × 1")
    print("    Neither has BOTH factors > 1.")
    print("    Therefore the original statement is FALSE.")
    print()
    print("  Corrected claim: ∀ n > 1, ¬ Prime n → ∃ a b > 1, a * b = n  ✓")


def factoring_landscape():
    """
    Compute and display the 'factoring landscape': for each n from 2 to N,
    show its smallest nontrivial factor (0 if prime).
    """
    N = 60
    print()
    print("── Factoring landscape (smallest nontrivial factor) ─────────────")
    print(f"  n:    ", end="")
    for n in range(2, N + 1):
        print(f"{n:>3}", end="")
    print()
    print(f"  d(n): ", end="")
    for n in range(2, N + 1):
        d = smallest_nontrivial_factor(n)
        if d == 0:
            print("  .", end="")  # prime
        else:
            print(f"{d:>3}", end="")
    print()
    print("  (dots = primes, numbers = smallest nontrivial factor)")


def save_visualization():
    """Save a PNG visualization if matplotlib is available."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("\n  [matplotlib not available — skipping PNG generation]")
        return

    N = 200
    ns = list(range(2, N + 1))
    factors = []
    colors = []
    for n in ns:
        d = smallest_nontrivial_factor(n)
        if d == 0:
            factors.append(0)
            colors.append('#e74c3c')  # red for primes
        else:
            factors.append(d)
            colors.append('#2ecc71')  # green for composites

    fig, ax = plt.subplots(figsize=(14, 5))
    ax.bar(ns, factors, color=colors, width=1.0, edgecolor='none')
    ax.set_xlabel('n', fontsize=13)
    ax.set_ylabel('Smallest nontrivial factor d(n)', fontsize=13)
    ax.set_title(
        'Factoring Oracle: Composite numbers (green) vs Primes (red, d=0)',
        fontsize=14
    )

    # Legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='#2ecc71', label='Composite (theorem applies)'),
        Patch(facecolor='#e74c3c', label='Prime (original stmt FALSE)'),
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=11)

    plt.tight_layout()
    plt.savefig('factoring_oracle.png', dpi=150)
    print(f"\n  [Saved visualization to factoring_oracle.png]")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    """
    KEY INSIGHT: The original theorem statement is false because primes
    have no nontrivial factorization. The corrected theorem — adding the
    hypothesis ¬ Prime n — is both true and formally verified in Lean 4.

    The proof extracts the minimal nontrivial factor d of a composite n,
    then constructs the pair (d, n/d) as witnesses.
    """
    demonstrate_theorem()
    demonstrate_counterexample()
    factoring_landscape()
    save_visualization()

    print()
    print("=" * 65)
    print("  Key insight: The existence of nontrivial factors for composite")
    print("  numbers is the certified mathematical foundation upon which")
    print("  all factoring algorithms rest. Formal verification caught")
    print("  the error in the original statement immediately.")
    print("=" * 65)


if __name__ == "__main__":
    main()
